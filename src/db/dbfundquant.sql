/*
 Navicat Premium Data Transfer

 Source Server         : fundquant
 Source Server Type    : MySQL
 Source Server Version : 80019
 Source Host           : localhost:3306
 Source Schema         : dbfundquant

 Target Server Type    : MySQL
 Target Server Version : 80019
 File Encoding         : 65001

 Date: 04/02/2021 22:27:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for fundcompany
-- ----------------------------
DROP TABLE IF EXISTS `fundcompany`;
CREATE TABLE `fundcompany`  (
  `company_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `company_shortname` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `company_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `company_englishname` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_tel` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_address` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_website` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_setupdate` date NULL DEFAULT NULL,
  `lastupdate` date NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fundday
-- ----------------------------
DROP TABLE IF EXISTS `fundday`;
CREATE TABLE `fundday`  (
  `fund_code` varchar(6) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `date` date NOT NULL,
  `netvalue` double(16, 8) NULL DEFAULT NULL,
  `totalvalue` double(16, 8) NULL DEFAULT NULL,
  `substatus` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `rdmstatus` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`fund_code`, `date`) USING BTREE,
  UNIQUE INDEX `IFUNDDAY_DATE_FUNDCODE`(`date`, `fund_code`) USING BTREE,
  INDEX `IFUNDDAY_FUNDCODE_DATE`(`fund_code`, `date`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic PARTITION BY RANGE (year(`date`))
PARTITIONS 3
(PARTITION `p0` VALUES LESS THAN (2016) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 ,
PARTITION `p1` VALUES LESS THAN (2019) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 ,
PARTITION `p2` VALUES LESS THAN (MAXVALUE) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 )
;

-- ----------------------------
-- Table structure for funddayaudit
-- ----------------------------
DROP TABLE IF EXISTS `funddayaudit`;
CREATE TABLE `funddayaudit`  (
  `fund_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `funddayrecords` int(0) NULL DEFAULT NULL,
  UNIQUE INDEX `fund_code`(`fund_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fundinfo
-- ----------------------------
DROP TABLE IF EXISTS `fundinfo`;
CREATE TABLE `fundinfo`  (
  `company_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `fund_code` varchar(6) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `fund_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `fund_trusteecode` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fund_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fund_manager` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fund_setupdate` date NULL DEFAULT NULL,
  `fund_asset` double(16, 2) NULL DEFAULT NULL,
  `lastupdate` date NULL DEFAULT NULL,
  UNIQUE INDEX `IFUNDINFO_FUNDCODE`(`fund_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for intervalyields
-- ----------------------------
DROP TABLE IF EXISTS `intervalyields`;
CREATE TABLE `intervalyields`  (
  `fund_code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金代码',
  `yield_1w` double(16, 8) NULL DEFAULT NULL COMMENT '近1周收益率',
  `yield_1m` double(16, 8) NULL DEFAULT NULL COMMENT '近1月收益率',
  `yield_3m` double(16, 8) NULL DEFAULT NULL COMMENT '近3月收益率',
  `yield_6m` double(16, 8) NULL DEFAULT NULL COMMENT '近6月收益率',
  `yield_1y` double(16, 8) NULL DEFAULT NULL COMMENT '近1年收益率',
  `yield_3y` double(16, 8) NULL DEFAULT NULL COMMENT '近3年收益率',
  `yield_5y` double(16, 8) NULL DEFAULT NULL COMMENT '近5年收益率',
  `yield_all` double(16, 8) NULL DEFAULT NULL COMMENT '自成立来收益率',
  PRIMARY KEY (`fund_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Procedure structure for Gen_intervalyields
-- ----------------------------
DROP PROCEDURE IF EXISTS `Gen_intervalyields`;
delimiter ;;
CREATE DEFINER=`fqrun`@`localhost` PROCEDURE `Gen_intervalyields`(IN v_companycode varchar(8))
BEGIN
  #Routine body goes here...
  insert into intervalyields(fund_code,yield_all,yield_5y,yield_3y,yield_1y,yield_6m,yield_3m,yield_1m,yield_1w)
  select a.fund_code,a.yield_all,
         IFNULL(b.yield_5y, 0) yield_5y,
         IFNULL(c.yield_3y, 0) yield_3y,
         IFNULL(d.yield_1y, 0) yield_1y,
         IFNULL(e.yield_6m, 0) yield_6m,
         IFNULL(f.yield_3m, 0) yield_3m,
         IFNULL(g.yield_1m, 0) yield_1m,
         IFNULL(h.yield_1w, 0) yield_1w
    from (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_all
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) a
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_5y
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) b
         on a.fund_code = b.fund_code
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_3y
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) c
         on a.fund_code = c.fund_code
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_1y
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) d
         on a.fund_code = d.fund_code
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_6m
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) e
         on a.fund_code = e.fund_code
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_3m
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) f
         on a.fund_code = f.fund_code
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_1m
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) g
         on a.fund_code = g.fund_code
         left join
         (select fund_code,(nexttotalvalue-totalvalue)/netvalue*100 yield_1w
            from (select fund_code,netvalue,totalvalue,lag(totalvalue,1) over(partition by fund_code ORDER BY date DESC) nexttotalvalue
                    from (select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date) a) a
                           where rownum = 1
                          union all
                          select a.fund_code,a.date,a.netvalue,a.totalvalue
                            from (select a.fund_code,a.date,a.netvalue,a.totalvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.date,a.netvalue,a.totalvalue
                                            from fundday a,fundinfo b
                                           where a.date >= DATE_SUB(CURDATE(), INTERVAL 1 WEEK)
                                             and a.fund_code = b.fund_code
                                             and b.company_code = v_companycode
                                           order by fund_code,date desc) a) a
                           where rownum = 1) a) a
           where a.nexttotalvalue is not null) h
         on a.fund_code = h.fund_code;
  COMMIT;
END
;;
delimiter ;

-- ----------------------------
-- Function structure for getyield
-- ----------------------------
DROP FUNCTION IF EXISTS `getyield`;
delimiter ;;
CREATE DEFINER=`fqrun`@`localhost` FUNCTION `getyield`(fundcode VARCHAR(6), begindate date, enddate date) RETURNS double(16,8)
begin
    declare yield double(16,8);
    select (nexttotalvalue-totalvalue)/netvalue*100 into yield
      from (select netvalue,totalvalue,lag(totalvalue,1) over(ORDER BY date DESC) nexttotalvalue
              from ((select date,netvalue,totalvalue from fundday where fund_code = fundcode and date >= begindate and date <= enddate LIMIT 1)
                     union all
                    (select date,netvalue,totalvalue from fundday where fund_code = fundcode and date >= begindate and date <= enddate ORDER BY date desc LIMIT 1)
                   )a
           )a
     where a.nexttotalvalue is not null;
    return yield;
end
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
