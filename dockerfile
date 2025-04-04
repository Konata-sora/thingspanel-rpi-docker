FROM alpine:3.19

# 设置时区
ENV TZ=Asia/Shanghai

# 安装基础包
RUN apk update && \
    apk add --no-cache \
    bash \
    curl \
    gnupg \
    wget \
    git \
    nano \
    sudo \
    supervisor \
    unzip \
    ca-certificates \
    postgresql14 \
    postgresql14-contrib \
    nginx \
    redis \
    tzdata \
    go

# 设置PostgreSQL数据目录
ENV PGDATA=/var/lib/postgresql/data

# 初始化PostgreSQL
RUN mkdir -p ${PGDATA} && \
    chown -R postgres:postgres ${PGDATA} && \
    su postgres -c "initdb -D ${PGDATA}" && \
    echo "host all all 0.0.0.0/0 md5" >> ${PGDATA}/pg_hba.conf && \
    echo "listen_addresses='*'" >> ${PGDATA}/postgresql.conf

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
RUN su postgres -c "pg_ctl start -D ${PGDATA}" && \
    su postgres -c "createdb ThingsPanel" && \
    su postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'postgresThingsPanel';\"" && \
    su postgres -c "pg_ctl stop -D ${PGDATA}"

# 配置Redis
RUN sed -i 's/# requirepass foobared/requirepass redis/g' /etc/redis/redis.conf

# 配置Nginx
COPY nginx.conf /etc/nginx/http.d/default.conf

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
COPY supervisord.conf /etc/supervisor.d/thingspanel.ini

# 开放端口
EXPOSE 80 1883 8883 9999

# 启动脚本
COPY start.sh /thingspanel/start.sh
RUN chmod +x /thingspanel/start.sh

CMD ["/thingspanel/start.sh"]