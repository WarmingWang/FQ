# -*- coding: UTF-8 -*-

import re
import gzip
import logging
from urllib.request import urlopen, Request

logger = logging.getLogger(__name__)  # 操作日志对象
logging.basicConfig(level=logging.NOTSET)

def ungzip(data):
    try:  # 尝试解压
        print('正在解压.....')
        data = gzip.decompress(data)
        print('解压完毕!')
    except:
        print('未经压缩, 无需解压')
    return data

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
        html = ungzip(html).decode('utf-8')
        cre = re.compile('<table id="gspmTbl".*?<tbody>(.*?)</tbody>', re.S)
        html_table = cre.findall(html)[0]

        companies = []
        rows = re.findall(r'<tr(.*?)</tr>', html_table, re.S)
        logger.info('爬取基金公司个数：'+str(len(rows)))
        for row in rows:
            tds = re.findall(r'class="td-align-left" data-sortvalue="(.*?)" ><a href="(.*?)">(.*?)</a></td>.*?(\d\d\d\d-\d\d-\d\d)', row, re.S)
            for td in tds:
                companies.append(td)
        # print (companies[0])

        return companies

    def downloadfundinfo(self):
        return 'downloadFundinfo success...'

    def downloadfundday(self):
        return 'downloadFundinfo success...'