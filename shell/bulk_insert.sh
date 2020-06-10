#!/bin/bash
user=XXX
host=XXX
port=XXX
password=XXX

if [ ! -x /usr/bin/jq ];then
    yum -y install jq
fi
nginx_dir=/var/log/nginx/access.log
date_time=`date '+%d/%b/%Y:%H:%M' -d '-1 min'`
#date_time="09/Jun/2020:07:20:57"
date_now=`date '+%Y-%m-%d'`
status_run="200"
grep "$date_time" $nginx_dir | while read line
do
    run_status=$(echo $line | jq .run_status|tr -d "\"")
    if [[ $run_status != 200 ]];then
        http_host=$(echo $line | jq .http_host)
        access_ip=$(echo $line | jq .access_ip)
        access_time=$(echo $line | jq .access_time)
        run_status=$(echo $line | jq .run_status)
        req_url=$(echo $line | jq .req_url)
        http_referer=$(echo $line | jq .http_referer)
        http_agent=$(echo $line | jq .http_agent)
        /usr/bin/mysql -h$host -P$port -u$user -p$password -e "INSERT INTO nginx_log.nginx_log (http_host,access_ip,access_time,run_status,req_url,http_referer,http_agent) VALUES ('$http_host','$access_ip','$access_time','$run_status','$req_url','$http_referer','$http_agent');"
    fi
done
echo "finish"
