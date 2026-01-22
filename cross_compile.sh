#!/bin/bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "========================================="
echo "Openpilot ARM64 交叉编译脚本"
echo "========================================="
echo "目标架构: aarch64-linux-gnu (OnePlus 6)"
echo "主机架构: $(uname -m)"
echo ""

export OPENPILOT_DIR="$SCRIPT_DIR"

export ARCH="aarch64"
export TARGET="aarch64-linux-gnu"
export CROSS_COMPILE="aarch64-linux-gnu-"

export CC="clang"
export CXX="clang++"

export CFLAGS="-target aarch64-linux-gnu -mcpu=cortex-a57 -mtune=cortex-a57"
export CXXFLAGS="-target aarch64-linux-gnu -mcpu=cortex-a57 -mtune=cortex-a57"
export LDFLAGS="-target aarch64-linux-gnu -fuse-ld=lld"

export QMAKE="qmake"

export SYSROOT="/usr/aarch64-linux-gnu"

export SCONS_ARGS="-j$(nproc)"

echo "环境变量设置:"
echo "  CC=$CC"
echo "  CXX=$CXX"
echo "  CFLAGS=$CFLAGS"
echo "  CXXFLAGS=$CXXFLAGS"
echo "  LDFLAGS=$LDFLAGS"
echo "  SCONS_ARGS=$SCONS_ARGS"
echo ""

if [ ! -d "$OPENPILOT_DIR" ]; then
    echo "错误: openpilot 目录不存在: $OPENPILOT_DIR"
    exit 1
fi

echo "检查 Python 虚拟环境..."
if [ ! -d "$OPENPILOT_DIR/.venv" ]; then
    echo "创建 Python 虚拟环境..."
    pipenv --python 3.12
fi

echo "激活 Python 虚拟环境..."
pipenv shell

echo ""
echo "========================================="
echo "开始编译 openpilot..."
echo "========================================="

scons -u -j$(nproc) CC="$CC" CXX="$CXX" CCFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LINKFLAGS="$LDFLAGS"

echo ""
echo "========================================="
echo "编译完成!"
echo "========================================="
echo "编译产物位于: $OPENPILOT_DIR"
echo ""
echo "验证编译产物架构..."
find "$OPENPILOT_DIR" -type f -executable -name "*.so" -o -name "*.pyd" | head -5 | while read file; do
    if [ -f "$file" ]; then
        echo "  $file: $(file "$file" | grep -oE 'ELF [0-9]+-bit LSB|ARM aarch64')"
    fi
done

echo ""
echo "编译脚本执行完成!"
