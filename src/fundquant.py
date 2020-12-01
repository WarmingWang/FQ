# -*- coding: UTF-8 -*-

__author__ = "WarmingWang"

from src.crawler import downloadfromtt
from src.db import dbutils


def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print("Hi, {0}".format(name))  # Press Ctrl+F8 to toggle the breakpoint.

    db = dbutils.MysqlConn('dbfundquant')
    db.open()

    x = downloadfromtt.DownloadFromTT()
    companies = x.downloadfundcompany()
    # print(companies)

    i = 0
    values = []
    sql = "INSERT INTO fundcompany(company_shortname,company_tturl,company_name,company_setupdate) VALUES(%s,%s,%s,%s)"
    for company in companies:
        i = i + 1
        values.append(company)
        if i % 50 == 0:
            db.executemany(sql, values)
            values = []
    db.executemany(sql, values)

    db.close()



    print(x.downloadfundinfo())
    print(x.downloadfundday())


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

# fundQuant主入口
# 爬天天基金的数据写到mysql数据库中（downloadfromtt;）
