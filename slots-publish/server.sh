#!/usr/bin/env bash

# 初始化环境变量
SLOTS_BIN="${BASH_SOURCE-$0}"
SLOTS_BIN="$(dirname "${SLOTS_BIN}")"
SLOTS_BINDIR="$(cd "${SLOTS_BIN}"; pwd)"

# 初始化脚本配置
if [ -e "$SLOTS_BINDIR/slots_env.sh" ]; then
  . "$SLOTS_BINDIR/slots_env.sh"
fi

# 脚本日志
var_log_file="${SLOTS_BIN}/server.log"
# 开服延迟等待秒数
start_max_try=10
# 关服延迟等待秒数
stop_max_try=10

# 服务类型列表
declare -A service_type_list
service_type_list=()
# 服务列表
declare -A service_app_list
service_app_list=()

# 脚本入口
function main 
{
	# 初始化
	do_init
	# 分发传参
	case $1 in 
		start)      shift; do_start         ${@};;
		stop)       shift; do_stop          ${@};;
		restart)    shift; do_restart       ${@};;
		status)     shift; do_status        ${@};;
		reload)     shift; do_reload        ${@};;
		kill)  		shift; do_kill		    ${@};;
		*)          usage;;
	esac
}


# 脚本说明
function usage {	
	echo "==================帮助=================="
	echo "用法1: server.sh [选项] type [服务类型]"
	echo "用法2: server.sh [选项] [服务]"
	echo "选项说明"
	echo "start     启动服务"
	echo "stop      关闭服务"
	echo "restart   重启服务"
	echo "kill      KILL服务"
}

# 脚本启动初始化
function do_init {
	type_dirs=$(ls -l $SLOTS_CFGDIR |awk '/^d/{print $NF}')
	for type in $type_dirs; do
		service_type_list[$type]=""
		app_path=$SLOTS_CFGDIR/$type
		app_dirs=$(ls -l $app_path |awk '/^d/{print $NF}')
		for app in $app_dirs; do
			service_type_list[$type]="$app ${service_type_list[$type]}"
			service_app_list[$app]=$type
		done
	done
	echo "服务类型列表 = ${!service_type_list[*]}"
	echo "服务列表 = ${!service_app_list[*]}"
	echo ""
}

# 启动服务
function do_start {
	util::is_empty $1 && usage && return 1
	case $1 in
	# 启动所有服务
	all) 
		# 服务启动统计
		total_count=0
		start_count=0
		started_count=0  
		faild_count=0
		for svrid in $(echo ${!service_app_list[*]});do
			stype=${service_app_list[$svrid]}
			service::start $stype $svrid
			result=$?
			let total_count++
			if [ $result -eq 1 ]; then
				let started_count++
			elif [ $result -eq 0 ]; then
				let start_count++
			else
				let faild_count++
			fi
		done
		if [ $faild_count -lt 0 ]; then
			io::log_warn ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$start_count") $(io::yellow "started:$started_count") $(io::red "faild:$faild_count")
		else
			io::log_info ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$start_count") $(io::yellow "started:$started_count") $(io::red "faild:$faild_count")
		fi  
		;;
	# 启动指定类型服务
	type)
		stype=`echo ${@}|awk -F" " '{print $2}'`
		# 服务启动统计
		total_count=0
		start_count=0
		started_count=0  
		faild_count=0
		for svrid in ${service_type_list[$stype]};do
			service::start $stype $svrid
			result=$?
			let total_count++
			if [ $result -eq 1 ]; then
				let started_count++
			elif [ $result -eq 0 ]; then
				let start_count++
			else
				let faild_count++
			fi
		done
		if [ $faild_count -lt 0 ]; then
			io::log_warn ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$start_count") $(io::yellow "started:$started_count") $(io::red "faild:$faild_count")
		else
			io::log_info ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$start_count") $(io::yellow "started:$started_count") $(io::red "faild:$faild_count")
		fi
		;;
	# 启动指定服务
	*)
		svrid=`echo ${@}|awk -F" " '{print $1}'`
		stype=${service_app_list[$svrid]}
		if [ "x$stype" == "x" ]; then
			io::log_warn ${var_log_file} $(io::red "[$svrid] start not found")
		else
			service::start $stype $svrid
		fi
		;;
  esac
}

# 关闭服务
function do_stop {
	util::is_empty $1 && usage && return 1
	case $1 in
	all) 
		# 服务启动统计
		total_count=0
		stop_count=0
		stoped_count=0  
		kill_count=0
		for svrid in $(echo ${!service_app_list[*]});do
			stype=${service_app_list[$svrid]}
			service::stop $stype $svrid
			result=$?
			let total_count++
			if [ $result -eq 1 ]; then
				let stoped_count++
			elif [ $result -eq 0 ]; then
				let stop_count++
			else
				let kill_count++
			fi
		done
		if [ $kill_count -lt 0 ]; then
			io::log_warn ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$stop_count") $(io::yellow "started:$stoped_count") $(io::red "kill:$kill_count")
		else
			io::log_info ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$stop_count") $(io::yellow "started:$stoped_count") $(io::red "kill:$kill_count")
		fi
		;;
	type)
		stype=`echo ${@}|awk -F" " '{print $2}'`
		# 服务启动统计
		total_count=0
		stop_count=0
		stoped_count=0  
		kill_count=0
		for svrid in ${service_type_list[$stype]};do
			service::stop $stype $svrid
			result=$?
			let total_count++
			if [ $result -eq 1 ]; then
				let stoped_count++
			elif [ $result -eq 0 ]; then
				let stop_count++
			else
				let kill_count++
			fi
		done
		if [ $kill_count -lt 0 ]; then
			io::log_warn ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$stop_count") $(io::yellow "started:$stoped_count") $(io::red "kill:$kill_count")
		else
			io::log_info ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$stop_count") $(io::yellow "started:$stoped_count") $(io::red "kill:$kill_count")
		fi
		;;
	*)
		svrid=`echo ${@}|awk -F" " '{print $1}'`
		stype=${service_app_list[$svrid]}
		if [ "x$stype" == "x" ]; then
			io::log_warn ${var_log_file} $(io::red "[$svrid] stop not found")
		else
			service::stop $stype $svrid
		fi
		;;
  esac
}

# 重载服务
function do_reload {
	util::is_empty $1 && usage && return 1
	case $1 in
	all) 
		for svrid in $(echo ${!service_app_list[*]});do
			stype=${service_app_list[$svrid]}
			service::reload $stype $svrid
		done
		;;
	type)
		stype=`echo ${@}|awk -F" " '{print $2}'`
		echo ${service_type_list[$stype]}
		for svrid in ${service_type_list[$stype]};do
			service::reload $stype $svrid
		done
		;;
	*)
		svrid=`echo ${@}|awk -F" " '{print $1}'`
		stype=${service_app_list[$svrid]}
		if [ "x$stype" == "x" ]; then
			io::log_warn ${var_log_file} $(io::red "[$svrid] reload not found")
		else
			service::reload $stype $svrid
		fi
		;;
  esac
}

# Kill服务
function do_kill {
	util::is_empty $1 && usage && return 1
	case $1 in
	all) 
		for svrid in $(echo ${!service_app_list[*]});do
			stype=${service_app_list[$svrid]}
			service::kill $stype $svrid
		done
		;;
	type)
		stype=`echo ${@}|awk -F" " '{print $2}'`
		echo ${service_type_list[$stype]}
		for svrid in ${service_type_list[$stype]};do
			service::kill $stype $svrid
		done
		;;
	*)
		svrid=`echo ${@}|awk -F" " '{print $1}'`
		stype=${service_app_list[$svrid]}
		if [ "x$stype" == "x" ]; then
			io::log_warn ${var_log_file} $(io::red "[$svrid] kill not found")
		else
			service::kill $stype $svrid
		fi
		;;
  esac
}

function do_restart {
  util::is_empty $1 && usage && return 1
  do_stop ${@}
  sleep 5
  do_start ${@}
}

# 获取服务PID
function service::get_pid {
	stype=$1
	svrid=$2
	check_str="app.server.appid=$svrid.*app.server.apptype=$stype"
	pid=$(ps -ef|grep "${check_str}" | grep -v grep | awk '{print $2}')
	echo $pid
}

# 判断服务是否存活
function service::is_alive {
	stype=$1
	svrid=$2
	pid=$(service::get_pid $stype $svrid)
	if [ "x$pid" != "x" ];then			
		return 0
	else
		return 1
	fi
}

# 获取服务JVM配置
function service::get_jvm_param {
	stype=$1
	if [ "x${SERVICE_JVM[$stype]}" != "x" ]; then
		echo ${SERVICE_JVM[$type]}
	else
		echo ${SERVICE_JVM["none"]}
	fi
}

function service::update_jar {
	stype=$1
	jar_name=`ls ${SLOTS_JARDIR} | grep .*${stype}.*jar`
	if [ "x$jar_name" != "x" ]; then
		mv $SLOTS_JARDIR/$jar_name $SLOTS_RUNDIR/$jar_name
	fi
	jar_name=`ls ${SLOTS_RUNDIR} | grep .*${stype}.*jar`
	if [ "x$jar_name" != "x" ]; then
		echo "$SLOTS_RUNDIR/$jar_name"
	else
		echo ""
	fi
}

# 启动服务
function service::start {	
	stype=$1
	svrid=$2
	if service::is_alive $stype $svrid; then
		io::log_info ${var_log_file} $(io::green "[$stype/$svrid] is started")
		return 1
	fi
	if [ "${start_max_try}x" == "x" ]; then
		start_max_try=10
	fi
	SLOTS_JAVA_OPTION=$(service::get_jvm_param $stype)
	SLOTS_USR_PARAM="-Dapp.server.appid=$svrid -Dapp.server.apptype=$stype -Dapp.server.confpath=$SLOTS_CFGDIR -Dapp.server.logpath=$SLOTS_LOGDIR -Dapp.server.jsonpath=$SLOTS_JSONDIR -Dapp.server.sslpath=$SLOTS_SSLDIR -Dapp.server.luapath=$SLOTS_LUADIR -Dapp.server.modulespath=$SLOTS_MODULES"
	jarbin_dir=$(service::update_jar $stype)
	if [ "x$jarbin_dir" == "x" ]; then
		io::log_warn ${var_log_file} $(io::red "[$stype/$svrid] start faild, jar not found")
		return 3
	fi
	echo "nohup $JAVA -server $SLOTS_JAVA_OPTION $SLOTS_USR_PARAM -jar $jarbin_dir >/dev/null 2>&1 &"
	nohup $JAVA -server $SLOTS_JAVA_OPTION $SLOTS_USR_PARAM -jar $jarbin_dir >/dev/null 2>&1 &
	# 延迟判断
	sleep 2
	# 等待进程启动
	for ((_cnt = 1; _cnt <= ${start_max_try}; _cnt++)); do
		sleep 1
		if service::is_alive $stype $svrid; then
			break
		fi
		io::log_info ${var_log_file} $(io::white "[$stype/$svrid] start ing...$_cnt")
	done
	# 等待启动完成
	sleep 1
	# 检测启动是否成功  
	if service::is_alive $stype $svrid; then
		io::log_info ${var_log_file} $(io::green "[$stype/$svrid] start success")
		return 0    
	else
		io::log_warn ${var_log_file} $(io::red "[$stype/$svrid] start faild")
		return 2
	fi 
}

# 重载服务
function service::reload {
	stype=$1
	svrid=$2
	pid=$(service::get_pid $stype $svrid)
	if [ "x$pid" == "x" ];then
		io::log_warn ${var_log_file} $(io::red "[$stype/$svrid] reload faild")
		return 2
	else
		$(kill -12 $pid)
		io::log_info ${var_log_file} $(io::green "[$stype/$svrid] reload success")
		return 0 
	fi			 
}

# 关闭服务
function service::stop {
	stype=$1
	svrid=$2
	stop_max_try=$2
	pid=$(service::get_pid $stype $svrid)
	if [ "${stop_max_try}x" == "x" ]; then
		stop_max_try=10
	fi
	if [ "x$pid" == "x" ];then
		io::log_info ${var_log_file} $(io::green "[$stype/$svrid] is stoped")
		return 1
	fi
	$(kill $pid)
	# 等待正常关闭流程
	for ((_cnt = 1; _cnt < ${stop_max_try}; _cnt++)); do
		sleep 1	
		if ! server::is_alive $stype $svrid; then
			break
		fi
		io::log_info ${var_log_file} $(io::white "[$stype/$svrid] stop ing...$_cnt")		
	done
	# 等待关闭完成
	sleep 1
	# 检测启动是否成功  
	if ! service::is_alive $stype $svrid; then
		io::log_info ${var_log_file} $(io::green "[$stype/$svrid] stop success")
		return 0    
	else
		$(kill -9 $pid)
		io::log_warn ${var_log_file} $(io::red "[$stype/$svrid] stop success, kill -9")
		return 2
	fi
}

# kill服务
function service::kill {
	stype=$1
	svrid=$2
	pid=$(service::get_pid $stype $svrid)
	if [ "x$pid" == "x" ];then			
		io::log_warn ${var_log_file} $(io::red "[$stype/$svrid] is killed")
		return 1
	else
		$(kill -9 $pid)
		io::log_warn ${var_log_file} $(io::red "[$stype/$svrid] kill success, kill -9")
		return 0
	fi	
}

# 重启服务
function server::restart 
{
	stype=$1
	svrid=$2
	server::stop $stype $svrid
	sleep 5
	server::start $stype $svrid 
}

main "${@}"
