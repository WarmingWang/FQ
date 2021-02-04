# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

import xlwings as xw

wb = xw.Book()
sht = wb.sheets[0]
info_list = [['20190001','已揽收','凯撒邮局'],
['20190001','已发货','凯撒邮局'],
['20192288','已揽收','麻花镇邮局'],
['20192288','已发货','麻花镇邮局'],
['20192288','正在派送','阿里山']]

titles = [['包裹号','状态','地点']]
sht.range('a1').value = titles
sht.range('a2').value = info_list
wb.save('Track.xlsx')


# app = xw.App(visible=True, add_book=False)
# #新建工作簿 (如果不接下一条代码的话，Excel只会一闪而过，卖个萌就走了）
# wb = app.books.add()