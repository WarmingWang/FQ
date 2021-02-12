# -*- coding: UTF-8 -*-
from FQ.src.db import dbutils


class DBFundQuant:

    def __init__(self):
        self.db = dbutils.MysqlConn('dbfundquant')
        self.db.open()

    def __del__(self):
        self.db.close()

    def insertFundCompany(self, companies: list):
        # print(companies)
        if len(companies) == 0:
            return 0
        i = 0
        values = []
        sql = "INSERT INTO fundcompany(company_shortname,company_code,company_name,company_setupdate) VALUES(%s,%s,%s,%s)"
        for company in companies:
            i = i + 1
            values.append(company)
            """50笔插一次"""
            if i % 50 == 0:
                # print(sql)
                iRet = self.db.executemany(sql, values)
                if iRet != 0:
                    return iRet
                values = []
        # print(sql)
        iRet = self.db.executemany(sql, values)
        return iRet

    def insertFundinfo(self, company: str, funds: list):
        i = 0
        values = []
        sql = "INSERT INTO fundinfo(company_code,fund_name,fund_code) VALUES(%s,%s,%s)"
        for fund in funds:
            i = i + 1
            values.append(tuple(company) + fund)
            """50笔插一次"""
            if i % 50 == 0:
                # print(values)
                iRet = self.db.executemany(sql, values)
                if iRet != 0:
                    return iRet
                values = []
        # print(sql)
        # print(values)
        iRet = self.db.executemany(sql, values)
        return iRet

    def insertFundday(self, fundday: tuple, page: int):
        """第一页且不足49条代表startdate有值，行情里有历史数据，可能有重复，需要判断，耗时较长"""
        if page == 1 and len(fundday) != 49:
            addfundday = []
            for fd in fundday:
                sql = "select count(1) from fundday where fund_code = '%s' and date = '%s'" % (fd[0], fd[1])
                iexists = self.db.execSql(sql, False)[0][0]
                if iexists == 0:
                    addfundday.append(fd)
        else:
            addfundday = fundday
        sql = "INSERT INTO fundday(fund_code,date,netvalue,totalvalue,substatus,rdmstatus,bonus) VALUES(%s,%s,%s,%s,%s,%s,%s)"
        iRet = self.db.executemany(sql, addfundday)
        return iRet

    def insertFunddayAudit(self, funddayaudits: tuple):
        i = 0
        values = []
        sql = "INSERT INTO funddayaudit(fund_code,funddayrecords) VALUES(%s,%s)"
        for funddayaudit in funddayaudits:
            i = i + 1
            values.append(funddayaudit)
            """50笔插一次"""
            if i % 50 == 0:
                iRet = self.db.executemany(sql, values)
                if iRet != 0:
                    return iRet
                values = []
        iRet = self.db.executemany(sql, values)
        return iRet

# company1 = DBFundQuant()
# # company1.insertFundCompany()
# company1.insertFundinfo(['80000223'], [('嘉实优质精选混合C', '010276'), ('嘉实优质精选混合A', '010275')])
#
#
# company1.insertFundday([('001631', '2020-10-15', '3.0137', '3.0918', '开放申购', '开放赎回'), ('001631', '2020-10-14', '3.0227', '3.1008', '开放申购', '开放赎回'), ('001631', '2020-10-13', '3.0320', '3.1101', '开放申购', '开放赎回'), ('001631', '2020-10-12', '3.0156', '3.0937', '开放申购', '开放赎回'), ('001631', '2020-10-09', '2.9075', '2.9856', '开放申购', '开放赎回')])
