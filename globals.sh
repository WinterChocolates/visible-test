#!/bin/bash

# 应用目录
readonly APP_DIR="/visible"

# 应用名称
readonly APP_NAME="visible"

# 系统版本
. /etc/os-release
readonly SYSTEM_VERSION=$NAME

# 可见目录
readonly centos="/visible/centos"

# CentOS 启动脚本
readonly CENTOS_START_BASE="$APP_DIR/centos/index.sh"

# Ubuntu/Debian 目录
readonly deub="/visible/deub"

# Ubuntu/Debian 启动脚本
readonly DEUB_START_BASE="$APP_DIR/deub/index.sh"

# 架构
ARCHITECTURE=""
# 当前架构变量
CUR_ARCHITECTURE=""
# 架构检查
detectionArchitecture() {
    case $(arch) in
    x86_64) CUR_ARCHITECTURE="x64" ;;
    aarch64) CUR_ARCHITECTURE="arm64" ;;
    *)
        read -p "$(echo -e "暂不支持armv71,s390x等架构\n手动安装参考Ubuntu详细\n回车退出")" Enter
        exit
        ;;
    esac
}
detectionArchitecture

# 架构
readonly ARCHITECTURE="$CUR_ARCHITECTURE"

# 版本控制,旧系统请下载16.20.0
# NODE_VERSION='16.20.0'
# 适用于 CentOS 8 及以上版本
readonly NODE_VERSION='22'
readonly REDIS_VERSION='6.2.13'
readonly PCRE_VERSION='8.45'
readonly NGINX_VERSION='1.24.0'
readonly NVM_VERSION='0.40.3'

# 包管理器
# readonly CENTOS_PKG_MANAGER='yum' # 适用于 CentOS 7
readonly CENTOS_PKG_MANAGER='dnf' # 适用于 CentOS 8 及以上版本
readonly DEUB_PKG_MANAGER='apt-get' # 适用于 Ubuntu/Debian

# NVM 下载地址
readonly NVM_DOWNLOAD_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh"
# NVM 镜像源
readonly NVM_NODEJS_ORG_MIRROR_URL="https://npmmirror.com/mirrors/node"
# NPM 镜像源
readonly NPM_NODEJS_ORG_MIRROR_URL="https://registry.npmmirror.com"
# Node.js 镜像源
readonly REDIS_DOWNLOAD_URL="http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"
# Nginx 下载地址
readonly NGINX_DOWNLOAD_URL="http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
# nginx依赖
readonly NGINX_DEPENDENCIES="make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre-devel gcc"
# NGINX DEUB 依赖
readonly NGINX_DEUB_DEPENDENCIES="build-essential zlib1g-dev g++ libpcre3-dev openssl libssl-dev"
# PCRE 下载地址
readonly PCRR_DOWNLOAD_URL="http://downloads.sourceforge.net/project/pcre/pcre/$PCRE_VERSION/pcre-$PCRE_VERSION.tar.gz"

# Docker 官方仓库地址
readonly DOCKER_REPO_URL="https://download.docker.com/linux/centos/docker-ce.repo"

# Docker 依赖包
readonly DOCKER_DEPENDENCIES="yum-utils device-mapper-persistent-data lvm2"
# Docker DEUB 依赖包
readonly DOCKER_DEUB_DEPENDENCIES="apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common"

# 用户（计划废弃）
readonly USER_BASE_DIR="/home/lighthouse"

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
