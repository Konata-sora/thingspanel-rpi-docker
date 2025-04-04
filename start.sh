#!/bin/bash

# 启动PostgreSQL
su postgres -c "/usr/pgsql-14/bin/pg_ctl start -D /var/lib/pgsql/14/data"

# 启动Redis
redis-server /etc/redis/redis.conf &

# 启动Nginx
nginx

# 使用Supervisor管理GMQTT和Backend服务
/usr/bin/supervisord -c /etc/supervisord.conf

# 保持容器运行
tail -f /dev/null
