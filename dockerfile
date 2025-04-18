FROM rockylinux:9

# 设置时区
ENV TZ=Asia/Shanghai

# 安装EPEL和基础工具
RUN dnf install -y epel-release && \
    dnf install -y dnf-utils && \
    dnf config-manager --set-enabled crb && \
    dnf clean all && \
    dnf makecache

# 安装基础包
RUN dnf update -y && \
    dnf install -y --allowerasing \
    curl \
    gnupg \
    wget \
    git \
    nano \
    sudo \
    supervisor \
    unzip \
    ca-certificates \
    postgresql-server \
    postgresql-contrib \
    nginx \
    redis \
    golang && \
    dnf clean all

# 初始化PostgreSQL
RUN postgresql-setup --initdb && \
    systemctl enable postgresql

# 配置PostgreSQL
RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf && \
    sed -i "s/ident/md5/g" /var/lib/pgsql/data/pg_hba.conf && \
    echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/data/pg_hba.conf

# 设置Go环境
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin
RUN go env -w GO111MODULE=on && \
    go env -w GOPROXY=https://goproxy.cn,direct

# 创建工作目录
RUN mkdir -p /thingspanel
WORKDIR /thingspanel

# 克隆ThingsPanel项目
RUN git clone https://github.com/ThingsPanel/thingspanel-gmqtt.git && \
    git clone https://github.com/ThingsPanel/thingspanel-backend-community.git

# 下载ThingsPanel前端
RUN mkdir -p /thingspanel/frontend && \
    cd /thingspanel/frontend && \
    wget -O dist.tar.gz https://github.com/ThingsPanel/thingspanel-frontend-community/releases/download/latest/dist.tar.gz && \
    tar -xzf dist.tar.gz && \
    rm dist.tar.gz

# 初始化PostgreSQL数据库
RUN su postgres -c "pg_ctl start -D /var/lib/pgsql/data" && \
    su postgres -c "createdb ThingsPanel" && \
    su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgresThingsPanel';\"" && \
    su postgres -c "pg_ctl stop -D /var/lib/pgsql/data"

# 配置Redis
RUN sed -i 's/# requirepass foobared/requirepass redis/g' /etc/redis/redis.conf && \
    sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf

# 配置Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 编译GMQTT
RUN cd /thingspanel/thingspanel-gmqtt/cmd/gmqttd && \
    go build -o gmqttd

# 编译Backend
RUN cd /thingspanel/thingspanel-backend-community && \
    go build -o thingspanel-backend

# 复制配置文件
COPY gmqtt_config.yml /thingspanel/thingspanel-gmqtt/cmd/gmqttd/default_config.yml
COPY thingspanel.yml /thingspanel/thingspanel-gmqtt/cmd/gmqttd/thingspanel.yml
COPY backend_config.yml /thingspanel/thingspanel-backend-community/configs/conf.yml

# 配置Supervisor
COPY supervisord.conf /etc/supervisord.d/thingspanel.ini

# 开放端口
EXPOSE 80 1883 8883 9999

# 启动脚本
COPY start.sh /thingspanel/start.sh
RUN chmod +x /thingspanel/start.sh

CMD ["/thingspanel/start.sh"]