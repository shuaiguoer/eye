#!/bin/bash
#chkconfig: 2345 88 66
#description: eye_server
#AUTHOR Shuai
#MAIL ls12345666@qq.com
#VERSION 1
#################################  希望此脚本邮件永不发送  ###################################
VERSION=eye_1.sh
LATEST_version=`curl http://pan.shuaiguoer.com/code/shell/eye/ 2> /dev/null  | grep "<span>"| awk -F">" '{print $2}' | awk -F"<" '{print $1}' | awk 'END{print}'`
LATEST_href="http://pan.shuaiguoer.com/code/shell/eye/$LATEST_version"
TIME=`date +"%Y-%m-%d %H:%M:%S"`
DISK_USE=`df -Th | grep '/$' | awk '{print $(NF-1)}' | awk -F% '{print $1}'`
MEM_USE=`free -m | grep Mem | awk '{print $3}'`
MEM_TOTAL=`free -m | grep Mem | awk '{print $2}'`
MEM_PERCENT=$((MEM_USE*100/MEM_TOTAL))
DDOS_MAX_NUM=`netstat -ntu | awk '{print $5}' | cut -d: -f1 | uniq -c | sort -n | awk 'END{print $1}'`
DDOS_MAX_IP=`netstat -ntu | awk '{print $5}' | cut -d: -f1 | uniq -c | sort -n | awk 'END{print $2}'`
CONF_DIR=/etc/eye
EYE_STATUS=`grep status $CONF_DIR/eye.conf 2>/dev/null | awk '{print $2}'`
EMAIL=`grep email $CONF_DIR/eye.conf 2>/dev/null | awk '{print $2}'`
DISK_LIMIT=`grep DISK $CONF_DIR/eye.conf 2>/dev/null | awk '{print $2}'`
MEM_LIMIT=`grep MEM $CONF_DIR/eye.conf 2>/dev/null | awk '{print $2}'`
DDOS_LIMIT=`grep DDOS $CONF_DIR/eye.conf 2>/dev/null | awk '{print $2}'`

# 定位脚本所在当前目录
BIN_FOLDER=$(cd "$(dirname "$0")";pwd)

# 将eye加入系统服务
if [ ! -f /etc/init.d/eye ];	then
	\cp $BIN_FOLDER/eye.sh /etc/init.d/eye
	chkconfig --add eye
	chkconfig eye on
	echo "alias eye='$BIN_FOLDER/eye.sh'" >> /etc/bashrc
	source /etc/bashrc
fi

# 判断配置文件目录是否存在
[ ! -d $CONF_DIR ] && mkdir $CONF_DIR

# 字体颜色
color(){
	echo -e "\e[$1;$2m$3\e[0m"
}

# 生成默认配置文件
default_conf(){
if [ ! -f $CONF_DIR/eye.conf ];	then
printf "# eye配置文件
**********************

EYE_status      on

DISK_limit      90

MEM_limit       90

DDOS_limit      1000

EYE_email	""

**********************\n" > $CONF_DIR/eye.conf
fi
}

# 重置配置文件
conf_file(){
	read -p "请输入您的(磁盘)报警阈值(`color 1 31 %`)：" DISK_VAR
	read -p "请输入您的(内存)报警阈值(`color 1 31 %`)：" MEM_VAR
	read -p "请输入您的(DDOS)报警阈值(`color 1 31 连接数`)：" DDOS_VAR
	read -p "请输入您要接收eye报警的邮箱：" EMAIL_NUM
	cat << EOF

	eye配置文件
        ********************
	eye_status      on
	disk_limit      $DISK_VAR%
	mem_limit       $MEM_VAR%
	ddos_limit	$DDOS_VAR
	eye_email       $EMAIL_NUM
	conf_path	$CONF_DIR/eye.conf
	********************

EOF
	read -p "`color 1 34 确认写入配置文件？`(`color 1 32 y`/`color 1 31 n`)" RES
	if [ $RES == y ];	then
		echo -e "# eye配置文件\n**********************" > $CONF_DIR/eye.conf
		echo -e "\nEYE_status	on" >> $CONF_DIR/eye.conf
		echo -e "\nDISK_limit	$DISK_VAR" >> $CONF_DIR/eye.conf
		echo -e "\nMEM_limit	$MEM_VAR" >> $CONF_DIR/eye.conf
		echo -e "\nDDOS_limit	$DDOS_VAR" >> $CONF_DIR/eye.conf
		echo -e "\nEYE_email	$EMAIL_NUM" >> $CONF_DIR/eye.conf
		echo -e "\n**********************" >> $CONF_DIR/eye.conf
		color 1 32 配置保存成功
		break
	fi
}

# 判断是否创建配置文件
while :
do
	if [ ! -f $CONF_DIR/eye.conf ]; then
		default_conf
	else
		break
	fi
done

# 根据eye状态，判断是否报警
if [[ $EYE_STATUS == on ]];	then
	# 磁盘监控报警
	if [[ $DISK_USE -gt $DISK_LIMIT ]];	then
		echo -e "$TIME  磁盘使用量超出预期\n当前总占用：${DISK_USE}%" | mailx -s "磁盘警告" $EMAIL
		echo "$TIME	磁盘警告：当前总占用：${DISK_USE}%" >> eye.log
	fi

	# 内存监控报警
	if [[ $MEM_PERCENT -gt $MEM_LIMIT ]];	then
		echo -e "$TIME  内存使用量超出预期\n当前总占用：${MEM_PERCENT}%" | mailx -s "内存警告" $EMAIL
		echo "$TIME	内存警告：当前总占用：${MEM_PERCENT}%" >> eye.log
	fi

	# DDOS监控报警
	if [[ $DDOS_MAX_NUM -gt $DDOS_LIMIT ]];	then
		echo -e "$TIME     检测受到DDOS攻击(每分钟的连接数超出预期)\n每分钟被攻击次数：$DDOS_MAX_NUM    攻击者IP：$DDOS_MAX_IP" | mailx -s "DDOS警告" $EMAIL
		echo "$TIME	DDOS警告：每分钟被攻击次数：$DDOS_MAX_NUM	攻击者IP：$DDOS_MAX_IP" >> eye.log
	fi
fi

# 重置配置文件 --config
eye_config(){
while :
do
	conf_file
done
}

# 版本更新
eye_update(){
	if [[ $VERSION < $LATEST_version ]];	then
		read -p "`color 1 34 确认更新eye为最新版本？`(`color 1 32 y`/`color 1 31 n`)" OR
		if [ $OR == y ];	then
			color "" 1 正在为您更新，请稍等...
	                wget -O eye.sh $LATEST_href
			wget -qO eye_version.log http://pan.shuaiguoer.com/code/shell/log/eye_version.log
			color 1 32 更新成功！
			\cp $BIN_FOLDER/eye.sh /etc/init.d/eye
		fi
	else
		color 1 32 无需更新，已是最新版本！
	fi
}

# 状态显示
eye_show(){
	echo "● 内存当前占用量：$MEM_PERCENT"
	echo "● 磁盘当前占用量：$DISK_USE"
	echo "● DDOS最大连接数：$DDOS_MAX_NUM		最大连接IP：$DDOS_MAX_IP"
}

# 帮助信息 --help
eye_help(){
	printf "用法：	eye [选项]...
	\e[32m● \e[0m eye --help		帮助信息
	\e[32m● \e[0m eye --config		配置
	\e[32m● \e[0m eye update		更新
	\e[32m● \e[0m eye show		信息
	\e[32m● \e[0m eye start		开启
	\e[32m● \e[0m eye stop		关闭
	\e[32m● \e[0m eye status		当前状态\n"
}

# eye状态控制 on/off/status
case $1 in
	"")
		default_conf;;
	show)
		eye_show;;
	start)
		sed -i 's/off/on/' $CONF_DIR/eye.conf
		color 1 32 已开启;;
	stop)
		sed -i 's/on/off/' $CONF_DIR/eye.conf
		color 1 31 已关闭;;
	restart)
		sed -i 's/on/off/' $CONF_DIR/eye.conf
		color 1 31 已关闭
		sed -i 's/off/on/' $CONF_DIR/eye.conf
		color 1 32 已开启;;
	status)
		if [[ $EYE_STATUS == on ]];     then
			printf "当前eye状态：\e[1;32m● $EYE_STATUS\e[0m\n"
		elif [[ $EYE_STATUS == off ]];     then
			printf "当前eye状态：\e[1;31m● $EYE_STATUS\e[0m\n"
		fi;;
	--config)
		eye_config;;
	--help)
		eye_help;;
	update)
		eye_update;;
	*)
		echo "用法：eye  {show | start | stop | restart | status | update | --config | --help}"
esac
