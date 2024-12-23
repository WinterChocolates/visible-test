#!/bin/bash

source /visible/globals.sh

# 检查 wget 是否安装，未安装则安装
wget --version &>/dev/null
if [ $? != 0 ]; then
    yum install wget -y
fi

# 检查 git 是否安装，未安装则安装
git --version &>/dev/null
if [ $? != 0 ]; then
    yum install git -y
fi

while true; do
    OPTION=$(whiptail \
        --title "《Visible》" \
        --menu "$version" \
        15 50 3 \
        "1" "环境部署 Environment" \
        "2" "工具管理 Tool Management" \
        "3" "系统重启 Restart" \
        3>&1 1>&2 2>&3)

    feedback=$?
    if [ $feedback = 0 ]; then
        # 环境部署
        if [ $OPTION = 1 ]; then
            bash "$centos/environment.sh"
        fi

        # 工具管理 (示例功能，具体根据需求修改)
        if [ $OPTION = 2 ]; then
            bash "$centos/shellupdata.sh"
        fi

        # 系统重启
        if [ $OPTION = 3 ]; then
            shutdown -r now
            break # 系统重启后退出脚本
        fi
    else
        exit # 退出脚本
    fi
done
