# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

from src.db import dbutils
from src.db import dbfundquant
from src.crawler import downloadfromtt


def print_hi(name):

    dl = downloadfromtt.DownloadFromTT()
    dbfq = dbfundquant.DBFundQuant()

    """网页抓取数据库中没有的基金公司"""
    companies = dl.downloadfundcompany()
    """基金公司到数据库"""
    dbfq.insertFundCompany(companies)


    """从数据库获取所有基金公司,抓取基金到数据库"""
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    sql = "select company_code from fundcompany order by company_code"
    companies = db.execSql(sql, False)
    for company in companies:
        """通过基金抓取对应的开放式基金"""
        funds = dl.openfundincompany(company[0])
        dbfq.insertFundinfo(company[0], funds)
    db.close()


    """
    下载基金对应的行情信息到数据库
    getfundday内部调用dbfq.insertFundday()实现插入数据库操作
    """
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    sql = "select company_code from fundcompany order by company_code"
    companies = db.execSql(sql, False)
    for company in companies:
        """通过基金抓取对应的开放式基金"""
        funds = dl.openfundincompany(company[0])
        dbfq.insertFundinfo(company[0], funds)
    db.close()
    dl.getfunddayhis('001631', 49)



# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

# fundQuant主入口
# 爬天天基金的数据写到mysql数据库中（downloadfromtt;）
