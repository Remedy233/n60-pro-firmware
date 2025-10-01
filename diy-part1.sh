#!/bin/bash
#
# DIY Part 1 - Feeds 更新前执行的自定义脚本
# 在 feeds 更新之前执行
# 基于 ImmortalWrt MT798x，集成 iStoreOS 特性
#

echo "=== 执行 DIY Part 1 脚本 ==="
echo "添加 iStoreOS 相关源..."

# 检查并添加 iStore 应用商店源（避免重复）
if ! grep -q "src-git istore" feeds.conf.default; then
    echo "src-git istore https://github.com/linkease/istore.git;main" >> feeds.conf.default
    echo "已添加 iStore 源"
fi

# 检查并添加 iStoreOS packages 源（包含 quickstart 等核心组件）
if ! grep -q "src-git istoreos_packages" feeds.conf.default; then
    echo "src-git istoreos_packages https://github.com/istoreos/istoreos.git;istoreos-24.10" >> feeds.conf.default
    echo "已添加 iStoreOS packages 源"
fi

# 添加常用插件源（可选，按需取消注释）
# sed -i '$a src-git helloworld https://github.com/fw876/helloworld.git' feeds.conf.default
# sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall.git' feeds.conf.default
# sed -i '$a src-git openclash https://github.com/vernesong/OpenClash.git;master' feeds.conf.default

echo "DIY Part 1 执行完成"
