# 磊科 N60 Pro iStoreOS 固件编译指南

本项目用于编译磊科 N60 Pro 路由器的 iStoreOS 固件

## 项目说明

本项目基于 **ImmortalWrt MT798x** 固件（针对 MT7981B 优化），集成 **iStoreOS** 核心特性：
- ✅ iStore 应用商店
- ✅ QuickStart 快速入门向导
- ✅ iStoreOS 优化配置
- ✅ MT7981B 完整驱动支持

## 设备信息

- **设备型号**: Netcore N60 Pro (磊科)
- **处理器**: MediaTek MT7981B
- **架构**: ARM Cortex-A53 双核
- **固件基础**: ImmortalWrt MT798x + iStoreOS
- **内核版本**: 6.6

## 系统要求

### 硬件要求
- 至少 4GB RAM
- 至少 50GB 可用磁盘空间
- 稳定的网络连接

### 软件要求（Ubuntu/Debian）
```bash
sudo apt update
sudo apt install -y build-essential clang flex bison g++ gawk \
gcc-multilib g++-multilib gettext git libncurses5-dev libssl-dev \
python3-distutils rsync unzip zlib1g-dev file wget
```

## 快速开始

### 1. 克隆本项目
```bash
git clone <your-repo-url>
cd "n60 pro"
```

### 2. 执行编译脚本
```bash
chmod +x build.sh
./build.sh
```

### 3. 等待编译完成
首次编译可能需要 2-6 小时，取决于您的硬件配置和网络速度。

## 编译输出

编译完成后，固件文件位于：
```
immortalwrt-mt798x/bin/targets/mediatek/mt7981/
```

主要文件：
- `immortalwrt-mediatek-mt7981-netcore_n60-pro-squashfs-sysupgrade.bin` - 升级固件
- `immortalwrt-mediatek-mt7981-netcore_n60-pro-squashfs-factory.bin` - 出厂固件（首次刷入）

## 刷机方法

### 方法 1: Web 界面升级（推荐）
1. 登录路由器管理界面
2. 进入系统 → 备份/升级
3. 选择编译好的 sysupgrade.bin 文件
4. 点击上传并等待升级完成

### 方法 2: Breed/Uboot 刷入
1. 进入 Breed/Uboot 界面
2. 选择固件更新
3. 上传 factory.bin 文件
4. 刷入并重启

## 自定义配置

### 修改软件包
编辑 `diy-part2.sh` 文件，添加或删除需要的软件包。

### 修改编译配置
1. 运行 `make menuconfig` 进入配置界面
2. 选择需要的功能和软件包
3. 保存配置到 `.config` 文件

### 添加自定义主题
在 `diy-part2.sh` 中添加主题下载和安装命令。

## 常见问题

### Q: 编译失败怎么办？
A: 
1. 检查网络连接是否稳定
2. 清理编译目录：`./build.sh clean`
3. 重新执行编译：`./build.sh`

### Q: 如何更新编译环境？
A: 
```bash
./build.sh update
```

### Q: 如何添加插件？
A: 编辑 `diy-part2.sh` 文件，使用 `./scripts/feeds install <包名>` 添加

### Q: 固件太大无法刷入？
A: 在 `make menuconfig` 中取消一些不需要的软件包

## 固件特性

### iStoreOS 核心功能
- **iStore 应用商店** - 一键安装各类应用
- **QuickStart 快速入门** - 新手友好的向导界面
- **优化的中文界面** - 更符合国内用户习惯

### ImmortalWrt MT798x 优势
- **完整的 MT7981B 驱动** - 无线、有线性能优化
- **6.6 内核** - 最新稳定内核
- **针对国内优化** - 更快的软件源

## 文件说明

- `build.sh` - 主编译脚本（自动化构建）
- `diy-part1.sh` - 添加 iStoreOS 软件源
- `diy-part2.sh` - 集成 iStoreOS 组件和配置
- `n60-pro.config` - N60 Pro 的编译配置
- `开始编译.bat` - Windows 快捷启动脚本
- `README.md` - 本说明文档

## 技术支持

- [ImmortalWrt MT798x 项目](https://github.com/padavanonly/immortalwrt-mt798x-6.6)
- [iStoreOS 官方](https://github.com/istoreos/istoreos)
- [OpenWrt 官方文档](https://openwrt.org/docs/start)

## 许可证

本项目遵循 GPL-2.0 许可证。

## 鸣谢

- [ImmortalWrt MT798x 项目](https://github.com/padavanonly/immortalwrt-mt798x-6.6) - 提供 MT7981B 优化支持
- [iStoreOS 项目](https://github.com/istoreos/istoreos) - 提供应用商店和快速入门
- [ImmortalWrt 项目](https://github.com/immortalwrt/immortalwrt) - OpenWrt 增强版本
- [OpenWrt 项目](https://github.com/openwrt/openwrt) - 上游固件基础
