#!/bin/bash

source /visible/globals.sh

cd "$USER_BASE_DIR"

while true
do
	OPTION=$(whiptail \
		--title "《Env Deploy》" \
		--menu "$SYSTEM_VERSION" \
		15 50 5 \
		"0" "刷新环境" \
		"1" "安装node" \
		"2" "安装MySql" \
		"3" "安装redis" \
		"4" "安装pcre" \
		"5" "安装Nginx" \
	3>&1 1>&2 2>&3)
	feedback=$?
	if [ $feedback = 0 ]; then
		if [ $OPTION = 0 ]; then
			source /etc/profile
			read -p "环境已刷新!回车并继续Enter..." Enter
		fi

		if [ $OPTION = 1 ]; then
			wget -P "$USER_BASE_DIR" https://repo.huaweicloud.com/nodejs/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCHITECTURE.tar.gz
			mkdir "/usr/local/node-v$NODE_VERSION"
			tar zxvf "$USER_BASE_DIR/node-v$NODE_VERSION-linux-$ARCHITECTURE.tar.gz" --strip-components 1 -C "/usr/local/node-v$NODE_VERSION"
                	echo -e '#node v16.20.0\nexport PATH=/usr/local/node-v16.20.0/bin:$PATH' >/etc/profile.d/node.sh
			chmod +x /etc/profile.d/node.sh
			source /etc/profile.d/node.sh
			source /etc/profile
			ln -sfn "/usr/local/node-v$NODE_VERSION/bin/*" /usr/local/bin
			rm -rf "$USER_BASE_DIR/node-v$NODE_VERSION-linux-$ARCHITECTURE.tar.gz"
			read -p "完成nodejs安装回车并继续Enter..." Enter
		fi

		if [ $OPTION = 2 ]; then
			wget -P "$USER_BASE_DIR" https://repo.mysql.com/mysql-apt-config_0.8.30-1_all.deb
			cd "$USER_BASE_DIR"
			dpkg -i mysql-apt-config_0.8.30-1_all.deb
			apt update -y
			apt install mysql-server -y
			rm -rf "$USER_BASE_DIR/mysql-apt-config_0.8.30-1_all.deb"
			read -p "完成mysql安装回车并继续Enter..." Enter
		fi

		if [ $OPTION = 3 ]; then
			apt install build-essential tcl -y
			if [ ! -d "$APP_DIR/file/redis-$REDIS_VERSION" ]; then
				cd "$APP_DIR/file"
				wget "https://mirrors.huaweicloud.com/redis/redis-$REDIS_VERSION.tar.gz"
				tar zxvf "redis-$REDIS_VERSION.tar.gz"
			fi

			cd "$APP_DIR/file/redis-$REDIS_VERSION"
			if [ ! -x "$APP_DIR/file/redis-$REDIS_VERSION/src/redis-server" ]; then
				make && make install
			fi

			./src/redis-server --daemonize yes
			bash "$APP_DIR/file/redis.sh"
			echo "$APP_DIR/file/redis-$REDIS_VERSION"

			read -p "完成Redis安装!回车并继续Enter..." Enter
		fi

		if [ $OPTION = 4 ]; then
			apt install libpcre3 libpcre3-dev -y
			read -p "完成Pcre安装!回车并继续Enter..." Enter
		fi

		if [ $OPTION = 5 ]; then
			apt install build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev -y
			if [ ! -d "/usr/local/nginx-$NGINX_VERSION" ]; then
				cd /usr/local/src
				wget "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
				tar zxvf "nginx-$NGINX_VERSION.tar.gz"
				cd /usr/local/src/nginx-$NGINX_VERSION
				./configure --prefix=/usr/local/nginx --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module
				make && make install
			fi
			/usr/local/nginx/sbin/nginx -v
			echo "/usr/local/nginx-$NGINX_VERSION"
			read -p "完成Nginx安装!回车并继续Enter..." Enter
		fi
		cd "$USER_BASE_DIR"
	else
		exit
	fi
done
