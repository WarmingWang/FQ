# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

import re
import logging
import time
import random

from tqdm import tqdm
from FQ.src.utils import utils
from FQ.src.db import dbutils
from FQ.src.db import dbfundquant
from urllib.request import urlopen, Request
from multiprocessing import Process, Pool

logger = logging.getLogger(__name__)  # 操作日志对象
logging.basicConfig(level=logging.ERROR)

class Audit:
    URL_HOME = 'http://fund.eastmoney.com'

    def funddayaudit(self, flag=0):
        """
        行情稽核
            1、下载基金行情总数
            2、用sql检查行情数量是否相等
        """

        db = dbutils.MysqlConn('dbfundquant')
        db.open()
        if flag == 0:
            pool = Pool(8)  # 创建一个8个进程的进程池
            try:
                """清空行情审核表funddayaudit"""
                db.execSql("truncate table funddayaudit", False)

                sql = "select company_code from fundcompany where lastupdate = '%s' order by company_code" % utils.getCurDate()
                companies = db.execSql(sql, False)
                if len(companies) <= 0:
                    return 0
                # ------------- 配置好进度条 -------------
                pbar = tqdm(total=len(companies))
                pbar.set_description("稽核fundday：  {}".format(time.strftime('%Y-%m-%d %H:%M:%S')))
                update = lambda *args: pbar.update()
                # --------------------------------------
                for company in companies:
                    # self.getfunddayRecords(str(company[0]))
                    pool.apply_async(func=self.getfunddayRecords, args=(str(company[0]),), callback=update)  # 通过callback来更新进度条

            finally:
                pool.close()
                pool.join()

        sql = "SELECT a.fund_code, a.funddayrecords factrecords, b.funddayrecords \
                 FROM funddayaudit a, \
                      ( SELECT fund_code, COUNT( 1 ) funddayrecords FROM fundday GROUP BY fund_code ) b \
                WHERE a.fund_code = b.fund_code \
                  AND a.funddayrecords <> b.funddayrecords \
                ORDER BY a.fund_code"
        funddayaudit = db.execSql(sql, False)
        db.close()
        return funddayaudit

    def getfunddayRecords(self, company_code: str):
        """获取记录数和页码"""

        def getRecordsAndPages(html: str):
            ret = re.search(
                r'records:([0-9]\d*),pages:([0-9]\d*)',
                html, re.S)
            return ret

        db = dbutils.MysqlConn('dbfundquant')
        db.open()
        sql = "select fund_code from fundinfo where company_code = '%s' order by fund_code" % company_code
        funds = db.execSql(sql, False)
        db.close()
        values = []
        value = []
        for fund in funds:
            url = 'http://fund.eastmoney.com/f10/F10DataApi.aspx?type=lsjz&code=' + str(fund[0]) + '&per=1'
            html = utils.get_urlopen(url)
            rp = getRecordsAndPages(html)
            records = int(rp.group(1))
            value.append(fund[0])
            value.append(records)
            values.append(tuple(value))
            value = []

        dbfq = dbfundquant.DBFundQuant()
        iRet = dbfq.insertFunddayAudit(funddayaudits=values)
        if iRet != 0:
            return iRet
        return 0

if __name__ == '__main__':
    pass
    # aud = Audit()
    # aud.funddayaudit()