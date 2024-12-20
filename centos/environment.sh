#!/bin/bash

source /visible/globals.sh

# 进入
cd "$DIRECTORY"

while true; do
    OPTION=$(whiptail \
        --title "《Environment》" \
        --menu "$version" \
        15 50 5 \
        "0" "刷新环境" \
        "1" "安装node" \
        "2" "安装redis" \
        "3" "安装mysql" \
        "4" "安装nginx" \
        3>&1 1>&2 2>&3)
    feedback=$?
    if [ $feedback = 0 ]; then


        # 刷新环境
        if [ $OPTION = 0 ]; then
            source /etc/profile
            ##返回
            read -p "环境已刷新!回车并继续Enter..." Enter
        fi

        # node
        if [ $OPTION = 1 ]; then

            node -v
            if [ $? != 0 ]; then
                 =yum install curl -y
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
                echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
                source ~/.bashrc # 刷新环境
                NODE_VERSION="18.20.3"
                nvm install "$NODE_VERSION"
                nvm use "$NODE_VERSION"
                npm install yarn@1.19.1 -g --registry=https://registry.npmmirror.com
            fi

            if [ ! $(strings /usr/lib64/libstdc++.so.6 | grep 'CXXABI_1.3.8') ]; then
                cd "$DIRECTORY"
                git clone https://gitee.com/WinterChocolates/libstdc-.so.6.0.26.git
                mv "$DIRECTORY"/libstdc-.so.6.0.26/libstdc++.so.6.0.26 /lib64/
                rm -rf /lib64/libstdc++.so.6
                ln -s /lib64/libstdc++.so.6.0.26 /lib64/libstdc++.so.6
                rm -rf "$DIRECTORY"/libstdc-.so.6.0.26
            fi
           
            # 安装 Chromium
            if ! rpm -q chromium &> /dev/null; then
                sudo yum install chromium -y
            fi
            # 安装更多依赖
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
            )
            for PACKAGE in "${REQUIRED_PACKAGES[@]}"; do
              if ! rpm -q "$PACKAGE" &> /dev/null; then
                sudo yum install "$PACKAGE" -y
              fi
            done

            # 安装 fonts
            if ! yum group list installed | grep -q "fonts"; then
                sudo yum groupinstall fonts -y
            fi
            
            ##返回
            read -p "完成机器人环境安装!回车并继续Enter..." Enter
        fi
        
        # 安装redis
        if [ $OPTION = 2 ]; then
            # 检查是否已经存在 Redis 源代码目录
            if [ ! -d "$AppName/file/redis-$centosRedisV" ]; then
                cd "$AppName/file"
                # 下载 Redis
                wget "http://download.redis.io/releases/redis-$centosRedisV.tar.gz"
                tar zxvf "redis-$centosRedisV.tar.gz"
            fi
            cd "$AppName/file/redis-$centosRedisV"
            # 检查是否已经编译安装 Redis
            if [ ! -x "$AppName/file/redis-$centosRedisV/src/redis-server" ]; then
                # 编译 Redis
                make
                make install
            fi
            # 启动 Redis 服务
            ./src/redis-server --daemonize yes
            # 设置
            sh  "$AppName/file/redis.sh"
            echo "$AppName/file/redis-$centosRedisV"
            read -p "完成数据库安装!回车并继续Enter..." Enter
        fi
        
        # mysql
        if [ $OPTION = 3 ]; then
            yum install epel-release -y
            yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
            yum-config-manager --enable remi -y
            yum localinstall https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm -y
            rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 
            yum install mysql-community-server -y
            systemctl start mysqld  # 启动
            systemctl enable mysqld # 自启动
            read -p "完成数据库安装!回车并继续Enter..." Enter
        fi

        # nginx
        if [ $OPTION = 4 ]; then
            #基础环境
            yum install make zlib zlib-devel gcc-c++ libtool openssl openssl-devel pcre-devel gcc -y
            # 检查是否已经安装了 pcre
            if [ ! -d "/usr/local/pcre-$centosPcreV" ]; then
                cd /usr/local
                wget "http://downloads.sourceforge.net/project/pcre/pcre/$centosPcreV/pcre-$centosPcreV.tar.gz"
                tar zxvf "pcre-$centosPcreV.tar.gz"
                cd "pcre-$centosPcreV"
                ./configure
                make
                make install
            fi
            cd  "/usr/local/pcre-$centosPcreV"
            # 检查
            pcre-config --version
            echo "/usr/local/pcre-$centosPcreV"
            # 检查是否已经安装了 nginx
            if [ ! -d "/usr/local/nginx-$centosNginxV" ]; then

                cd /usr/local
                wget  "http://nginx.org/download/nginx-$centosNginxV.tar.gz"
                tar zxvf "nginx-$centosNginxV.tar.gz"
                cd "nginx-$centosNginxV"
                ./configure --prefix=/usr/local/nginx --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module "--with-pcre=/usr/local/pcre-8.45" --with-stream
                make
                make install
            fi
            # 检查
            /usr/local/nginx/sbin/nginx -v
            echo "/usr/local/nginx-$centosNginxV"
            read -p "完成安装!回车并继续Enter..." Enter
        fi

        #最后返回
        cd "$DIRECTORY"

    else
        exit
    fi
done
