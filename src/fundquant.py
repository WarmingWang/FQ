# -*- coding: UTF-8 -*-

__author__ = "WarmingWang"

import downloadfromtt

def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print("Hi, {0}".format(name))  # Press Ctrl+F8 to toggle the breakpoint.
    x = downloadfromtt.DownloadFromTT()
    print(x.downloadfundcompany())
    print(x.downloadfundinfo())
    print(x.downloadfundday())


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

#fundQuant主入口
#爬天天基金的数据写到mysql数据库中（downloadFundinfo.py;downloadFundday.py）



