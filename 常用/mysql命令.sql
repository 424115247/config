-- 当前打开的连接的数量。
show status like '%Threads_connected%';
-- 查看数据库状态如下
show status like 'thread%';
-- 最大连接数
show variables like '%max_connections%'; 
-- 当前连接数
show full processlist;
-- 查看慢SQL日志是否启用
show variables like 'slow_query_log'; 
-- 查看执行慢于多少秒的SQL会记录到日志文件中
show variables like 'long_query_time';
-- 打开日志记录
set global slow_query_log='ON';
-- 关闭sql执行记录
set global slow_query_log='OFF';
-- 查询慢日志相关信息
SHOW VARIABLES LIKE '%query%' ;
-- 查看慢查询状态 有问题
SHOW STATUS LIKE '%slow_queries%';
-- 测试生成log
select sleep(2);