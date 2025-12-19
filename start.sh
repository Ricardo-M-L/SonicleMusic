#!/bin/bash

# SonicleMusic 一键启动脚本
# 前端: React (端口 3000, HTTPS)
# 后端: NeteaseCloudMusicApi (端口 4000)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRONT_DIR="$SCRIPT_DIR/front"
BACKEND_DIR="$SCRIPT_DIR/backen"

# 日志文件
FRONT_LOG="$SCRIPT_DIR/front.log"
BACKEND_LOG="$SCRIPT_DIR/backend.log"

# Node.js 兼容版本
REQUIRED_NODE_VERSION="18"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 加载 nvm
load_nvm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# 检查并设置 Node.js 版本
setup_node() {
    load_nvm

    local current_version=$(node --version 2>/dev/null | sed 's/v//' | cut -d'.' -f1)

    # 检查当前版本是否兼容 (Node 16)
    if [[ "$current_version" == "16" ]]; then
        print_status "当前 Node.js 版本 v$current_version 兼容"
        return 0
    fi

    print_warning "当前 Node.js v$current_version 版本不兼容，需要 Node 16"

    # 检查是否有 nvm
    if ! command -v nvm &> /dev/null; then
        print_error "未检测到 nvm，请手动安装 Node.js 16 或使用 nvm 管理版本"
        print_error "安装 nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
        return 1
    fi

    # 检查是否已安装 Node 16
    if nvm ls 16 2>/dev/null | grep -q "v16"; then
        print_status "切换到 Node.js 16..."
        nvm use 16
    else
        print_status "正在安装 Node.js 16..."
        nvm install 16
        nvm use 16
    fi

    print_status "Node.js 版本: $(node --version)"
}

# 检查端口是否被占用
check_port() {
    local port=$1
    if lsof -i:$port > /dev/null 2>&1; then
        return 0  # 端口被占用
    else
        return 1  # 端口空闲
    fi
}

# 安装依赖
install_deps() {
    local dir=$1
    local name=$2

    if [ ! -d "$dir/node_modules" ]; then
        print_status "正在为 $name 安装依赖..."
        cd "$dir" || return 1
        npm install --legacy-peer-deps
        cd "$SCRIPT_DIR" || return 1
    fi
}

# 启动服务
start_services() {
    print_status "=== SonicleMusic 启动 ==="

    # 检查并设置 Node.js 版本
    if ! setup_node; then
        print_error "Node.js 版本设置失败，请手动处理"
        return 1
    fi

    # 检查端口
    if check_port 4000; then
        print_warning "端口 4000 已被占用，后端可能已在运行"
    fi

    if check_port 3000; then
        print_warning "端口 3000 已被占用，前端可能已在运行"
    fi

    # 安装依赖
    install_deps "$BACKEND_DIR" "后端"
    install_deps "$FRONT_DIR" "前端"

    # 启动后端
    if ! check_port 4000; then
        print_status "启动后端服务 (端口 4000)..."
        cd "$BACKEND_DIR" || return 1
        PORT=4000 nohup node app.js > "$BACKEND_LOG" 2>&1 &
        cd "$SCRIPT_DIR" || return 1
        sleep 2

        if check_port 4000; then
            print_status "后端服务启动成功 ✓"
        else
            print_error "后端服务启动失败，请检查日志: $BACKEND_LOG"
        fi
    fi

    # 启动前端
    if ! check_port 3000; then
        print_status "启动前端服务 (端口 3000, HTTPS)..."
        cd "$FRONT_DIR" || return 1
        nohup npm start > "$FRONT_LOG" 2>&1 &
        cd "$SCRIPT_DIR" || return 1
        sleep 3

        print_status "前端服务启动中..."
        print_warning "首次启动可能需要较长时间编译"
    fi

    echo ""
    print_status "=== 服务地址 ==="
    echo -e "  前端页面: ${GREEN}https://localhost:3000${NC}"
    echo -e "  后端 API: ${GREEN}http://localhost:4000${NC}"
    echo ""
    print_warning "提示: 前端使用 HTTPS，浏览器可能提示证书不受信任，请点击'继续访问'"
    echo ""
    print_status "查看日志:"
    echo "  前端日志: tail -f $FRONT_LOG"
    echo "  后端日志: tail -f $BACKEND_LOG"
}

# 停止服务
stop_services() {
    print_status "=== 停止 SonicleMusic 服务 ==="

    # 停止前端 (端口 3000)
    if check_port 3000; then
        print_status "停止前端服务 (端口 3000)..."
        lsof -ti:3000 | xargs kill -9 2>/dev/null
        print_status "前端服务已停止 ✓"
    else
        print_warning "前端服务未运行"
    fi

    # 停止后端 (端口 4000)
    if check_port 4000; then
        print_status "停止后端服务 (端口 4000)..."
        lsof -ti:4000 | xargs kill -9 2>/dev/null
        print_status "后端服务已停止 ✓"
    else
        print_warning "后端服务未运行"
    fi

    print_status "所有服务已停止"
}

# 查看服务状态
show_status() {
    print_status "=== SonicleMusic 服务状态 ==="

    echo -n "后端服务 (端口 4000): "
    if check_port 4000; then
        echo -e "${GREEN}运行中${NC}"
        lsof -i:4000 | grep LISTEN
    else
        echo -e "${RED}未运行${NC}"
    fi

    echo ""
    echo -n "前端服务 (端口 3000): "
    if check_port 3000; then
        echo -e "${GREEN}运行中${NC}"
        lsof -i:3000 | grep LISTEN
    else
        echo -e "${RED}未运行${NC}"
    fi
}

# 查看日志
show_logs() {
    local service=$1

    case $service in
        front|frontend)
            if [ -f "$FRONT_LOG" ]; then
                tail -f "$FRONT_LOG"
            else
                print_error "前端日志文件不存在"
            fi
            ;;
        back|backend)
            if [ -f "$BACKEND_LOG" ]; then
                tail -f "$BACKEND_LOG"
            else
                print_error "后端日志文件不存在"
            fi
            ;;
        *)
            print_status "同时显示前后端日志 (Ctrl+C 退出)"
            tail -f "$FRONT_LOG" "$BACKEND_LOG"
            ;;
    esac
}

# 重启服务
restart_services() {
    stop_services
    sleep 2
    start_services
}

# 显示帮助
show_help() {
    echo "SonicleMusic 一键启动脚本"
    echo ""
    echo "用法: $0 <命令>"
    echo ""
    echo "命令:"
    echo "  start     启动所有服务"
    echo "  stop      停止所有服务"
    echo "  restart   重启所有服务"
    echo "  status    查看服务状态"
    echo "  logs      查看所有日志"
    echo "  logs front    查看前端日志"
    echo "  logs backend  查看后端日志"
    echo "  help      显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start      # 启动服务"
    echo "  $0 stop       # 停止服务"
    echo "  $0 status     # 查看状态"
}

# 主入口
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac
