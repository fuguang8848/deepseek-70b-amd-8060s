#!/bin/bash
# ROCm 7.2.4 环境安装脚本 (for AMD 8060S / gfx1151)
# 适用于 Ubuntu 24.04 / AMD Ryzen AI MAX+ 395

set -e

echo "=== AMD 8060S ROCm 7.2.4 环境安装 ==="
echo ""

# 检查系统
if [ ! -f /etc/apt/sources.list.d/rocm.list ]; then
  echo "[1/5] 添加 ROCm 7.2.4 APT 源..."
  curl -L https://repo.radeon.com/rocm/rocm.gpg.key | sudo tee /etc/apt/trusted.gpg.d/rocm.gpg > /dev/null
  echo "deb [arch=amd64] https://repo.radeon.com/rocm/ubuntu/7.2.4 jammy main" | \
    sudo tee /etc/apt/sources.list.d/rocm.list > /dev/null
  sudo apt-get update -qq
fi

echo "[2/5] 安装 ROCm 7.2.4 核心包..."
sudo apt-get install -y --no-install-recommends \
  hsa-rocr7.2.4 \
  hip-runtime-amd7.2.4 \
  rocm-device-libs7.2.4 \
  comgr7.2.4 \
  rocm-llvm7.2.4 \
  rocm-utils7.2.4 \
  rocminfo7.2.4 \
  rocprofiler7.2.4 \
  hipblaslt7.2.4 \
  hipblas7.2.4 \
  rocsolver7.2.4 \
  rocsparse7.2.4 \
  rocrand7.2.4 \
  rocm-smi \
  rocm-libs7.2.4 \
  2>&1 | tail -5

echo "[3/5] 配置环境变量..."
cat >> ~/.bashrc << 'EOF'

# ROCm 7.2.4 for AMD 8060S (gfx1151)
export ROCM_PATH=/opt/rocm-7.2.4
export HIP_PATH=/opt/rocm-7.2.4
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib/llvm/lib:$LD_LIBRARY_PATH
export PATH=$ROCM_PATH/bin:$PATH
EOF

echo "[4/5] 下载 llama.cpp b9442..."
mkdir -p ~/bin
cd /tmp
if [ ! -f llama-b9442-bin.tar.gz ]; then
  curl -L https://github.com/ggml-org/llama.cpp/releases/download/b9442/llama-b9442-bin-ubuntu-rocm-7.2-x64.tar.gz \
    -o llama-b9442-bin.tar.gz
fi
tar -xzf llama-b9442-bin.tar.gz -C ~/bin/
mv ~/bin/llama-b9442 ~/bin/llama.cpp-b9442

echo "[5/5] 验证安装..."
source ~/.bashrc
rocm-smi --showmeminfo vram 2>/dev/null | head -5
~/bin/llama.cpp-b9442/llama-cli --list-devices 2>&1 | head -3

echo ""
echo "=== 安装完成！==="
echo "运行以下命令启动 DeepSeek R1 70B:"
echo "  bash ~/deepseek-70b-amd-8060s/run-llama-gpu.sh"
