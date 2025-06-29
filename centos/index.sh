#!/bin/bash

source /visible/globals.sh

# 检查 wget 是否安装，未安装则安装
wget --version &>/dev/null
if [ $? != 0 ]; then
    $CENTOS_PKG_MANAGER install wget -y
fi

# 检查 git 是否安装，未安装则安装
git --version &>/dev/null
if [ $? != 0 ]; then
    $CENTOS_PKG_MANAGER install git -y
fi

ENVIRONMENT_BASH="$centos/selects/environment.sh"
SYSTEM_CONFIG_BASH="$centos/selects/SystemConfig.sh"
TOOL_MANAGEMENT_BASH="$centos/selects/shellupdata.sh"

while true; do
    OPTION=$(whiptail \
        --title "《Visible》" \
        --menu "$SYSTEM_VERSION" \
        20 70 10 \
        "1" "环境部署 Environment" \
        "2" "系统设置 Syten Config" \
        "3" "脚本管理 Tool Management" \
        "4" "重启系统 Restart" \
        3>&1 1>&2 2>&3)

    feedback=$?
    if [ $feedback = 0 ]; then
        # 环境部署
        if [ $OPTION = 1 ]; then
            bash "$ENVIRONMENT_BASH"
        fi

        if [ $OPTION = 2 ]; then
            bash "$SYSTEM_CONFIG_BASH"
        fi

        if [ $OPTION = 3 ]; then
            bash "$TOOL_MANAGEMENT_BASH"
        fi

        # 系统重启
        if [ $OPTION = 4 ]; then
            shutdown -r now
            break # 系统重启后退出脚本
        fi
    else
        exit # 退出脚本
    fi
done
