--查看分区信息
select
  partition_name part,
  partition_expression expr,
  partition_description descr,
  table_rows
from information_schema.partitions  where
  table_schema = schema()
  and table_name='fundday';

--解决创建function报错问题
--  This function has none of DETERMINISTIC, NO SQL, or READS SQL DATA in its declaration and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)
show variables like '%log_bin_trust_function_creators%';
set global log_bin_trust_function_creators = 1;

-- 缓冲池(1206, 'The total number of locks exceeds the lock table size')
show variables like '%innodb_buffer_pool_size%'
set GLOBAL innodb_buffer_pool_size=2147483648;
