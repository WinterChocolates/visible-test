#!/bin/bash

source /visible/globals.sh

# 检查命令执行是否成功
check_command() {
    if [ $? -ne 0 ]; then
        echo "命令执行失败: $1"
        exit 1
    fi
}

# 安装必要的软件包
install_packages() {
    REQUIRED_PACKAGES=(
        pango.x86_64
        libXcomposite.x86_64
        libXcursor.x86_64
        libXdamage.x86_64
        libXext.x86_64
        libXi.x86_64
        libXtst.x86_64
        cups-libs.x86_64
        libXScrnSaver.x86_64
        libXrandr.x86_64
        GConf2.x86_64
        alsa-lib.x86_64
        atk.x86_64
        gtk3.x86_64
        libdrm
        libgbm
        libxshmfence
        nss
        curl
    )

    for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
        if ! rpm -q "$PACKAGE" &>/dev/null; then
            sudo yum install "$PACKAGE" -y
            check_command "安装包 $PACKAGE"
        fi
    done
}

# 安装 Node.js 和 Yarn
install_node() {
    node -v
    if [ $? -ne 0 ]; then
        echo "Node.js 未安装，开始安装 Node.js 和 Yarn..."

        # 安装 Node.js 依赖
        install_packages

        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        check_command "安装 NVM"

        echo 'export NVM_DIR="$HOME/.nvm"' >>~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>~/.bashrc
        source ~/.bashrc
        check_command "刷新 bashrc"

        NODE_VERSION="18.20.3"
        nvm install "$NODE_VERSION"
        nvm use "$NODE_VERSION"
        npm install yarn@1.19.1 -g --registry=https://registry.npmmirror.com
        check_command "安装 Node.js 和 Yarn"
    else
        echo "Node.js 已安装，版本：$(node -v)"
    fi
}

# 安装 Chromium
install_chromium() {
    if ! rpm -q chromium &>/dev/null; then
        sudo yum install chromium -y
        check_command "安装 Chromium"
    fi
}

# 安装 Redis
install_redis() {
    REDIS_DIR="$AppName/file/redis-$centosRedisV"

    # 如果 Redis 目录不存在，下载并解压 Redis
    if [ ! -d "$REDIS_DIR" ]; then
        cd "$AppName/file"
        wget "http://download.redis.io/releases/redis-$centosRedisV.tar.gz"
        check_command "下载 Redis"
        tar zxvf "redis-$centosRedisV.tar.gz"
        check_command "解压 Redis"
        rm -f "redis-$centosRedisV.tar.gz" # 删除下载的 tar 包以节省空间
    fi

    cd "$REDIS_DIR"

    # 如果 Redis 没有编译安装，执行编译和安装
    if [ ! -x "$REDIS_DIR/src/redis-server" ]; then
        make
        check_command "编译 Redis"
        make install
        check_command "安装 Redis"
    fi

    # 启动 Redis 服务器
    ./src/redis-server --daemonize yes
    check_command "启动 Redis"

    # 执行 Redis 配置脚本
    sh "$AppName/file/redis.sh"
    echo "Redis 安装完成，路径：$REDIS_DIR"
}

# 安装 MySQL
install_mysql() {
    sudo yum install epel-release -y
    check_command "安装 epel-release"
    sudo yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
    check_command "安装 remi-release"
    sudo yum-config-manager --enable remi -y
    sudo yum localinstall https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm -y
    check_command "安装 MySQL 源"
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    sudo yum install mysql-community-server -y
    check_command "安装 MySQL"
    sudo systemctl start mysqld
    sudo systemctl enable mysqld
}

# 安装 Nginx
install_nginx() {
    sudo yum install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre-devel gcc -y
    check_command "安装 Nginx 依赖包"

    if [ ! -d "/usr/local/pcre-$centosPcreV" ]; then
        cd /usr/local
        wget "http://downloads.sourceforge.net/project/pcre/pcre/$centosPcreV/pcre-$centosPcreV.tar.gz"
        tar zxvf "pcre-$centosPcreV.tar.gz"
        cd "pcre-$centosPcreV"
        ./configure
        make
        make install
        check_command "安装 pcre"
    fi

    cd "/usr/local/pcre-$centosPcreV"
    pcre-config --version

    if [ ! -d "/usr/local/nginx-$centosNginxV" ]; then
        cd /usr/local
        wget "http://nginx.org/download/nginx-$centosNginxV.tar.gz"
        tar zxvf "nginx-$centosNginxV.tar.gz"
        cd "nginx-$centosNginxV"
        ./configure --prefix=/usr/local/nginx --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module "--with-pcre=/usr/local/pcre-8.45" --with-stream
        make
        make install
        check_command "安装 Nginx"
    fi

    if ! which nginx >/dev/null 2>&1; then
        echo "Nginx 未安装，正在添加 Nginx 路径到环境变量中..."
        echo "export PATH=\$PATH:/usr/local/nginx/sbin:/usr/local/nginx/bin" >>/etc/profile
        source /etc/profile
        echo "Nginx 路径已成功添加到环境变量中。"
    else
        echo "Nginx 已安装，路径为：$(which nginx)"
    fi
}

# 主菜单函数
main_menu() {
    while true; do
        OPTION=$(whiptail \
            --title "《Environment》" \
            --menu "$version" \
            15 50 5 \
            "0" "刷新环境" \
            "1" "安装node" \
            "2" "安装chromium" \
            "3" "安装redis" \
            "4" "安装mysql" \
            "5" "安装nginx" \
            3>&1 1>&2 2>&3)

        feedback=$?
        if [ $feedback = 0 ]; then
            case $OPTION in
            0)
                source /etc/profile
                read -p "环境已刷新!回车并继续Enter..." Enter
                ;;
            1)
                install_node
                read -p "Node完成安装!回车并继续Enter..." Enter
                ;;
            2)
                install_chromium
                read -p "Chromium完成安装!回车并继续Enter..." Enter
                ;;
            3)
                install_redis
                read -p "Redis完成安装!回车并继续Enter..." Enter
                ;;
            4)
                install_mysql
                read -p "MySQL完成安装!回车并继续Enter..." Enter
                ;;
            5)
                install_nginx
                read -p "NGINX完成安装!回车并继续Enter..." Enter
                ;;
            *)
                exit 1
                ;;
            esac
        else
            exit
        fi
    done
}

main_menu
