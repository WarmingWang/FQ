# -*- coding: UTF-8 -*-
import pymysql
import logging

logger = logging.getLogger(__name__)  # 操作日志对象
logging.basicConfig(level=logging.ERROR)


class MysqlConn:
    """
    数据库连接的公共类，提供连接数据库，查询，删除语句等操作
    """

    def __init__(self, dbName=None):
        self.currentConn = None
        self.host = "localhost"#192.168.210.128
        self.user = "fqrun"
        self.password = "fqrun"
        self.dbName = dbName
        self.charset = "utf8"
        self.resultlist = []

    def open(self):
        try:
            conn = pymysql.connect(
                host=self.host,
                user=self.user,
                password=self.password,
                db=self.dbName,
                charset=self.charset,
            )
        except pymysql.err.OperationalError as e:
            logger.exception("数据库连接失败！")
            if "Errno 10060" in str(e) or "2003" in str(e):
                logger.error("数据库连接失败！")
            raise
        # logger.info('数据库连接成功')
        self.currentConn = conn  # 数据库连接完成
        # self.cursor = self.currentConn.cursor()  # 游标，用来执行数据库

    def execSql(self, sql: str, closeConn=True) -> list:
        '''执行sql'''
        if closeConn:
            self.open()
        # logger.info("开始执行sql语句")
        self.cursor = self.currentConn.cursor()
        with self.cursor as my_cursor:
            my_cursor.execute(sql)  # 执行sql语句
            self.resultlist = my_cursor.fetchall()  # 获取数据
            self.currentConn.commit()  # 提交
        if self.currentConn:
            if closeConn:
                self.close()
        return self.resultlist

    def executemany(self, sql: str, values: tuple):
        """"""
        try:
            self.cursor = self.currentConn.cursor()
            with self.cursor as my_cursor:
                my_cursor.executemany(sql, values)
                self.currentConn.commit()
        except Exception as e:
            logger.exception(e)
            logger.exception('sql:'+sql+'values:'+str(values))
            self.currentConn.rollback()
            return -1
        return 0

    def close(self):  # 关闭连接
        # logger.info("关闭数据库连接")
        if self.currentConn.cursor():
            self.currentConn.cursor().close()
        self.currentConn.close()



# db = MysqlConn("dbfundquant")
# db.open()
# print(db.execSql("SELECT VERSION()", False))
# db.close()


# sql = "INSERT INTO fundcompany(company_shortname,company_code,company_name,company_setupdate) VALUES(%s,%s,%s,%s)"
# values = [('THJJ', '80041198', '天弘基金管理有限公司', '2004-11-08'), ('YFDJJ', '80000229', '易方达基金管理有限公司', '2001-04-17')]
# db = MysqlConn("dbfundquant")
# db.open()
# db.executemany(sql, values)
# db.close()
