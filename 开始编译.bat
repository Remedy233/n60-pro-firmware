@echo off
chcp 65001 >nul
echo ╔═══════════════════════════════════════════╗
echo ║   磊科 N60 Pro iStoreOS 固件编译工具     ║
echo ║   ImmortalWrt MT798x + iStoreOS          ║
echo ╚═══════════════════════════════════════════╝
echo.
echo 本脚本将在 WSL (Windows Subsystem for Linux) 中执行编译
echo.

REM 检查 WSL 是否安装
wsl --list >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 WSL！
    echo.
    echo 请先安装 WSL2：
    echo 1. 以管理员身份运行 PowerShell
    echo 2. 执行: wsl --install
    echo 3. 重启电脑
    echo 4. 再次运行本脚本
    echo.
    pause
    exit /b 1
)

echo [信息] 检测到 WSL，准备启动编译...
echo.
echo 正在进入 WSL 环境...
echo.

REM 获取当前目录的 WSL 路径
for /f "delims=" %%i in ('wsl wslpath -a "%CD%"') do set WSL_PATH=%%i

REM 在 WSL 中执行编译脚本
wsl bash -c "cd '%WSL_PATH%' && chmod +x build.sh diy-part1.sh diy-part2.sh && ./build.sh"

echo.
echo ═══════════════════════════════════════════
echo 编译流程已结束
echo ═══════════════════════════════════════════
echo.
pause
