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

 Date: 20/02/2021 16:18:10
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
  `ratio` double(16, 8) NULL DEFAULT NULL,
  `substatus` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `rdmstatus` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `bonus` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
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
CREATE DEFINER=`fqrun`@`localhost` PROCEDURE `Gen_intervalyields`(IN v_companycode varchar(8), IN v_enddate date)
BEGIN
  #Routine body goes here...
  insert into intervalyields(fund_code,yield_all,yield_5y,yield_3y,yield_1y,yield_6m,yield_3m,yield_1m,yield_1w)
  with v_fundday as
  (select a.fund_code,a.date,a.netvalue,a.bonus
     from fundday a,fundinfo b
    where a.fund_code = b.fund_code
      and b.company_code = v_companycode
      and a.date <= v_enddate)

  select a.fund_code,a.yield_all,
         IFNULL(b.yield_5y, 0) yield_5y,
         IFNULL(c.yield_3y, 0) yield_3y,
         IFNULL(d.yield_1y, 0) yield_1y,
         IFNULL(e.yield_6m, 0) yield_6m,
         IFNULL(f.yield_3m, 0) yield_3m,
         IFNULL(g.yield_1m, 0) yield_1m,
         IFNULL(h.yield_1w, 0) yield_1w
    from (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_all
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) a
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_5y
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 5 YEAR) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 5 YEAR) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 5 YEAR)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) b
         on a.fund_code = b.fund_code
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_3y
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 3 YEAR) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 3 YEAR) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 3 YEAR)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) c
         on a.fund_code = c.fund_code
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_1y
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 1 YEAR) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 1 YEAR) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 1 YEAR)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) d
         on a.fund_code = d.fund_code
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_6m
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 6 MONTH) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 6 MONTH) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 6 MONTH)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) e
         on a.fund_code = e.fund_code
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_3m
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 3 MONTH) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 3 MONTH) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 3 MONTH)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) f
         on a.fund_code = f.fund_code
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_1m
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 1 MONTH) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 1 MONTH) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 1 MONTH)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) g
         on a.fund_code = g.fund_code
         left join
         (select a.fund_code,round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 yield_1w
            from (select a.fund_code,a.netvalue beginnet,b.netvalue endnet
                    from (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 1 WEEK) order by fund_code,date) a) a
                           where rownum = 1) a,
                         (select a.fund_code,a.netvalue
                            from (select a.fund_code,a.netvalue,
                                         case when @fundcode != a.fund_code then @rownum := 1
                                              else @rownum := @rownum + 1
                                              end as rownum,
                                         @fundcode := fund_code
                                    from (select @rownum := 0, @fundcode := "") var,
                                         (select a.fund_code,a.netvalue from v_fundday a where a.date > DATE_SUB(v_enddate, INTERVAL 1 WEEK) order by fund_code,date desc) a) a
                           where rownum = 1) b
                   where a.fund_code = b.fund_code) a
                 LEFT JOIN
                 (select fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                   WHEN bonusflag = '1' THEN bonus
                                                   WHEN bonusflag = '2' THEN bonus
                                                   END))) Ix
                    from (select fund_code,lastnetvalue,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                                      END bonusflag,
                                 CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                                      WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                                      WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                                      END bonus
                            from (select a.fund_code,a.bonus,
                                         lag(a.netvalue,1) over(partition by fund_code ORDER BY date) lastnetvalue
                                    from v_fundday a
                                   where a.date > DATE_SUB(v_enddate, INTERVAL 1 WEEK)) a
                           where LENGTH(trim(bonus))>0) a
                   GROUP BY fund_code) c
                  ON a.fund_code = c.fund_code) h
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
  with v_fundday as
  (select a.fund_code,a.date,a.netvalue,a.bonus
     from fundday a
    where a.fund_code = fundcode
      and a.date <= enddate
		   	and a.date >= begindate)
  select round(a.endnet/a.beginnet* IFNULL(c.Ix,1)-1,4)*100 into yield
    from (select 'xxxxxx' fund_code,a.netvalue beginnet,b.netvalue endnet
            from (select netvalue from v_fundday LIMIT 1) a,
                 (select netvalue from v_fundday ORDER BY date desc LIMIT 1) b
         ) a
         LEFT JOIN
         (select 'xxxxxx' fund_code,EXP(SUM(LN(CASE WHEN bonusflag = '0' THEN (1+bonus/(lastnetvalue-bonus))
                                                    WHEN bonusflag = '1' THEN bonus
                                                    WHEN bonusflag = '2' THEN bonus
                                                    END))) Ix
            from (select lastnetvalue,
                         CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN '0'
                              WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN '1'
                              WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN '2'
                              END bonusflag,
                         CASE WHEN INSTR(bonus,'每份派现金') > 0 THEN REPLACE(REPLACE(bonus,'每份派现金',''),'元','')
                              WHEN INSTR(bonus,'每份基金份额折算') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额折算',''),'份','')
                              WHEN INSTR(bonus,'每份基金份额分拆') > 0 THEN REPLACE(REPLACE(bonus,'每份基金份额分拆',''),'份','')
                              END bonus
                    from (select a.bonus,
                                 lag(a.netvalue,1) over(ORDER BY date) lastnetvalue
                            from v_fundday a) a
                   where LENGTH(trim(bonus))>0) a
         ) c
         ON a.fund_code = c.fund_code;
    return yield;
end
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
