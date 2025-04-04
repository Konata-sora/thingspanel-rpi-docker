# ThingsPanel All-In-One Docker 镜像

![Build Status](https://github.com/yourusername/thingspanel-docker/actions/workflows/docker-publish.yml/badge.svg)
[![Docker Pulls](https://img.shields.io/docker/pulls/yourusername/thingspanel-all-in-one.svg)](https://hub.docker.com/r/yourusername/thingspanel-all-in-one)

这是一个一体化的ThingsPanel物联网平台Docker镜像，支持包括树莓派在内的多种架构。

## 支持的架构

- `linux/amd64`: 适用于标准服务器/PC
- `linux/arm64`: 适用于树莓派4（64位OS）
- `linux/arm/v7`: 适用于树莓派3和树莓派4（32位OS）

## 快速开始

### 使用Docker运行

```bash
docker run -d \
  --name thingspanel \
  -p 80:80 \
  -p 1883:1883 \
  -p 8883:8883 \
  yourusername/thingspanel-all-in-one:latest
```

### 使用Docker Compose运行

创建`docker-compose.yml`文件：

```yaml
version: '3'

services:
  thingspanel:
    image: yourusername/thingspanel-all-in-one:latest
    container_name: thingspanel
    restart: always
    ports:
      - "80:80"      # Nginx HTTP
      - "1883:1883"  # MQTT
      - "8883:8883"  # MQTT over TLS
    volumes:
      - thingspanel-data:/thingspanel/data
      - postgres-data:/var/lib/postgresql/data
      - redis-data:/var/lib/redis

volumes:
  thingspanel-data:
  postgres-data:
  redis-data:
```

然后运行：

```bash
docker-compose up -d
```

## 包含组件

- GMQTT：MQTT消息服务器
- ThingsPanel后端：平台API服务
- ThingsPanel前端：用户界面
- TimescaleDB (PostgreSQL)：数据存储
- Redis：缓存服务
- Nginx：Web服务器

## 登录信息

- **系统管理员**：
  - 用户名：super@super.cn
  - 密码：123456

- **租户管理员**：
  - 用户名：tenant@tenant.cn
  - 密码：123456

## 自行构建镜像

如果你想自行修改和构建镜像：

1. 克隆此仓库
   ```bash
   git clone https://github.com/yourusername/thingspanel-docker.git
   cd thingspanel-docker
   ```

2. 修改配置文件
   根据需要修改配置文件。

3. 构建镜像
   ```bash
   docker build -t yourusername/thingspanel-all-in-one .
   ```

### 自动构建

本仓库使用GitHub Actions自动构建多架构Docker镜像。它会在以下情况触发构建：
- 推送到main分支
- 创建新的release标签（格式为v*）
- 手动触发工作流

## 项目结构

```
├── Dockerfile                # 镜像构建文件
├── docker-compose.yml        # Docker Compose配置
├── nginx.conf                # Nginx配置
├── start.sh                  # 容器启动脚本
├── supervisord.conf          # Supervisor配置
├── gmqtt_config.yml          # GMQTT配置
├── thingspanel.yml           # ThingsPanel GMQTT插件配置
├── backend_config.yml        # 后端配置
└── .github/workflows/        # GitHub Actions工作流
    └── docker-publish.yml    # 自动构建配置
```

## 使用指南

详细的使用指南请参阅[使用指南文档](./USAGE.md)。

## 贡献

欢迎提交pull request或issue来改进这个项目。

## 许可证

此项目采用MIT许可证。ThingsPanel相关组件的许可证请参阅其各自的仓库。
