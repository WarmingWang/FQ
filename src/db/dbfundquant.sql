/*
 Navicat Premium Data Transfer

 Source Server         : fundquant
 Source Server Type    : MySQL
 Source Server Version : 50732
 Source Host           : 192.168.210.128:3306
 Source Schema         : dbfundquant

 Target Server Type    : MySQL
 Target Server Version : 50732
 File Encoding         : 65001

 Date: 28/12/2020 23:30:25
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for fundcompany
-- ----------------------------
DROP TABLE IF EXISTS `fundcompany`;
CREATE TABLE `fundcompany`  (
  `company_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `company_shortname` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `company_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `company_englishname` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_tel` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_address` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_website` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `company_setupdate` date NULL DEFAULT NULL,
  `lastupdate` date NULL DEFAULT NULL,
  PRIMARY KEY (`company_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 161 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fundday
-- ----------------------------
DROP TABLE IF EXISTS `fundday`;
CREATE TABLE `fundday`  (
  `fund_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `date` date NULL DEFAULT NULL,
  `netvalue` double(16, 8) NULL DEFAULT NULL,
  `totalvalue` double(16, 8) NULL DEFAULT NULL,
  `substatus` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `rdmstatus` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for fundinfo
-- ----------------------------
DROP TABLE IF EXISTS `fundinfo`;
CREATE TABLE `fundinfo`  (
  `fund_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_code` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `fund_code` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `fund_name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `fund_trusteecode` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fund_type` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fund_manager` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `fund_setupdate` date NULL DEFAULT NULL,
  `fund_asset` double(16, 2) NULL DEFAULT NULL,
  `lastupdate` date NULL DEFAULT NULL,
  PRIMARY KEY (`fund_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9988 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
