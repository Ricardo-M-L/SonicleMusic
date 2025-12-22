# SonicleMusic - 律动音乐

一个高仿网易云音乐网页版的音乐播放器项目。

## 项目简介

SonicleMusic 是一个基于 React + TypeScript 的网易云音乐网页版仿写项目，后端采用 [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) 提供数据接口支持。

> 本项目仅供学习使用，不作任何商业用途。

## 技术栈

### 前端
- React 17 + TypeScript
- Redux + React-Redux (状态管理)
- React Router DOM (路由管理)
- Less (CSS 预处理)
- Axios (HTTP 请求)

### 后端
- Node.js + Express
- NeteaseCloudMusicApi

## 项目结构

```
SonicleMusic/
├── front/              # 前端项目 (React)
│   ├── src/            # 源代码
│   ├── public/         # 静态资源
│   └── package.json
├── backen/             # 后端项目 (NeteaseCloudMusicApi)
│   ├── module/         # API 模块
│   ├── util/           # 工具函数
│   └── package.json
├── start.sh            # 一键启动脚本
└── README.md
```

## 快速开始

### 环境要求

- Node.js 16.x (推荐使用 nvm 管理版本)
- npm 或 yarn

### 一键启动

项目提供了一键启动脚本，可以同时启动前端和后端服务：

```bash
# 启动所有服务
./start.sh start

# 停止所有服务
./start.sh stop

# 重启所有服务
./start.sh restart

# 查看服务状态
./start.sh status

# 查看日志
./start.sh logs           # 查看所有日志
./start.sh logs front     # 查看前端日志
./start.sh logs backend   # 查看后端日志
```

### 手动启动

#### 启动后端

```bash
cd backen
npm install
npm start
# 后端运行在 http://localhost:4000
```

#### 启动前端

```bash
cd front
npm install

# HTTPS 模式 (默认)
npm start
# 前端运行在 https://localhost:3000

# HTTP 模式
npm run start-http
# 前端运行在 http://localhost:3000
```

## 功能特性

- 登录功能 (二维码登录、验证码登录、手机密码登录、邮箱登录)
- 音乐播放器 (进度条、播放列表、歌词展示、快进、切歌、音量调节)
- 视频播放器 (进度条、分辨率切换、全屏)
- 音乐搜索
- 评论展示
- 首页推荐
- 排行榜
- 歌单/专辑/歌手页面
- 个人主页
- 签到、点赞等交互功能

## 服务地址

| 服务 | 地址 | 说明 |
|------|------|------|
| 前端 | https://localhost:3000 | HTTPS 模式，浏览器可能提示证书不受信任 |
| 后端 API | http://localhost:4000 | API 接口服务 |

## 开发说明

### 修改 API 地址

前端 API 地址配置在：`front/src/network/constant.ts` -> `BASE_URL`

### 性能测试

在浏览器控制台调用 `window.testPerformance()` 可以打印当前性能状况。

## 已知问题

- 频繁切换音频可能导致控制台报错
- 播放器切歌在某些情况下可能无法切换
- 评论按时间排序分页存在问题

## License

MIT

## 致谢

- [NeteaseCloudMusicApi](https://github.com/Binaryify/NeteaseCloudMusicApi) - 网易云音乐 API

