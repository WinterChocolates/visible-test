#!/bin/bash

source /visible/globals.sh

# 检查命令执行是否成功
checkCommand() {
    if [ $? -ne 0 ]; then
        echo "命令执行失败: $1"
        exit 1
    fi
}

# 安装必要的软件包
installPackageBaseBag() {
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
            sudo $CENTOS_PKG_MANAGER install "$PACKAGE" -y
            checkCommand "安装包 $PACKAGE"
        fi
    done
}

# 安装 Node.js 和 Yarn
installNode() {
    node -v
    if [ $? -ne 0 ]; then
        echo "Node.js 未安装，开始安装 Node.js 和 Yarn..."

        # 安装 Node.js 依赖
        installPackageBaseBag

        curl -o- "$NVM_DOWNLOAD_URL" | bash
        checkCommand "安装 NVM"

        echo 'export NVM_DIR="$HOME/.nvm"' >>~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>~/.bashrc
        source ~/.bashrc
        checkCommand "刷新 bashrc"

        # 设置 NVM 的 Node.js 镜像源
        export NVM_NODEJS_ORG_MIRROR="$NVM_NODEJS_ORG_MIRROR_URL"

        nvm install "$NODE_VERSION"
        nvm use "$NODE_VERSION"
        checkCommand "安装 Node.js"

        npm install yarn -g --registry="$NPM_NODEJS_ORG_MIRROR_URL"
        checkCommand "安装 Node.jsYarn"
    else
        echo "Node.js 已安装，版本：$(node -v)"
    fi
}

# 安装 Chromium
installChromium() {
    if ! rpm -q chromium &>/dev/null; then
        sudo $CENTOS_PKG_MANAGER install chromium -y
        checkCommand "安装 Chromium"
    fi
}

# 安装 Redis
installRedis() {
    REDIS_DIR="$APP_DIR/file/redis-$REDIS_VERSION"

    # 如果 Redis 目录不存在，下载并解压 Redis
    if [ ! -d "$REDIS_DIR" ]; then
        cd "$APP_DIR/file"
        wget "$REDIS_DOWNLOAD_URL"
        checkCommand "下载 Redis"
        tar zxvf "redis-$REDIS_VERSION.tar.gz"
        checkCommand "解压 Redis"
        rm -f "redis-$REDIS_VERSION.tar.gz" # 删除下载的 tar 包以节省空间
    fi

    cd "$REDIS_DIR"

    # 如果 Redis 没有编译安装，执行编译和安装
    if [ ! -x "$REDIS_DIR/src/redis-server" ]; then
        make
        checkCommand "编译 Redis"
        make install
        checkCommand "安装 Redis"
    fi

    # 启动 Redis 服务器
    ./src/redis-server --daemonize yes
    checkCommand "启动 Redis"

    # 执行 Redis 配置脚本
    sh "$APP_DIR/file/redis.sh"
    echo "Redis 安装完成，路径：$REDIS_DIR"
}

# 安装 MySQL
installMysql() {
    sudo $CENTOS_PKG_MANAGER install epel-release -y
    checkCommand "安装 epel-release"
    sudo $CENTOS_PKG_MANAGER install https://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
    checkCommand "安装 remi-release"
    sudo $CENTOS_PKG_MANAGER-config-manager --enable remi -y
    sudo $CENTOS_PKG_MANAGER localinstall https://repo.mysql.com//mysql80-community-release-el7-1.noarch.rpm -y
    checkCommand "安装 MySQL 源"
    rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
    sudo $CENTOS_PKG_MANAGER install mysql-community-server -y
    checkCommand "安装 MySQL"
    sudo systemctl start mysqld
    sudo systemctl enable mysqld
}

# 安装 Nginx
installNginx() {
    sudo $CENTOS_PKG_MANAGER install $NGINX_DEPENDENCIES -y

    checkCommand "安装 Nginx 依赖包"

    if [ ! -d "/usr/local/pcre-$PCRE_VERSION" ]; then
        cd /usr/local
        wget "$PCRR_DOWNLOAD_URL"
        tar zxvf "pcre-$PCRE_VERSION.tar.gz"
        cd "pcre-$PCRE_VERSION"
        ./configure
        make
        make install
        checkCommand "安装 pcre"
    fi

    cd "/usr/local/pcre-$PCRE_VERSION"
    pcre-config --version

    if [ ! -d "/usr/local/nginx-$NGINX_VERSION" ]; then
        cd /usr/local
        wget "$NGINX_DOWNLOAD_URL"
        tar zxvf "nginx-$NGINX_VERSION.tar.gz"
        cd "nginx-$NGINX_VERSION"
        ./configure --prefix=/usr/local/nginx --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module "--with-pcre=/usr/local/$PCRE_VERSION" --with-stream
        make
        make install
        checkCommand "安装 Nginx"
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

# 安装 Docker
installDocker() {
    if command -v docker &> /dev/null; then
        echo "Docker 已安装，版本：$(docker --version)"
        return 0
    fi

    echo "Docker 未安装，开始安装 Docker..."
    
    # 卸载旧版本
    sudo $CENTOS_PKG_MANAGER remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine -y

    # 使用全局变量安装依赖包
    sudo $CENTOS_PKG_MANAGER install -y $DOCKER_DEPENDENCIES
    checkCommand "安装 Docker 依赖包"

    # 使用全局变量添加 Docker 官方仓库
    sudo yum-config-manager --add-repo "$DOCKER_REPO_URL"
    checkCommand "添加 Docker 仓库"

    # 安装 Docker CE
    sudo $CENTOS_PKG_MANAGER install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    checkCommand "安装 Docker CE"

    # 启动并启用 Docker 服务
    sudo systemctl start docker
    sudo systemctl enable docker
    checkCommand "启动 Docker 服务"

    # 将当前用户添加到 docker 组
    sudo usermod -aG docker $USER
    checkCommand "添加用户到 docker 组"

    # 配置 Docker 镜像加速器
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://registry.cn-shanghai.aliyuncs.com",
    "https://registry.cn-beijing.aliyuncs.com",
    "https://registry.cn-shenzhen.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

    # 重启 Docker 服务
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    checkCommand "重启 Docker 服务"

    echo "Docker 安装完成！"
    echo "注意：请重新登录终端以使用户组变更生效，或运行 'newgrp docker'"
    docker --version
}

# 主菜单函数
main_menu() {
    while true; do
        OPTION=$(whiptail \
            --title "《Environment》" \
            --menu "$SYSTEM_VERSION" \
            20 70 10 \
            "1" "安装node" \
            "2" "安装chromium" \
            "3" "安装redis" \
            "4" "安装mysql" \
            "5" "安装nginx" \
            "6" "安装docker" \
            3>&1 1>&2 2>&3)

        feedback=$?
        if [ $feedback = 0 ]; then
            case $OPTION in
            1)
                installNode
                read -p "Node完成安装!回车并继续Enter..." Enter
                ;;
            2)
                installChromium
                read -p "Chromium完成安装!回车并继续Enter..." Enter
                ;;
            3)
                installRedis
                read -p "Redis完成安装!回车并继续Enter..." Enter
                ;;
            4)
                installMysql
                read -p "MySQL完成安装!回车并继续Enter..." Enter
                ;;
            5)
                installNginx
                read -p "NGINX完成安装!回车并继续Enter..." Enter
                ;;
            6)
                installDocker
                read -p "Docker完成安装!回车并继续Enter..." Enter
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
