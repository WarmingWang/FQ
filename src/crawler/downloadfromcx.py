# -*- coding: UTF-8 -*-
__author__ = "WarmingWang"

import time
import math
from selenium import webdriver
from FQ.src.utils import utils


class DownloadFromCX:
    URL_HOME = 'https://www.morningstar.cn/quickrank/default.aspx'

    # 模拟登录
    def logincx(self):
        global browser
        browser = webdriver.Chrome()

        # 只加载10s
        browser.set_page_load_timeout(8)
        try:
            browser.get(self.URL_HOME)
        except Exception:
            time.sleep(5)
            browser.execute_script('window.stop()')
        # 模拟用户登录
        browser.find_element_by_id('emailTxt').send_keys('')#email
        browser.find_element_by_id('pwdValue').send_keys('')#psw
        browser.find_element_by_id('txtCheckCode').send_keys('')
        # time.sleep(8)
        while 1:
            try:
                browser.find_element_by_id('emailTxt')  #等待手工登陆
            except:
                break
        time.sleep(2)
        browser.execute_script('window.stop()')

    def downfundinfo(self):
        fundnum = int(browser.find_element_by_id('ctl00_cphMain_TotalResultLabel').text)
        pages = math.floor(fundnum / 25)
        for page in range(pages):
            try:
                next_page = browser.find_element_by_link_text('>')
                next_page.click()

            except Exception:
                browser.execute_script('window.stop()')

    def get1pagefund(self):
        # num = int(browser.find_element_by_id('ctl00_cphMain_gridResult_ctl17_lblRowNo').text)

        # table = browser.find_element_by_id('ctl00_cphMain_gridResult')
        items = browser.find_elements_by_xpath('//table[@id= "ctl00_cphMain_gridResult"]//tr[contains(@class, "gridItem") or contains(@class, "gridAlternateItem")]')
        for idx, item in enumerate(items):
            num = int(item.find_element_by_id('ctl00_cphMain_gridResult_ctl'+str(idx+2).rjust(2, '0')+'_lblRowNo').text)
            print(num)
            xx = item.find_elements_by_class_name("msDataText")
            for _ in xx:
                print(_.text)
            # print(item.text)
        # tds = table.find_elements_by_tag_name('a')
        # for i in range(len(tds)):
        #     # print(tds[i].get_attribute('href'))
        #     print(tds[i].text)
        # # a_hrefs_du = [tds[i].get_attribute('href') for i in range(len(tds))]


cx = DownloadFromCX()
cx.logincx()
# cx.downfundinfo()
cx.get1pagefund()