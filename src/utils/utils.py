# -*- coding: UTF-8 -*-

import gzip
import datetime
import logging

logger = logging.getLogger(__name__)  # 操作日志对象
logging.basicConfig(level=logging.DEBUG)
"""
解压
"""


def ungzip(data):
    try:  # 尝试解压
        # print('正在解压.....')
        data = gzip.decompress(data)
        # print('解压完毕!')
    except:
        print('未经压缩, 无需解压')
    return data


"""
YYYYMMDD -> YYYY-MM-DD
"""


def strToDate(date: str):
    if len(date) != 8:
        logger.exception("错误的日期字符串！%s", date)
    try:
        int(date)
    except Exception as e:
        logger.exception("错误的日期字符串！%s", date)
        logger.exception(e)
    return date[0:4] + '-' + date[4:6] + '-' + date[6:8]


"""
获取当前日期YYYY-MM-DD
"""


def getCurDate():
    return datetime.datetime.today().strftime('%Y-%m-%d')



# date = strToDate('20100514')
# print(date)

# getCurDate()

