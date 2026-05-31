#!/bin/bash
# DeepSeek R1 70B GPU 启动脚本
# 重启后第一时间运行，避免桌面合成器占用 GPU 内存

export ROCM_PATH=/opt/rocm-7.2.4
export HIP_PATH=/opt/rocm-7.2.4
export LD_LIBRARY_PATH=$HOME/bin/llama.cpp-b9442:$ROCM_PATH/lib:$ROCM_PATH/lib/llvm/lib:$LD_LIBRARY_PATH
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PATH=$HOME/bin/llama.cpp-b9442:$PATH

MODEL=~/.cache/ollama/models/deepseek-r1-70b-q4.gguf

echo "=== GPU 状态 ==="
rocm-smi --showmeminfo vram 2>/dev/null | head -8
echo ""
$HOME/bin/llama.cpp-b9442/llama-cli --list-devices 2>&1 | head -3
echo ""
echo "=== 开始推理 ==="

PROMPT="${1:-"Hello, how are you?"}"
echo "Prompt: $PROMPT"

time echo "$PROMPT" | $HOME/bin/llama.cpp-b9442/llama-cli \
  -m $MODEL \
  -c 256 -ngl 99 -t 16 --log-disable 2>&1

echo ""
echo "=== 测试完成 ==="
rocm-smi --showmeminfo vram 2>/dev/null | head -8
