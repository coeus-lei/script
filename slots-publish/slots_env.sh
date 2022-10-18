#!/usr/bin/env bash
SLOTS_BINDIR="${SLOTS_BINDIR:-/usr/bin}"

# 定义路径
if [ "x$SLOTS_RUNDIR" = "x" ];then
	SLOTS_RUNDIR="$SLOTS_BINDIR/bin"
fi
if [ "x$SLOTS_CFGDIR" = "x" ];then
	SLOTS_CFGDIR="$SLOTS_BINDIR/service"
fi
if [ "x$SLOTS_JARDIR" = "x" ];then
	SLOTS_JARDIR="$SLOTS_BINDIR/jar"
fi
if [ "x$SLOTS_JSONDIR" = "x" ];then
	SLOTS_JSONDIR="$SLOTS_BINDIR/conf/json"
fi
if [ "x$SLOTS_LOGDIR" = "x" ];then
	SLOTS_LOGDIR="$SLOTS_BINDIR/log"
fi
if [ "x$SLOTS_DUMPDIR" = "x" ];then
	SLOTS_DUMPDIR="$SLOTS_BINDIR/dump"
fi
if [ "x$SLOTS_SSLDIR" = "x" ];then
	SLOTS_SSLDIR="$SLOTS_BINDIR/conf/ssl"
fi
if [ "x$SLOTS_LUADIR" = "x" ];then
	SLOTS_LUADIR="$SLOTS_BINDIR/conf/lua"
fi
if [ "x$SLOTS_MODULES" = "x" ];then
  SLOTS_MODULES="$SLOTS_BINDIR/conf/lua"
fi

# 初始化目录
if [ ! -e "$SLOTS_RUNDIR" ]; then
  $(mkdir -p $SLOTS_RUNDIR)
fi
if [ ! -e "$SLOTS_CFGDIR" ]; then
  $(mkdir -p $SLOTS_CFGDIR)
fi
if [ ! -e "$SLOTS_JARDIR" ]; then
  $(mkdir -p $SLOTS_JARDIR)
fi
if [ ! -e "$SLOTS_JSONDIR" ]; then
  $(mkdir -p $SLOTS_JSONDIR)
fi
if [ ! -e "$SLOTS_LOGDIR" ]; then
  $(mkdir -p $SLOTS_LOGDIR)
fi
if [ ! -e "$SLOTS_DUMPDIR" ]; then
  $(mkdir -p $SLOTS_DUMPDIR)
fi
if [ ! -e "$SLOTS_SSLDIR" ]; then
  $(mkdir -p $SLOTS_SSLDIR)
fi
if [ ! -e "$SLOTS_LUADIR" ]; then
  $(mkdir -p $SLOTS_LUADIR)
fi
if [ ! -e "$SLOTS_MODULES" ]; then
  $(mkdir -p $SLOTS_MODULES)
fi

# 搜索JDK目录
if [ "$JAVA_HOME" != "" ]; then
  JAVA="$JAVA_HOME/bin/java"
else
  JAVA=java
fi

# 初始化彩色打印的库
if [ -e "$SLOTS_BINDIR/lbf/lbf_init.sh" ]; then
  cd "$SLOTS_BINDIR/lbf/"
  . "$SLOTS_BINDIR/lbf/lbf_init.sh"
  cd "$SLOTS_BINDIR/"
fi

# 定义不同服务的JVM配置
declare -A SERVICE_JVM
SERVICE_JVM=(
["none"]="-server -XX:+UseG1GC -Xmx1G -Xms1G -XX:MaxGCPauseMillis=200"
["game2"]="-server -XX:+UseG1GC -Xmx4G -Xms4G -XX:MaxGCPauseMillis=200"
)

echo $SERVER_JAR
