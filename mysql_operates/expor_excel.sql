#This is a sample example for xls formart
select * into outfile '/var/lib/mysql-files/outfile.xls' 
from (
select 
CONVERT(('编号') USING gbk),
CONVERT(('名字') USING gbk),
CONVERT(('网址') USING gbk),
CONVERT(('数值') USING gbk),
CONVERT(("国家") USING gbk) #写表头并且修改为gbk格式，支持中文
UNION 
select 
id,
CONVERT((name) USING gbk),
CONVERT((url) USING gbk),
CONVERT((alexa) USING gbk),
CONVERT((country) USING gbk),
from Websites) b;#查询的数据
##############################################
#This is a sample example for csv formart
select * into outfile '/var/lib/mysql-files/outfile.csv' 
fields terminated by ','  #设定分隔符，excel表格中自动匹配
from (
select 
CONVERT(('编号') USING gbk),
CONVERT(('名字') USING gbk),
CONVERT(('网址') USING gbk),
CONVERT(('数值') USING gbk),
CONVERT(("国家") USING gbk) #写表头并且修改为gbk格式，支持中文
UNION 
select 
id,
CONVERT((name) USING gbk),
CONVERT((url) USING gbk),
CONVERT((alexa) USING gbk),
CONVERT((country) USING gbk),
from Websites) b;#查询的数据
