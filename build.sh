#!/bin/bash
#
# 磊科 N60 Pro iStoreOS 固件自动编译脚本
# 基于 ImmortalWrt MT798x 6.6 + iStoreOS
#

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置变量
REPO_URL="https://github.com/padavanonly/immortalwrt-mt798x-6.6.git"
REPO_BRANCH="openwrt-24.10-6.6"
WORK_DIR="immortalwrt-mt798x"
CONFIG_FILE="n60-pro.config"
DIY_P1_SH="diy-part1.sh"
DIY_P2_SH="diy-part2.sh"

# 打印信息函数
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 未安装，请先安装必要的依赖"
        return 1
    fi
    return 0
}

# 检查系统依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
    local deps=("git" "make" "gcc" "g++" "python3")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! check_command "$dep"; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_error "缺少依赖: ${missing[*]}"
        print_info "Ubuntu/Debian 系统请运行："
        echo "sudo apt update && sudo apt install -y build-essential clang flex bison g++ gawk gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev python3-distutils rsync unzip zlib1g-dev file wget"
        exit 1
    fi
    
    print_info "系统依赖检查通过"
}

# 克隆源码
clone_source() {
    print_info "准备源码..."
    
    if [ -d "$WORK_DIR" ]; then
        print_warn "$WORK_DIR 目录已存在"
        read -p "是否删除并重新克隆? (y/N): " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            rm -rf "$WORK_DIR"
        else
            print_info "使用现有源码目录"
            return 0
        fi
    fi
    
    print_info "克隆 ImmortalWrt MT798x 源码..."
    git clone -b "$REPO_BRANCH" --single-branch --filter=blob:none "$REPO_URL" "$WORK_DIR"
    
    if [ $? -ne 0 ]; then
        print_error "源码克隆失败"
        exit 1
    fi
    
    print_info "源码克隆完成"
}

# 更新 feeds
update_feeds() {
    print_info "更新和安装 feeds..."
    
    cd "$WORK_DIR"
    
    # 执行自定义脚本 Part 1
    if [ -f "../$DIY_P1_SH" ]; then
        print_info "执行自定义脚本 Part 1..."
        chmod +x "../$DIY_P1_SH"
        bash "../$DIY_P1_SH"
    fi
    
    # 更新 feeds
    ./scripts/feeds update -a
    if [ $? -ne 0 ]; then
        print_error "Feeds 更新失败"
        exit 1
    fi
    
    # 安装 feeds
    ./scripts/feeds install -a
    if [ $? -ne 0 ]; then
        print_error "Feeds 安装失败"
        exit 1
    fi
    
    print_info "Feeds 更新完成"
    cd ..
}

# 加载配置
load_config() {
    print_info "加载设备配置..."
    
    cd "$WORK_DIR"
    
    # 执行自定义脚本 Part 2
    if [ -f "../$DIY_P2_SH" ]; then
        print_info "执行自定义脚本 Part 2..."
        chmod +x "../$DIY_P2_SH"
        bash "../$DIY_P2_SH"
    fi
    
    # 复制配置文件
    if [ -f "../$CONFIG_FILE" ]; then
        print_info "应用配置文件: $CONFIG_FILE"
        cp "../$CONFIG_FILE" .config
    else
        print_warn "配置文件不存在，使用默认配置"
        make defconfig
    fi
    
    # 下载依赖
    print_info "下载编译依赖..."
    make defconfig
    make download -j8
    
    # 检查下载完整性
    find dl -size -1024c -exec ls -l {} \;
    find dl -size -1024c -exec rm -f {} \;
    
    cd ..
}

# 开始编译
start_compile() {
    print_info "开始编译固件..."
    print_warn "首次编译可能需要 2-6 小时，请耐心等待..."
    
    cd "$WORK_DIR"
    
    # 获取 CPU 核心数
    THREAD_COUNT=$(nproc)
    print_info "使用 $THREAD_COUNT 线程编译"
    
    # 开始编译
    make -j$((THREAD_COUNT + 1)) V=s
    
    if [ $? -ne 0 ]; then
        print_error "编译失败，尝试单线程编译..."
        make -j1 V=s
        
        if [ $? -ne 0 ]; then
            print_error "单线程编译也失败了"
            cd ..
            exit 1
        fi
    fi
    
    cd ..
    print_info "编译完成！"
}

# 显示结果
show_result() {
    print_info "编译结果："
    
    FIRMWARE_PATH="$WORK_DIR/bin/targets/mediatek/mt7981"
    
    if [ -d "$FIRMWARE_PATH" ]; then
        echo ""
        echo "固件位置: $FIRMWARE_PATH"
        echo ""
        ls -lh "$FIRMWARE_PATH"/*.bin 2>/dev/null || print_warn "未找到固件文件"
        echo ""
        print_info "请在上述目录中查找固件文件"
    else
        print_warn "未找到固件输出目录"
    fi
}

# 清理编译
clean_build() {
    print_warn "清理编译环境..."
    
    if [ -d "$WORK_DIR" ]; then
        cd "$WORK_DIR"
        make clean
        cd ..
        print_info "清理完成"
    else
        print_warn "源码目录不存在"
    fi
}

# 深度清理
distclean_build() {
    print_warn "深度清理编译环境..."
    
    if [ -d "$WORK_DIR" ]; then
        read -p "这将删除所有编译文件，确定继续? (y/N): " choice
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            cd "$WORK_DIR"
            make distclean
            cd ..
            print_info "深度清理完成"
        else
            print_info "取消清理"
        fi
    else
        print_warn "源码目录不存在"
    fi
}

# 更新源码
update_source() {
    print_info "更新源码..."
    
    if [ -d "$WORK_DIR" ]; then
        cd "$WORK_DIR"
        git pull
        cd ..
        print_info "源码更新完成"
    else
        print_warn "源码目录不存在，请先执行完整编译"
    fi
}

# 显示帮助
show_help() {
    echo "磊科 N60 Pro iStoreOS 固件编译脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  (无参数)    执行完整编译流程"
    echo "  compile     仅执行编译步骤"
    echo "  update      更新源码和 feeds"
    echo "  clean       清理编译文件"
    echo "  distclean   深度清理（删除所有编译产物）"
    echo "  help        显示此帮助信息"
    echo ""
}

# 主函数
main() {
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║   磊科 N60 Pro ImmortalWrt 固件编译工具  ║"
    echo "║      基于 ImmortalWrt MT798x 6.6         ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""
    
    case "$1" in
        compile)
            start_compile
            show_result
            ;;
        update)
            update_source
            update_feeds
            ;;
        clean)
            clean_build
            ;;
        distclean)
            distclean_build
            ;;
        help)
            show_help
            ;;
        *)
            check_dependencies
            clone_source
            update_feeds
            load_config
            start_compile
            show_result
            
            echo ""
            print_info "=== 编译流程完成 ==="
            print_info "固件文件位于: $WORK_DIR/bin/targets/mediatek/mt7981/"
            echo ""
            ;;
    esac
}

# 运行主函数
main "$@"
