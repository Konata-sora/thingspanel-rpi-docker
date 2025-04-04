FROM ubuntu:22.04

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 设置时区
ENV TZ=Asia/Shanghai

# 安装基础软件包
RUN apt-get update && apt-get install -y \
    apt-utils \
    curl \
    wget \
    git \
    nano \
    nginx \
    redis-server \
    postgresql \
    postgresql-contrib \
    sudo \
    supervisor \
    unzip

# 安装Go 1.22
RUN wget https://go.dev/dl/go1.22.0.linux-arm64.tar.gz && \
    tar -C /usr/local -xzf go1.22.0.linux-arm64.tar.gz && \
    rm go1.22.0.linux-arm64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# 设置Go环境
RUN go env -w GO111MODULE=on && \
    go env -w GOPROXY=https://goproxy.cn,direct

# 创建工作目录
RUN mkdir -p /thingspanel
WORKDIR /thingspanel

# 克隆ThingsPanel项目
RUN git clone https://github.com/ThingsPanel/thingspanel-gmqtt.git && \
    git clone https://github.com/ThingsPanel/thingspanel-backend-community.git

# 下载ThingsPanel前端 - 使用正确的URL
RUN mkdir -p /thingspanel/frontend && \
    cd /thingspanel/frontend && \
    wget -O dist.tar.gz https://github.com/ThingsPanel/thingspanel-frontend-community/releases/download/latest/dist.tar.gz && \
    tar -xzf dist.tar.gz && \
    rm dist.tar.gz

# 配置PostgreSQL和TimescaleDB
RUN service postgresql start && \
    sudo -u postgres psql -c "CREATE DATABASE \"ThingsPanel\";" && \
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgresThingsPanel';" && \
    sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS timescaledb;" -d "ThingsPanel"

# 配置Redis
RUN sed -i 's/# requirepass foobared/requirepass redis/g' /etc/redis/redis.conf

# 配置Nginx
COPY nginx.conf /etc/nginx/sites-available/thingspanel
RUN ln -sf /etc/nginx/sites-available/thingspanel /etc/nginx/sites-enabled/default

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
COPY supervisord.conf /etc/supervisor/conf.d/thingspanel.conf

# 开放端口
EXPOSE 80 1883 8883 9999

# 启动脚本
COPY start.sh /thingspanel/start.sh
RUN chmod +x /thingspanel/start.sh

CMD ["/thingspanel/start.sh"]
