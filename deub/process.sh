#!/bin/bash

source /visible/globals.sh

cd "$USER_BASE_DIR"

while true
do
	OPTION=$(whiptail \
		--title "《Process》" \
		--menu "$version" \
		15 50 5 \
		"1" "安装InstallLsof" \
		"2" "查看Lsof -i:" \
		"3" "杀死Kill -9" \
		3>&1 1>&2 2>&3)
	feedback=$?
	if [ $feedback = 0 ]; then
		if [ $OPTION = 1 ]; then
			apt install lsof -y
			read -p "Enter回车并继续..." Enter
		fi

		if [ $OPTION = 2 ]; then
			read -p "输入端口：" ID
			lsof -i:$ID
			read -p "记下PID,Enter回车并继续..." Enter
                fi
		if [ $OPTION = 3 ]; then
			read -p "选择PID：" PID
			kill -9 $PID
			read -p "已执行,Enter回车并继续..." Enter
                fi
	else
		exit
	fi
done
