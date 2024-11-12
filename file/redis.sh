#!/bin/bash

centosRedisV='6.2.13'
REDIS_USER="redis"
REDIS_GROUP="redis"
REDIS_SERVER="/visible/file/redis-$centosRedisV/redis-server"
REDIS_CONF="/visible/file/redis-$centosRedisV/redis.conf"

# 创建 Redis systemd 单元文件
cat > /etc/systemd/system/redis.service <<EOF
[Unit]
Description=Redis Server
After=network.target

[Service]
ExecStart=${REDIS_SERVER} ${REDIS_CONF}
ExecStop=${REDIS_SERVER} stop
User=${REDIS_USER}
Group=${REDIS_GROUP}
Restart=always

[Install]
WantedBy=multi-user.target
EOF


##更新环境
source /etc/profile

# 重新加载 systemd 配置
systemctl daemon-reload

# 启用 Redis 的开机自启动
systemctl enable redis

# 启动 Redis 服务
systemctl start redis
