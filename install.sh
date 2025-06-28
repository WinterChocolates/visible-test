#!/bin/bash

# 引入变量
source /visible/globals.sh

# 设置 visible
bash /visible/bin.sh

# 启动 检查系统
. /etc/os-release
release=$ID

case $release in
"rhel" | "centos" | "fedora")
    bash "$CENTOS_START_BASE"
    ;;
"ubuntu" | "debian")
    bash "$DEUB_START_BASE"
    ;;
esac
