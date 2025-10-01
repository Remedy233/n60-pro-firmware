#!/bin/bash
#
# DIY Part 2 - 配置前执行的自定义脚本
# 在 feeds 安装之后、配置之前执行
# 集成 iStoreOS 特性到 ImmortalWrt MT798x
#

echo "=== 执行 DIY Part 2 脚本 ==="

# 安装 iStoreOS 核心组件
echo "安装 iStoreOS 核心组件..."

# 优先从 istore feed 安装
echo "安装 iStore 应用商店..."
./scripts/feeds install -a -p istore || echo "警告: iStore feed 安装失败，继续..."

# 从 istoreos_packages feed 安装（如果存在）
echo "安装 iStoreOS 组件..."
./scripts/feeds install -a -p istoreos_packages 2>/dev/null || echo "提示: istoreos_packages feed 未找到或安装失败"

# 手动安装关键组件（确保安装成功）
echo "安装关键组件..."
./scripts/feeds install luci-app-store || echo "警告: luci-app-store 安装失败"
./scripts/feeds install quickstart 2>/dev/null || echo "提示: quickstart 未找到"
./scripts/feeds install luci-app-quickstart 2>/dev/null || echo "提示: luci-app-quickstart 未找到"
./scripts/feeds install taskd 2>/dev/null || echo "提示: taskd 未找到"
./scripts/feeds install istoreos-files 2>/dev/null || echo "提示: istoreos-files 未找到"

# 修改默认 IP（可选）
# sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# 修改默认主机名和时区（通过 uci-defaults 实现，更可靠）
# 注意：不直接修改 config_generate，因为不同版本路径可能不同

# 安装常用网络工具
echo "安装常用插件..."
./scripts/feeds install -a luci-app-upnp
./scripts/feeds install -a luci-app-ddns
./scripts/feeds install -a luci-app-ttyd

# 存储和文件共享
./scripts/feeds install -a luci-app-samba4

# 删除冲突的包（如果有）
rm -rf feeds/luci/applications/luci-app-dockerman 2>/dev/null

# 添加自定义文件到固件
mkdir -p files/etc/uci-defaults

# 创建首次启动配置
cat > files/etc/uci-defaults/99-istoreos-init << 'EOF'
#!/bin/sh
# iStoreOS 初始化配置
uci set system.@system[0].hostname='iStoreOS'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 启用 QuickStart
/etc/init.d/quickstart enable
/etc/init.d/taskd enable

exit 0
EOF

chmod +x files/etc/uci-defaults/99-istoreos-init

echo "DIY Part 2 执行完成"
