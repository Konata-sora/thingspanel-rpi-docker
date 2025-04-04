# ThingsPanel All-In-One Docker Image for Raspberry Pi

这是一个完整的ThingsPanel物联网平台的Docker镜像，特别针对树莓派ARM架构优化。该镜像包含了ThingsPanel的所有必要组件，可以让您通过简单几步在树莓派上部署完整系统。

## 包含组件

- GMQTT：MQTT消息服务器
- ThingsPanel后端：平台API服务
- ThingsPanel前端：用户界面
- TimescaleDB (PostgreSQL)：数据存储
- Redis：缓存服务
- Nginx：Web服务器

## 使用方法

### 准备

确保您的树莓派已经安装了Docker和Docker Compose:

```bash
curl -sSL https://get.docker.com | sh
sudo apt-get install -y docker-compose
```

### 构建和运行

1. 下载所有文件到一个目录中：

```bash
git clone https://github.com/yourusername/thingspanel-docker.git
cd thingspanel-docker
```

2. 构建并启动容器：

```bash
docker-compose up -d
```

3. 等待几分钟让所有服务启动完成，然后访问 `http://your-raspberry-pi-ip` 打开ThingsPanel管理界面。

### 登录凭据

- 系统管理员：super@super.cn / 123456
- 租户管理员：tenant@tenant.cn / 123456

## 持久化数据

此Docker配置使用命名卷来持久化数据：

- `thingspanel-data`: 存储GMQTT数据
- `postgres-data`: 存储TimescaleDB/PostgreSQL数据
- `redis-data`: 存储Redis数据

这确保了即使容器被删除，您的数据也不会丢失。

## 端口

- 80: Web界面 (Nginx)
- 1883: MQTT
- 8883: MQTT over TLS
- 9999: 后端API
- 8082-8084: GMQTT相关服务

## 自定义

如果需要自定义配置，可以修改以下文件然后重新构建镜像：

- `nginx.conf`: Nginx配置
- `gmqtt_config.yml`: GMQTT配置
- `thingspanel.yml`: ThingsPanel GMQTT插件配置 
- `backend_config.yml`: 后端服务配置

修改后运行 `docker-compose build` 和 `docker-compose up -d` 应用更改。

## 故障排除

查看容器日志：

```bash
docker logs thingspanel-all-in-one
```

查看特定服务日志：

```bash
# GMQTT日志
docker exec thingspanel-all-in-one cat /var/log/gmqtt.out.log

# 后端日志
docker exec thingspanel-all-in-one cat /var/log/backend.out.log
```

## 注意事项

- 此镜像专为树莓派等ARM设备设计，但也可在其他Linux系统上使用
- 初次启动可能需要几分钟才能完成所有服务的初始化
- 默认配置适用于大多数使用场景，但可能需要根据您的网络环境进行调整
