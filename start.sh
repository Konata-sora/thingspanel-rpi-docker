#!/bin/bash

# 启动PostgreSQL
service postgresql start

# 启动Redis
service redis-server start

# 启动Nginx
service nginx start

# 使用Supervisor管理GMQTT和Backend服务
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# 保持容器运行
tail -f /dev/null
