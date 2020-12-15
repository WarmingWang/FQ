# -*- coding: UTF-8 -*-
from src.db import dbutils


class DBFundQuant:

    def __init__(self):
        self.db = dbutils.MysqlConn('dbfundquant')
        self.db.open()

    def __del__(self):
        self.db.close()

    def insertFundCompany(self, companies: list):
        # print(companies)

        i = 0
        values = []
        sql = "INSERT INTO fundcompany(company_shortname,company_code,company_name,company_setupdate) VALUES(%s,%s,%s,%s)"
        for company in companies:
            i = i + 1
            values.append(company)
            """50笔插一次"""
            if i % 50 == 0:
                # print(sql)
                self.db.executemany(sql, values)
                values = []
        # print(sql)
        self.db.executemany(sql, values)
        return 0

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
                self.db.executemany(sql, values)
                values = []
        # print(sql)
        # print(values)
        self.db.executemany(sql, values)
        return 0

    def insertFundday(self, fundday: tuple):
        sql = "INSERT INTO fundday(fund_code,date,netvalue,totalvalue,substatus,rdmstatus) VALUES(%s,%s,%s,%s,%s,%s)"
        # print(sql)
        print(fundday)
        # self.db.executemany(sql, fundday)
        return 0


# company1 = DBFundQuant()
# # company1.insertFundCompany()
# company1.insertFundinfo(['80000223'], [('嘉实优质精选混合C', '010276'), ('嘉实优质精选混合A', '010275')])
#
#
# company1.insertFundday([('001631', '2020-10-15', '3.0137', '3.0918', '开放申购', '开放赎回'), ('001631', '2020-10-14', '3.0227', '3.1008', '开放申购', '开放赎回'), ('001631', '2020-10-13', '3.0320', '3.1101', '开放申购', '开放赎回'), ('001631', '2020-10-12', '3.0156', '3.0937', '开放申购', '开放赎回'), ('001631', '2020-10-09', '2.9075', '2.9856', '开放申购', '开放赎回')])
