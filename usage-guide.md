# 在树莓派上部署ThingsPanel的详细指南

这个指南将帮助您在树莓派上使用Docker镜像快速部署ThingsPanel物联网平台。

## 系统要求

- 树莓派4（2GB RAM以上）或更高版本
- 树莓派OS (64位)
- 至少16GB的SD卡
- 网络连接

## 安装步骤

### 1. 准备树莓派

确保您的树莓派已更新：

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. 安装Docker和Docker Compose

```bash
# 安装Docker
curl -sSL https://get.docker.com | sh

# 将当前用户添加到docker组
sudo usermod -aG docker $USER

# 重新登录以应用更改
# 注销并重新登录，或者执行：
newgrp docker

# 安装Docker Compose
sudo apt-get install -y docker-compose
```

### 3. 创建项目目录

```bash
mkdir -p ~/thingspanel
cd ~/thingspanel
```

### 4. 下载所有必要文件

将本文档提供的所有文件保存到`~/thingspanel`目录中。包括以下文件：

- `Dockerfile`
- `docker-compose.yml`
- `nginx.conf`
- `start.sh`
- `supervisord.conf`
- `gmqtt_config.yml`
- `thingspanel.yml`
- `backend_config.yml`

### 5. 设置文件权限

```bash
chmod +x start.sh
```

### 6. 构建和启动ThingsPanel

```bash
# 构建镜像
docker-compose build

# 启动容器
docker-compose up -d
```

构建过程可能需要20-30分钟，取决于您的网络连接和树莓派型号。

### 7. 验证部署

容器启动后，等待约2-3分钟让所有服务初始化，然后打开浏览器访问：

```
http://your-raspberry-pi-ip
```

您应该能看到ThingsPanel的登录界面。

## 登录信息

- **系统管理员**：
  - 用户名：super@super.cn
  - 密码：123456

- **租户管理员**：
  - 用户名：tenant@tenant.cn
  - 密码：123456

## 常见问题解决

### 查看容器运行状态

```bash
docker ps
```

### 查看容器日志

```bash
docker logs thingspanel-all-in-one
```

### 检查服务日志

```bash
# GMQTT日志
docker exec thingspanel-all-in-one cat /var/log/gmqtt.out.log

# 后端日志
docker exec thingspanel-all-in-one cat /var/log/backend.out.log
```

### 重启容器

```bash
docker-compose restart
```

### 停止和删除容器

```bash
docker-compose down
```

### 数据持久化

所有数据存储在Docker卷中，即使重新创建容器也不会丢失。如需备份数据：

```bash
# 备份PostgreSQL数据
docker exec thingspanel-all-in-one pg_dump -U postgres ThingsPanel > thingspanel_backup.sql

# 恢复PostgreSQL数据
cat thingspanel_backup.sql | docker exec -i thingspanel-all-in-one psql -U postgres -d ThingsPanel
```

## 连接MQTT设备

设备可以通过以下方式连接到ThingsPanel：

- MQTT Broker地址：your-raspberry-pi-ip
- MQTT端口：1883
- MQTT用户名：root
- MQTT密码：root

## 安全建议

对于生产环境，建议修改默认密码：

1. 修改`thingspanel.yml`中的MQTT密码
2. 修改`backend_config.yml`中的数据库密码
3. 重新构建并启动容器

## 系统结构

此镜像包含以下组件：

- **Nginx**：Web服务器，提供前端访问和API代理
- **PostgreSQL/TimescaleDB**：时序数据库，存储设备数据
- **Redis**：缓存服务，提高系统性能
- **GMQTT**：MQTT消息服务器，处理设备通信
- **ThingsPanel后端**：业务逻辑和API服务
- **ThingsPanel前端**：用户界面

所有组件都在同一容器中运行，简化了部署和维护过程。
