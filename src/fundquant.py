# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

from tqdm import tqdm
from FQ.src.utils import utils
from FQ.src.db import dbutils
from FQ.src.db import dbfundquant
from FQ.src.crawler import downloadfromtt


def exec_fundquant():
    dl = downloadfromtt.DownloadFromTT()
    dbfq = dbfundquant.DBFundQuant()

    """网页抓取数据库中没有的基金公司"""
    companies = dl.downloadfundcompany()
    """基金公司到数据库"""
    dbfq.insertFundCompany(companies)

    """从数据库获取所有基金公司,抓取基金到数据库"""
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    sql = "select company_code from fundcompany where IFNULL(lastupdate,'') <> '%s' order by company_code" % utils.getCurDate()
    companies = db.execSql(sql, False)
    companies = tqdm(companies)
    if companies.total > 0:
        for company in companies:
            companies.set_description("下载更新fundinfo：{}".format(company))
            """通过基金抓取对应的开放式基金"""
            funds = dl.openfundincompany(company[0])
            dbfq.insertFundinfo(company, funds)

            """更新fundcompany的lastupdate"""
            sql = "update fundcompany set lastupdate = '%s' where company_code = '%s'" % (utils.getCurDate(), company[0])
            db.execSql(sql, False)
    db.close()

    """
    下载基金对应的行情信息到数据库
    """
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    sql = "select fund_code from fundinfo where IFNULL(lastupdate,'') <> '%s' order by company_code,fund_code" % utils.getCurDate()
    funds = db.execSql(sql, False)
    try:
        with tqdm(funds) as t:
            for fund in t:
                t.set_description("下载更新fundday：{}".format(fund))
                """通过基金抓取对应的历史行情"""
                sql = "select max(date) from fundday where fund_code = '%s'" % str(fund[0])
                sdate = db.execSql(sql, False)[0][0]
                if sdate == None:
                    dl.getfundday(str(fund[0]))
                else:
                    dl.getfundday(str(fund[0]), str(sdate))

                """更新fundinfo的lastupdate"""
                sql = "update fundinfo set lastupdate = '%s' where fund_code = '%s'" % (utils.getCurDate(), str(fund[0]))
                db.execSql(sql, False)
    except KeyboardInterrupt:
        t.close()#试图解决进度条换行的问题
        raise
    t.close()
    db.close()





# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    exec_fundquant()
