# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

import time

from tqdm import tqdm
from FQ.src.utils import utils
from FQ.src.db import dbutils
from FQ.src.db import dbfundquant
from FQ.src.crawler import downloadfromtt
from multiprocessing import Process, Pool


def get1fundday(fundcode: str):
    dl = downloadfromtt.DownloadFromTT()
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    """首次下载失败后需要重新下载"""
    sql = "select count(1) from fundinfo where fund_code = '%s' and lastupdate is null" % fundcode
    iCount = db.execSql(sql, False)[0][0]
    if iCount == 1:
        sql = "delete from fundday where fund_code = '%s'" % fundcode
        db.execSql(sql, False)

    sql = "select max(date) from fundday where fund_code = '%s'" % fundcode
    sdate = db.execSql(sql, False)[0][0]
    if sdate == None:
        iRet = dl.getfundday(fundcode)
        if iRet != 0:
            return iRet
    else:
        iRet = dl.getfundday(fundcode, str(sdate))
        if iRet != 0:
            return iRet

    """更新fundinfo的lastupdate"""
    sql = "update fundinfo set lastupdate = '%s' where fund_code = '%s'" % (
        utils.getCurDate(), fundcode)
    try:
        db.execSql(sql, False)
    except:
        return -1


"""
下载基金对应的行情信息到数据库
"""


def exec_fundday():
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    pool = Pool(8)  # 创建一个8个进程的进程池
    try:
        sql = "select fund_code from fundinfo where IFNULL(lastupdate,'') <> '%s' order by company_code,fund_code" % utils.getCurDate()
        funds = db.execSql(sql, False)
        # ------------- 配置好进度条 -------------
        pbar = tqdm(total=len(funds))
        pbar.set_description("下载更新fundday：  {}".format(time.strftime('%Y-%m-%d %H:%M:%S')))
        update = lambda *args: pbar.update()
        # --------------------------------------
        for fund in funds:
            pool.apply_async(func=get1fundday, args=(str(fund[0]),), callback=update)  # 通过callback来更新进度条
    finally:
        pool.close()
        pool.join()
        db.close()

    return 0


def exec_fundquant():
    dl = downloadfromtt.DownloadFromTT()
    dbfq = dbfundquant.DBFundQuant()

    """网页抓取数据库中没有的基金公司"""
    companies = dl.downloadfundcompany()
    """基金公司到数据库"""
    iRet = dbfq.insertFundCompany(companies)
    if iRet != 0:
        return iRet

    """从数据库获取所有基金公司,抓取基金到数据库"""
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    try:
        sql = "select company_code from fundcompany where IFNULL(lastupdate,'') <> '%s' order by company_code" % utils.getCurDate()
        companies = db.execSql(sql, False)
        companies = tqdm(companies)
        if companies.total > 0:
            for company in companies:
                companies.set_description("下载更新fundinfo：{}".format(company))
                """通过基金抓取对应的开放式基金"""
                funds = dl.openfundincompany(company[0])
                iRet = dbfq.insertFundinfo(company, funds)
                if iRet != 0:
                    return iRet

                """更新fundcompany的lastupdate"""
                sql = "update fundcompany set lastupdate = '%s' where company_code = '%s'" % (
                    utils.getCurDate(), company[0])
                db.execSql(sql, False)
    finally:
        db.close()

    """下载基金对应的行情信息到数据库"""
    iRet = exec_fundday()
    if iRet != 0:
        return iRet

    return 0


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    i = 0
    while 1:
        if exec_fundquant() != 0:
            i += 1
            if i >= 5:
                break
            utils.logger.error("exec_fundquant failed %d times! 300 seconds after re-execution", i)
            time.sleep(300)
        else:
            break
    if i >= 5:
        print("exec_fundquant failed!")
    else:
        print("exec_fundquant success!")
