# -*- coding: UTF-8 -*-

import gzip
import time
import json
import random
import datetime
import logging
import requests
import urllib.request
from urllib.request import urlopen, Request

logger = logging.getLogger(__name__)  # 操作日志对象
logging.basicConfig(level=logging.ERROR)

headers = {
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36 Edg/87.0.664.60'
}

def get_urlopen(url_home, ret_type=''):
    i = 0
    while 1:
        try:
            # html = getHtml(url_home, headers=headers)
            html = urlopen(Request(url_home, headers=headers)).read()
            break
        except:
            i += 1
            if i >= 5:
                logger.error('访问失败%d次，请检查！', i)
                return []
            logger.debug('访问失败%d次，1-5秒后尝试再次连接', i)
            time.sleep(random.randint(1, 5))
            continue
    if ret_type == 'json':
        return json.loads(ungzip(html).decode('utf-8'))
    elif ret_type == 'pic':
        return html
    else:
        return ungzip(html).decode('utf-8')

"""
解压
"""


def ungzip(data):
    try:  # 尝试解压
        # print('正在解压.....')
        data = gzip.decompress(data)
        # print('解压完毕!')
    except:
        pass
        # print('未经压缩, 无需解压')
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


def getCurDate() -> str:
    return datetime.datetime.today().strftime('%Y-%m-%d')


def quotedstr(S) -> str:
    return '\'' + S + '\''


def get_proxy():
    return requests.get("http://127.0.0.1:5010/get/").json()


def delete_proxy(proxy):
    requests.get("http://127.0.0.1:5010/delete/?proxy={}".format(proxy))


def getHtml(url, headers):
    retry_count = 5
    while retry_count > 0:
        try:
            proxy = get_proxy().get("proxy")
            httpproxy_handler = urllib.request.ProxyHandler({"http": "http://{}".format(proxy)})
            opener = urllib.request.build_opener(httpproxy_handler)
            request = urllib.request.Request(url, headers=headers)
            response = opener.open(request)
            html = response.read()
            # print(html)
            # proxies = {"http": "http://{}".format(proxy)}
            # print(proxies)
            # html = urlopen(url, headers=headers, ).read()
            # html = requests.get('http://www.example.com', proxies={"http": "http://{}".format(proxy)})
            # 使用代理访问
            return html
        except Exception:
            retry_count -= 1
    # 删除代理池中代理
    delete_proxy(proxy)
    return None
# date = strToDate('20100514')
# print(date)
# getCurDate()

# headers = {
#     'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
#     'Accept-Encoding': 'gzip, deflate',
#     'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
#     'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36 Edg/87.0.664.60'
# }
# html = getHtml('http://fund.eastmoney.com/company',headers)
# html = ungzip(html).decode('utf-8')
# print(html)

# ss = getCurDate()
# print(ss)
