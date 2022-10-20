#!/bin/bash
SHELL_BIN="${BASH_SOURCE-$0}"
SHELL_BIN="$(dirname "${SHELL_BIN}")"
SHELL_BINDIR="$(cd "${SHELL_BIN}"; pwd)"

SETUP_RESULT=0
PHP_NEED_SETUP=0
NGINX_NEED_SETUP=0
if [[ -d '/usr/local/php' ]]; then
	echo "have php"
	SYS_CMD="systemctl status php-fpm"
	SYS_CMD_RES=$($SYS_CMD)
	SYS_CMD_STATUS=`echo $SYS_CMD_RES | grep 'Active: active (running)'`
	if [[ "$SYS_CMD_STATUS" ]]; then
		if [[ -d '/usr/local/nginx' ]]; then
			echo "have nginx"
			SYS_CMD="systemctl status nginx"
			SYS_CMD_RES=$($SYS_CMD)
			SYS_CMD_STATUS=`echo $SYS_CMD_RES | grep 'Active: active (running)'`
			if [[ "$SYS_CMD_STATUS" ]]; then
				SETUP_RESULT=2
			else
				SETUP_RESULT=3
			fi
		else
			echo "not found nginx"
			NGINX_NEED_SETUP=1
		fi
	else
		SETUP_RESULT=3
	fi
else
	echo "not found php"
	PHP_NEED_SETUP=1
	NGINX_NEED_SETUP=1
fi


if [[ "$PHP_NEED_SETUP" == "1" ]] || [[ "$NGINX_NEED_SETUP" == "1" ]]; then
	echo "clean yum beg........"
	sh $SHELL_BINDIR/shell/clean_yum.sh
	echo "clean yum end........"

	echo "init security beg........"
	sh $SHELL_BINDIR/shell/init_security.sh
	echo "init security end........"

	echo "setup system config beg........"
	sh $SHELL_BINDIR/shell/setup_sysconf.sh
	echo "setup system config end........"

	echo "setup php_env beg........"
	sh $SHELL_BINDIR/shell/php_env.sh
	echo "setup php_env end........"
	if [[ "$PHP_NEED_SETUP" == "1" ]]; then
		echo "setup php beg........"
		sh $SHELL_BINDIR/shell/setup_php.sh
		echo "setup php end........"

		echo "setup init_php beg........"
		sh $SHELL_BINDIR/shell/init_php.sh
		echo "setup init_php end........"
	fi
	if [[ "$NGINX_NEED_SETUP" == "1" ]]; then
		echo "setup nginx beg........"
		sh $SHELL_BINDIR/shell/setup_nginx.sh
		echo "setup nginx end........"
	fi
	if [[ -d '/usr/local/php' ]]; then
		SYS_CMD="systemctl status php-fpm"
		SYS_CMD_RES=$($SYS_CMD)
		SYS_CMD_STATUS=`echo $SYS_CMD_RES | grep 'Active: active (running)'`
		if [[ "$SYS_CMD_STATUS" ]]; then
			if [[ -d '/usr/local/nginx' ]]; then
				SYS_CMD="systemctl status nginx"
				SYS_CMD_RES=$($SYS_CMD)
				SYS_CMD_STATUS=`echo $SYS_CMD_RES | grep 'Active: active (running)'`
				if [[ "$SYS_CMD_STATUS" ]]; then
					SETUP_RESULT=1
				else
					echo "nginx not running"
					SETUP_RESULT=4
				fi
			fi
		else
			echo "php-fpm not running"
			SETUP_RESULT=4
		fi
	fi
fi

if [[ "$SETUP_RESULT" == "0" ]]; then
	echo "==install.sh finish==;$1;result:faild"
elif [[ "$SETUP_RESULT" == "1" ]]; then
	# 安装成功后重启
	echo "==install.sh finish==;$1;result:ok"
	exit 1
elif [[ "$SETUP_RESULT" == "2" ]]; then
	echo "==install.sh finish==;$1;result:repeated"
elif [[ "$SETUP_RESULT" == "3" ]]; then
	echo "==install.sh finish==;$1;result:not running"
else
	echo "==install.sh finish==;$1;result:can't running"
fi