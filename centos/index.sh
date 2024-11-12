#!/bin/bash

source /visible/globals.sh

wget --version 1>/dev/null
if [ $? != 0 ]
then yum  install wget -y
fi

git version 1>/dev/null
if [ $? != 0 ]
then
yum  install git -y
fi

while true
do
    OPTION=$(whiptail \
    --title "《visible》" \
    --menu "$version" \
    15 50 6 \
    "1" "环境部署Environment" \
    "2" "工具管理ToolManagement" \
    "3" "系统重启Restart" \
    3>&1 1>&2 2>&3)
    feedback=$?
    if [ $feedback = 0 ]; then
        # 环境部署administrat
        if [ $OPTION = 1 ]; then
            bash "$centos/environment.sh"
        fi

        # shellupdata
        if [ $OPTION = 4 ]; then
            bash "$centos/shellupdata.sh"
            child_exit_code=$?
            if [ $child_exit_code -eq 0 ]; then
                exit  # 结束整个脚本的执行
            fi
        fi

        # 系统重启restart
        if [ $OPTION = 7 ]; then
            shutdown -r now
        fi
    else
        exit
    fi
done
