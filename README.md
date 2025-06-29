# Visible

> Linux 系统轻量型图形化工具

## 一、安装教程

> 若要配置版本或其他设置，可阅读[globals bash](./globals.sh)

#### （1）切换用户

```sh
sudo su root
```

#### （2）环境准备

- 1.`Centos`系统初始化

>  Centos > 8, 推荐Centos9

```sh
dnf update -y 
dnf install git wget curl rsync -y
```

> 如果缺少`whiptail`可执行`dnf install whiptail -y`


- 2.`Ubuntu`系统初始化

>  Ubuntu > 20.04

```sh
apt update -y
apt-get install  git wget curl rsync -y
```

> 如果缺少`whiptail`可执行`apt-get install whiptail -y`

#### （3）项目拉取

- 克隆并初次启动

```sh
git clone --depth=1 -b main https://github.com/lemonade-lab/visible.git  /visible && chmod +x /visible/*/*.sh  && sh /visible/install.sh
```

- 日常启动

```sh
visible
```

## 二、远程连接工具

- Android：`JuiceSSH`

- IOS：`Termius`

- Windows：`MobaXterm`、`Termius`
