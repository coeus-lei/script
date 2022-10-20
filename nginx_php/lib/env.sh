#!/bin/bash
SHELL_BIN="${BASH_SOURCE-$0}"
SHELL_BIN="$(dirname "${SHELL_BIN}")"
SHELL_BIN="$(cd "${SHELL_BIN}"; pwd)"

if [ "x$SHELL_LIB_DIR" = "x" ];then
	SHELL_LIB_DIR="$SHELL_BIN"
fi
if [ "x$SHELL_PACKET_DIR" = "x" ];then
	SHELL_PACKET_DIR="$SHELL_BIN/../packet"
fi
if [ "x$SHELL_RPM_DIR" = "x" ];then
	SHELL_RPM_DIR="$SHELL_PACKET_DIR/rpm"
fi
if [ "x$SHELL_SQL_DIR" = "x" ];then
	SHELL_SQL_DIR="$SHELL_PACKET_DIR/sql"
fi
if [ "x$SHELL_SYSCONF_DIR" = "x" ];then
	SHELL_SYSCONF_DIR="$SHELL_PACKET_DIR/sysconf"
fi
if [ "x$SHELL_TAR_DIR" = "x" ];then
	SHELL_TAR_DIR="$SHELL_PACKET_DIR/tar"
fi

for shFile in `ls $SHELL_LIB_DIR | grep .sh`;do
	if [ "$shFile" != "env.sh" ];then
		. $SHELL_LIB_DIR/$shFile
	fi
done