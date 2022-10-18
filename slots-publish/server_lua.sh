#!/bin/bash
SHELL_BIN="${BASH_SOURCE-$0}"
SHELL_BIN="$(dirname "${SHELL_BIN}")"
SHELL_BINDIR="$(cd "${SHELL_BIN}"; pwd)"

. ${SHELL_BINDIR}/../common/tools/lbf/lbf/lbf_init.sh

############################################################
# User-defined variable
############################################################
# server settings
var_project_path=${SHELL_BINDIR}
var_log_file="${var_project_path}/server.log"
var_backup_dir="${var_project_path}/backup"
var_max_try=3000
var_telnet_max_try=10
var_mod_file="${var_project_path}/mod.txt"
var_skynet="${var_project_path}/../common/skynet/skynet"

############################################################
# Main Logic
############################################################
function usage 
{
  echo "Usage: $(path::basename $0) [start|stop|restart|reload|status] [all|loginsvrd|gatesvrd|...]"
  echo "       $(path::basename $0) [debug|cmd] [loginsvrd|gatesvrd|...]"
  echo "       $(path::basename $0) [kill] [all|loginsvrd|gatesvrd|...]"  
}

function main 
{
  cd ${var_project_path}
  
  case $1 in 
    start)      shift; do_start         ${@};;
    stop)       shift; do_stop          ${@};;
    restart)    shift; do_restart       ${@};;
    status)     shift; do_status        ${@};;
	reload)     shift; do_reload        ${@};;
    debug)  	shift; do_debug		    ${@};;
    cmd)  		shift; do_commond	    ${@};;
	kill)  		shift; do_kill		    ${@};;
    *)          usage;;
  esac
  io::no_output cd -
}

function do_kill
{
  util::is_empty $1 && usage && return 1
  case $1 in
    all) 
	  total_count=0
	  kill_count=0
	  killed_count=0  
	  # read必须把文件写最后,否则会新建立SHELL导致无法获取变量
      while read _mod; do
        svrid=`echo $_mod|awk -F" " '{print $1}'`
		server::kill ${svrid}
		result=$?
		let total_count++
		if [ $result -eq 1 ]; then
			let killed_count++
		else
			let kill_count++
		fi
      done < ${var_mod_file}
	  io::log_warn ${var_log_file} $(io::blue "total:$total_count") $(io::green "killed:$killed_count") $(io::red "kill:$kill_count")
	  ;;

    *)
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      server::kill $svrid;;
  esac
}

function do_start
{
  util::is_empty $1 && usage && return 1
  case $1 in
    all) 
	  total_count=0
	  start_count=0
	  started_count=0  
	  faild_count=0
	  # read必须把文件写最后,否则会新建立SHELL导致无法获取变量
      while read _mod; do
        svrid=`echo $_mod|awk -F" " '{print $1}'`
		server::start ${svrid}
		result=$?
		let total_count++
		if [ $result -eq 2 ]; then
			let started_count++
		elif [ $result -eq 0 ]; then
			let start_count++
		else
			let faild_count++
		fi
      done < ${var_mod_file}
	  if [ $faild_count -lt 0 ]; then
		io::log_warn ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$start_count") $(io::yellow "started:$started_count") $(io::red "faild:$faild_count")
	  else
		io::log_info ${var_log_file} $(io::blue "total:$total_count") $(io::green "start:$start_count") $(io::yellow "started:$started_count") $(io::red "faild:$faild_count")
	  fi  
	  ;;

    *)
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      server::start $svrid;;
  esac
}

function do_stop
{
  util::is_empty $1 && usage && return 1

  case $1 in
    all) 
      tac ${var_mod_file} | while read _mod; do
		svrid=`echo ${_mod}|awk -F" " '{print $1}'`
		svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
		time=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $3}'`
        server::stop ${_mod}
      done ;;

    *)
      
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
	  time=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $3}'`
      server::stop ${svrid} ${svrport} ${time};;
  esac
}

function do_restart 
{
  util::is_empty $1 && usage && return 1
  do_stop ${@}
  do_start ${@}
}

function do_status 
{
  util::is_empty $1 && usage && return 1
  case $1 in
    all) 
      cat ${var_mod_file} | while read _mod; do
        svrid=`echo $_mod|awk -F" " '{print $1}'`
		svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
        server::status ${svrid} ${svrport}
      done ;;

    *)
      svrid=`echo ${@}|awk -F" " '{print $1}'`
	  svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
      server::status ${svrid} ${svrport};;
  esac
}

function do_reload 
{
  util::is_empty $1 && usage && return 1

  case $1 in
    all) 
      cat ${var_mod_file} | while read _mod; do
		svrid=`echo $_mod|awk -F" " '{print $1}'`
		svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
        server::reload ${svrid} ${svrport}
      done ;;

    *)
      
      svrid=`echo ${@}|awk -F" " '{print $1}'`
      svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
      server::reload ${svrid} ${svrport};;
  esac
}

function do_debug
{
  util::is_empty $1 && usage && return 1
  svrid=`echo ${@}|awk -F" " '{print $1}'`
  svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
  result=$(server::check_port "${svrport}")
  if [ $result -gt 0 ]; then
	server::cammond ${svrid} ${svrport} "help"
	server::cammond ${svrid} ${svrport} "list"
	telnet 127.0.0.1 $svrport
  else
	server::status ${svrid} ${svrport}
	echo $(io::red "[$svrid] debug faild")
  fi  
}

function do_commond 
{
  util::is_empty $1 && usage && return 1
  echo "${@}"  
  svrid=`echo ${@}|awk -F" " '{print $1}'`
  svrport=`cat ${var_mod_file}|grep ${svrid}|awk -F" " '{print $2}'`
  server::cammond ${svrid} ${svrport} ${@:2}  
}


############################################################
# MOST OF TIMES YOU DO NOT NEED TO CHANGE THESE
############################################################
#################################
# process-related funcs
function server::is_alive 
{
  io::no_output pgrep -xf "${*}" && return 0 || return 1
}

function server::check_port 
{
  echo `echo -e "\n" | telnet 127.0.0.1 $1 2> /dev/null | grep Connected | wc -l`
}

function server::check_date
{
	result=`echo ${1} | egrep "^([0-9]{4})-(0[1-9]|1[0-2])-(0[0-9]|[1-2][0-9]|3[0-1])$"`
	if [ "x$result" == "x" ];then
		return 1
	else
		return 0
	fi
}

function server::status 
{
  svrid=$1
  port=$2  
  output=$(io::white "[${svrid}]")
  if server::is_alive "$var_skynet config_${svrid}"; then
    output="${output}    $(io::blue "[alive]")$(io::green "true")"
  else
    output="${output}    $(io::blue "[alive]")$(io::red "false")"
  fi

  result=$(server::check_port "${port}")
  if [ $result -gt 0 ]; then
	output="${output}    $(io::yellow "[debug]")$(io::green "true")"
  else
	output="${output}    $(io::yellow "[debug]")$(io::red "false")"
  fi  

  echo $output  
}

function server::kill 
{
	svrid=$1
	if ! server::is_alive "$var_skynet config_${svrid}"; then
		io::log_warn ${var_log_file} $(io::red "[$svrid] is killed")
		return 1
	fi
	pkill -9 -xf "$var_skynet config_${svrid}"
	io::log_warn ${var_log_file} $(io::red "[$svrid] kill success, kill -9")
	return 0
}

function server::start 
{
  svrid=$1
  local _dir="${var_project_path}/$(basename ${svrid})/" && cd $_dir

  Cur_Dir=$(pwd)
  echo $Cur_Dir
  echo $_dir
  echo $PATH
  echo "$var_skynet config_${svrid}"
  if server::is_alive "$var_skynet config_${svrid}"; then
    io::log_info ${var_log_file} $(io::green "[$svrid] is started")
    return 2
  fi
  eval "$var_skynet config_${svrid}"
  # 等待进程启动
  for ((_cnt = 1; _cnt < ${var_max_try}; _cnt++)); do
  	sleep 0.1
  	if server::is_alive "$var_skynet config_${svrid}"; then
  		break
  	fi
  done
  # 等待启动完成
  sleep 2
  # 打印启动日志  
  if [ -f "${_dir}systemlog" ]; then
     tail -25 "${_dir}systemlog"
  fi
  # 检测启动是否成功  
  if server::is_alive "$var_skynet config_${svrid}"; then
	io::log_warn ${var_log_file} $(io::green "[$svrid] start success")
    return 0    
  else
    io::log_info ${var_log_file} $(io::red "[$svrid] start faild")
    return 1
  fi 
}

function server::stop 
{
  svrid=$1
  port=$2   
  stop_max_try=$3
  if [ "${stop_max_try}x" == "x" ]; then
	stop_max_try=${var_max_try}
  fi
  io::log_info ${var_log_file} $(io::green "[$stop_max_try]")  
  if ! server::is_alive "$var_skynet config_${svrid}"; then
	io::log_info ${var_log_file} $(io::green "[$svrid] is stoped")
	return 1
  fi
  # 获取debug_console服务的状态
  telnet_close=false  
  for ((_cnt = 1; _cnt < ${var_telnet_max_try}; _cnt++)); do
    address=$(server::get_address ${svrid} ${port})   
	server::cammond ${svrid} ${port} "call" ${address} "'cmd','close'"
	result=$?
	if [ $result -eq 0 ]; then
		telnet_close=true
		break
	fi
	sleep 0.1
  done
  if $telnet_close; then
	  # 等待正常关闭流程
	  for ((_cnt = 1; _cnt < ${stop_max_try}; _cnt++)); do		
		if ! server::is_alive "$var_skynet config_${svrid}"; then
			io::log_info ${var_log_file} $(io::green "[$svrid] stop success, telnet")
			return 0
		fi
		sleep 0.1
	  done
  fi
  # 如果正常流程无法关闭,则使用kill -user2结束  
  pkill -USR2 -xf "$var_skynet config_${svrid}"
  for ((_cnt = 1; _cnt < ${var_max_try}; _cnt++)); do
	sleep 0.1
	if ! server::is_alive "$var_skynet config_${svrid}"; then
		io::log_warn ${var_log_file} $(io::red "[$svrid] stop success, kill")
		return 2
	fi
  done
  # 最后使用必杀武器kill -9  
  pkill -9 -xf "$var_skynet config_${svrid}"
  io::log_warn ${var_log_file} $(io::red "[$svrid] stop success, kill -9")
  return 3  
}

function server::restart 
{
  svrid=$1
  port=$2
  server::stop $svrid $port
  server::start $svrid  
}

function server::reload 
{
  svrid=$1
  port=$2 
  address=$(server::get_address ${svrid} ${port}) 
  server::cammond ${svrid} ${port} "call" ${address} "'cmd','reload'"
  result=$?  
  if [ $result -eq 1 ]; then
	server::status ${svrid} ${svrport}
	io::log_warn ${var_log_file} $(io::red "[$svrid] reload faild")
	return 1
  fi
  io::log_info ${var_log_file} $(io::green "[$svrid] reload success")
  return 0  
}

function server::get_address 
{
  service_id=$1
  port=$2
  address=`eval "echo 'list';sleep 1" | telnet 127.0.0.1 $port | grep $svrid | awk -F" " '{print $1}'`
  echo $address  
}

function server::cammond 
{
  svrid=$1
  port=$2
  cmd="${@:3}"  
  echo "server::cammond ${cmd}"
  result=$(server::check_port "${svrport}")
  if [ $result -lt 1 ]; then
	return 1
  fi
  eval 'echo "${cmd}";sleep 1' | telnet 127.0.0.1 $port
  return 0  
}

#################################
# here we start the main logic
main "${@}"

# vim:ts=2:sw=2:et:ft=sh:
