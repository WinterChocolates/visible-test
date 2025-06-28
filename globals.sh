#!/bin/bash

# 用户
USER_BASE_DIR="/home/lighthouse"

if [ ! -d "$USER_BASE_DIR" ]; then
    echo "$USER_BASE_DIR 开始创建..."
    mkdir -p "$USER_BASE_DIR"
    if [ $? -eq 0 ]; then
        echo "$USER_BASE_DIR 路径创建成功!"
    else
        echo "$USER_BASE_DIR 路径创建失败."
        exit 1
    fi
fi

# 地址
APP_DIR="/visible"
readonly APP_DIR

APP_NAME="visible"
readonly  APP_NAME

# 版本
. /etc/os-release
version=$NAME
#version=$(cat /etc/redhat-release 2>/dev/null || cat /etc/issue 2>/dev/null | sed 's/\\n//g; s/\\l//g; s/(Core)//g')
readonly version

centos="/visible/centos"
readonly centos

CENTOS_START_BASE="$APP_DIR/centos/index.sh"
readonly CENTOS_START_BASE

deub="/visible/deub"
readonly deub

DEUB_START_BASE="$APP_DIR/deub/index.sh"
readonly DEUB_START_BASE

# 架构
ARCHITECTURE=""

# 架构检查
detectionArchitecture() {
    case $(arch) in
    x86_64) ARCHITECTURE="x64" ;;
    aarch64) ARCHITECTURE="arm64" ;;
    *)
        read -p "$(echo -e "暂不支持armv71,s390x等架构\n手动安装参考Ubuntu详细\n回车退出")" Enter
        exit
        ;;
    esac
}

detectionArchitecture

# 版本控制,旧系统请下载16.20.0
# NODE_VERSION='16.20.0'
# 适用于 CentOS 8 及以上版本
NODE_VERSION='22'
REDIS_VERSION='6.2.13'
PCRE_VERSION='8.45'
NGINX_VERSION='1.24.0'

# 包管理器
# CENTOS_PKG_MANAGER='yum' # 适用于 CentOS 7
CENTOS_PKG_MANAGER='dnf' # 适用于 CentOS 8 及以上版本

NVM_DOWNLOAD_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh"
NVM_NODEJS_ORG_MIRROR_URL="https://npmmirror.com/mirrors/node"
NPM_NODEJS_ORG_MIRROR_URL="https://registry.npmmirror.com"

REDIS_DOWNLOAD_URL="http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"

NGINX_DOWNLOAD_URL="http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
# nginx依赖
NGINX_DEPENDENCIES="make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre-devel gcc"

PRCR_DOWNLOAD_URL="http://downloads.sourceforge.net/project/pcre/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz"
