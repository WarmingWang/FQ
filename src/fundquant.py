# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

import time

from tqdm import tqdm
from FQ.src.utils import utils
from FQ.src.db import dbutils
from FQ.src.db import dbfundquant
from FQ.src.crawler import downloadfromtt
from FQ.src.audit import audit
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


def download_fundday():
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


def download_all():
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
    iRet = download_fundday()
    if iRet != 0:
        return iRet

    return 0

def loadFundQuant():
    """下载所有记录"""
    i = 0
    while 1:
        if download_all() != 0:
            i += 1
            if i >= 5:
                break
            utils.logger.error("download_all failed %d times! 300 seconds after re-execution", i)
            time.sleep(300)
        else:
            break
    if i >= 5:
        print("download_all failed!")
        return -1
    else:
        print("download_all success!")
        return 0

def auditFundQuant():
    """稽核"""
    iAudit = 0  #稽核次数
    while 1:
        iRet = 0
        aud = audit.Audit()
        fdas = aud.funddayaudit(iAudit)
        iCount = len(fdas)
        if iCount > 0:
            print("有%d只基金行情稽核失败！    基金代码,实际数量,fundday表数量\n%s" % (iCount, fdas))
            iAudit += 1
            if iAudit >= 2:
                iRet = -1
                break
            wheresql = ''
            i = 0
            for fda in fdas:
                if i == 0:
                    wheresql = utils.quotedstr(fda[0])
                    i += 1
                else:
                    wheresql = wheresql + ',' + utils.quotedstr(fda[0])
            """更新稽核失败的基金lastupdate为null"""
            sql = "update fundinfo set lastupdate = null where fund_code in (%s)" % wheresql
            try:
                db = dbutils.MysqlConn('dbfundquant')
                db.open()
                db.execSql(sql, False)
            finally:
                db.close()
            """重新下载"""
            iRet1 = loadFundQuant()
            if iRet1 != 0:
                return iRet1
        else:
            print("行情稽核成功！")
            break
    return iRet

def statYieldByComp(companycode: str):
    """按公司维度统计区间收益表"""
    try:
        db = dbutils.MysqlConn('dbfundquant')
        db.open()
        """生成区间收益率"""
        db.callproc("Gen_intervalyields", companycode)
    except:
        return -1
    finally:
        db.close()
    return 0

def afterStat():
    """统计信息"""
    db = dbutils.MysqlConn('dbfundquant')
    db.open()
    pool = Pool(8)  # 创建一个8个进程的进程池
    try:
        """清空区间收益表intervalyields"""
        db.execSql("truncate table intervalyields", False)

        sql = "select company_code from fundcompany where lastupdate = '%s' order by company_code" % utils.getCurDate()
        companies = db.execSql(sql, False)
        if len(companies) <= 0:
            return 0
        # ------------- 配置好进度条 -------------
        pbar = tqdm(total=len(companies))
        pbar.set_description("区间收益统计intervalyields：  {}".format(time.strftime('%Y-%m-%d %H:%M:%S')))
        update = lambda *args: pbar.update()
        # --------------------------------------
        for company in companies:
            # statYieldByComp(str(company[0]))
            pool.apply_async(func=statYieldByComp, args=(str(company[0]),), callback=update)  # 通过callback来更新进度条
    finally:
        pool.close()
        pool.join()
        db.close()
    return 0

# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    """下载"""
    loadFundQuant()
    """稽核"""
    auditFundQuant()
    """统计"""
    afterStat()
