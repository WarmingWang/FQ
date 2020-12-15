# -*- coding: UTF-8 -*-

import re
import logging

from src.utils import utils
from src.db import dbutils
from src.db import dbfundquant
from urllib.request import urlopen, Request

logger = logging.getLogger(__name__)  # 操作日志对象
logging.basicConfig(level=logging.DEBUG)

"""
每日行情：http://fund.eastmoney.com/bzdm.html#os_0;isall_0;ft_;pt_1
"""


class DownloadFromTT:
    headers = {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'Accept-Encoding': 'gzip, deflate',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.67 Safari/537.36 Edg/87.0.664.47'
    }
    URL_HOME = 'http://fund.eastmoney.com'

    def downloadfundcompany(self) -> list:
        url_company = self.URL_HOME + '/company'
        html = urlopen(Request(url_company, headers=self.headers)).read()
        html = utils.ungzip(html).decode('utf-8')
        cre = re.compile('<table id="gspmTbl".*?<tbody>(.*?)</tbody>', re.S)
        html_table = cre.findall(html)[0]

        companies = []
        rows = re.findall(r'<tr(.*?)</tr>', html_table, re.S)
        logger.info('爬取基金公司个数：' + str(len(rows)))

        db = dbutils.MysqlConn('dbfundquant')
        db.open()
        for row in rows:  # company_shortname,company_code,company_name,company_setupdate
            tds = re.findall(
                r'class="td-align-left" data-sortvalue="(.*?)" ><a href="/Company/(.*?).html">(.*?)</a></td>.*?(\d\d\d\d-\d\d-\d\d)',
                row, re.S)
            for td in tds:
                sql = "select * from fundcompany where company_code = '%s'" % (td[1])
                if not db.execSql(sql, False):
                    companies.append(td)
        # print(companies)
        logger.info('新增基金公司个数：' + str(len(companies)) + ' :' + str(companies))
        db.close()
        return companies

    """
        获取基金的2种方式
        1：根据基金公司页面抓取单个基金公司所有开放式基金基金信息   （目前采用方式）
        2：通过api接口获取所有基金 http://fund.eastmoney.com/js/fundcode_search.js
    """

    def openfundincompany(self, company_code: str) -> list:
        url_company = self.URL_HOME + '/Company/' + company_code + '.html'
        html = urlopen(Request(url_company, headers=self.headers)).read()
        html = utils.ungzip(html).decode('utf-8')
        cre = re.compile('<div id="kfsFundNetWrap">.*?</div>', re.S)
        html_table = cre.findall(html)[0]  # 基金名称                     基金代码
        rows = re.findall(r'<td class="fund-name-code">.*?<a.*?"name".*?>(.*?)</a>.*?<a.*?"code".*?>(.*?)</a>.*?</td>',
                          html_table, re.S)
        logger.info('基金公司代码：' + company_code + ' 爬取开放式基金个数：' + str(len(rows)))

        if len(rows) == 0:
            return []

        funds = []
        db = dbutils.MysqlConn('dbfundquant')
        db.open()
        for row in rows:
            sql = "select * from fundinfo where company_code = '%s' and fund_code = '%s'" % (company_code, row[1])
            if not db.execSql(sql, False):
                funds.append(row)
        # print(funds)
        logger.info('基金公司代码：' + company_code + ' 新增开放式基金个数：' + str(len(funds)) + ' :' + str(funds))
        db.close()
        return funds

    def getfunddaycur(self, fund_code: str) -> list:
        url_fundday = 'http://fund.eastmoney.com/js/fundcode_search.js'
        html = urlopen(Request(url_fundday, headers=self.headers)).read()
        jsonStr = utils.ungzip(html).decode('utf-8')
        print(jsonStr)

        return 'getfunddaycur success...'

    """
    获取基金历史行情
        基础库使用，调用一次，每日获取行情采用
        由于行情数据量大，无法全部获取数据再返回，所以在函数里获取一部分就插入数据库insertFundday
    :param
        code    基金代码（必填）
        sdate   起始日期 默认当前日期
        edate   截止日期 默认当前日期
        per     N条/页  默认20（经测试最大支持49）
    """

    def getfunddayhis(self, code: str, per=20, sdate='', edate=''):
        """获取记录数和页码"""

        def getRecordsAndPages(html: str):
            ret = re.search(
                r'records:([0-9]\d*),pages:([0-9]\d*)',
                html, re.S)
            return ret

        """解析html中的table表单，按返回字典"""

        def parsehtmltable(html: str) -> dict:
            thead = re.findall(r'<thead>(.*?)</thead>', html, re.S)
            head = re.findall(r'<th.*?>(.*?)</th>', thead[0], re.S)
            tbody = re.findall(r'<tbody>(.*?)</tbody>', html, re.S)
            rows = re.findall(r'<tr>(.*?)</tr>', tbody[0], re.S)
            dic = {}
            for row in rows:
                r = re.findall(r'<td.*?>(.*?)</td>', row, re.S)
                for i in range(len(head)):
                    dic.setdefault(head[i], []).append(r[i])
            return dic

        url = 'http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code=' + code + '&per=' + str(
            per) + '&sdate=' + sdate + '&edate=' + edate
        html = urlopen(Request(url + '&page=1', headers=self.headers)).read().decode('utf-8')

        rp = getRecordsAndPages(html)
        records = int(rp.group(1))
        pages = int(rp.group(2))
        values = []
        value = []
        x = dbfundquant.DBFundQuant()
        if records > 0 and pages > 0:
            funddaydic = parsehtmltable(html)
            for i in range(len(funddaydic['净值日期'])):
                value.append(code)
                value.append(funddaydic['净值日期'][i])
                value.append(funddaydic['单位净值'][i])
                value.append(funddaydic['累计净值'][i])
                value.append(funddaydic['申购状态'][i])
                value.append(funddaydic['赎回状态'][i])
                values.append(tuple(value))
                value = []
            x.insertFundday(values)
        else:
            return []

        for curpage in range(2, pages + 1, 1):
            values = []
            html = urlopen(Request(url + '&page=' + str(curpage), headers=self.headers)).read().decode('utf-8')
            funddaydic = parsehtmltable(html)
            for i in range(len(funddaydic['净值日期'])):
                value.append(code)
                value.append(funddaydic['净值日期'][i])
                value.append(funddaydic['单位净值'][i])
                value.append(funddaydic['累计净值'][i])
                value.append(funddaydic['申购状态'][i])
                value.append(funddaydic['赎回状态'][i])
                values.append(tuple(value))
                value = []
            x.insertFundday(values)

        return 0

tt = DownloadFromTT()
tt.getfunddayhis('001631',49)
