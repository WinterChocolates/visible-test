# Visible

> Linux 系统轻量型图形化工具

UpdateTime:2023/9/26_V2.0

> node/chrome/redis/mysql/nginx

## 一、安装教程

> 若要配置版本或其他设置，可阅读[globals bash](./globals.sh)

#### （1）切换用户

```sh
sudo su root
```

#### （2）环境准备

>  Centos > 8, 推荐Centos9

> 1.`Centos`系统初始化

```sh
dnf update -y 
dnf install whiptail git wget curl rsync -y
```

>  Ubuntu > 20.04

> 2.`Ubuntu`系统初始化

```sh
apt update -y
apt-get install whiptail git wget curl rsync -y
```

#### （3）项目拉取

> 克隆并初次启动

```sh
git clone --depth=1 -b main https://github.com/lemonade-lab/visible.git  /visible && chmod +x /visible/*/*.sh  && sh /visible/install.sh
```

> 日常启动

```sh
visible
```

## 二、远程连接工具

> Android：`JuiceSSH`

> IOS：`Termius`

> Windows：`MobaXterm`、`Termius`

## 三、功能预览


| 功能                  | 描述                                                         | 备注                                               |
|-----------------------|--------------------------------------------------------------|----------------------------------------------------|
| 安装 Node.js & Yarn   | 检查并安装 Node.js、Yarn，自动配置国内 NVM 镜像与 npm 镜像  | 可自动安装 nvm，并设置镜像，适用中国大陆网络环境    |
| 安装 Chromium         | 安装 Chromium 浏览器                                         | 仅支持 rpm 包管理器环境                            |
| 安装 Redis            | 下载、解压、编译、安装并后台启动 Redis                      | 支持自定义 Redis 版本及路径，自动运行配置脚本      |
| 安装 MySQL            | 配置第三方源并安装 MySQL 社区版                              | 自动导入 GPG key，开机自启                         |
| 安装 Nginx            | 安装依赖并源码编译安装 Nginx，支持自定义 PCRE 模块           | 自动设置环境变量，源码参数可定制                   |
