#!/bin/bash
SHELL_BIN="${BASH_SOURCE-$0}"
SHELL_BIN="$(dirname "${SHELL_BIN}")"
SHELL_BIN="$(cd "${SHELL_BIN}"; pwd)"

ETC_PROFILE_PATH='/etc/profile'

# 安装rpm目录下的所有rpm包
function installTar() {
        for tarFile in `ls $SHELL_TAR_DIR | grep $1.*.tar`;do
				if [ ! -e "$2" ]; then
				  mkdir -p $2
				  chown -R root:root $2
				fi
				if [ -e "$2/${tarFile%%.tar*}" ]; then
					echo "$tarFile is same install"
					continue
				fi				
                echo "insatll $tarFile begin.."
                tar -xzf $SHELL_TAR_DIR/$tarFile -C $2
                echo "insatll $tarFile sucess.."
        done
}

# 安装rpm目录下的所有rpm包
function installRpm() {
        for rpmFile in `ls $SHELL_RPM_DIR | grep $1.*rpm`;do
				if [ "x$2" != "x" ];then
					echo "insatll $rpmFile to $2 begin.."
					rpm -ivh --prefix=$2 $SHELL_RPM_DIR/$rpmFile --nodeps --force
					echo "insatll $rpmFile to $2 sucess.."
				else
					echo "insatll $rpmFile begin.."
					rpm -ivh $SHELL_RPM_DIR/$rpmFile --nodeps --force
					echo "insatll $rpmFile sucess.."
				fi             
        done
}

# 卸载指定rpm包
function uninstallRpm() {
        for eme in `rpm -qa |grep $1`;do
                echo "uninsatll $eme begin.."
                rpm -e --nodeps --force $eme  #执行卸载命令
                echo "uninsatll $eme sucess.."
        done
}

# 从/etc/profile中删除一条export
function delExport() {
        
        sed -i "/export.*$1=/d" $ETC_PROFILE_PATH
}

# 向/etc/profile中添加一条export
function addExport() {
        export_findstr="^export $1=.*"
        export_value="export $1=$2"
        isFind=`sed -n "/$export_findstr/p" $ETC_PROFILE_PATH`
        if [ -n "$isFind" ];then
                echo "update export [$export_findstr],[$export_value]"
                sed -i "s#$export_findstr#$export_value#g" $ETC_PROFILE_PATH
        else
                echo "add export $1=$2"
                echo "export $1=$2" >> $ETC_PROFILE_PATH
        fi
		source $ETC_PROFILE_PATH
}

function appendExport() {
		export_findstr_none="^export $1="
        export_findstr="^export $1=.*${2//\//\\/}"
		export_value=":${2//\//\\/}"
		echo $export_findstr
		isNone=`sed -n "/$export_findstr_none/p" $ETC_PROFILE_PATH`
        isFind=`sed -n "/$export_findstr/p" $ETC_PROFILE_PATH`
		if [ -n "$isNone" ];then	
			if [ -n "$isFind" ];then
					echo "append $1:$2 is exist"
			else
					echo "append export $1:$2"
					sed -i "/$export_findstr_none/s/$/$export_value/" $ETC_PROFILE_PATH
			fi
		else	
			echo "add export $1=\$$1:$2"
			echo "export $1=\$$1:$2" >> $ETC_PROFILE_PATH
		fi	
		source $ETC_PROFILE_PATH
}

function deleteSymbol() {   
        sed -i "/.*$1.*/d" $2
}

function replaceSymbol() {   
		sed -i "s/.*$1.*/$2/g" $3
}
