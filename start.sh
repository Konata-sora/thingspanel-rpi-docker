#!/bin/sh

# 启动PostgreSQL
su postgres -c "pg_ctl start -D /var/lib/postgresql/data"

# 启动Redis
redis-server /etc/redis/redis.conf &

# 启动Nginx
nginx

# 使用Supervisor管理GMQTT和Backend服务
/usr/bin/supervisord -c /etc/supervisord.conf

# 保持容器运行
tail -f /dev/null
