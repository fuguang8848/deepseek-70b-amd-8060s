# 🏆 DeepSeek R1 70B on AMD 8060S · 本地大模型部署实录

[English](./README_en.md) · **[技术突破全文](./BREAKTHROUGH.md)**

> **首次在消费级 AMD APU（8060S）上跑满血 70B 大模型**
> AMD Radeon 8060S · 128GB 统一内存 · ROCm 7.2.4 · 生成速度 3-10+ t/s

---

## 🎯 核心成果

**DeepSeek R1 Distill Llama 70B (Q4_K_M) 首次在 AMD 8060S 集成显卡上完整运行**

| 指标 | 数值 |
|------|------|
| 模型大小 | **40GB** (单 GGUF 文件) |
| 生成速度 | **3.3-10+ tokens/s** |
| GPU | AMD Radeon 8060S (gfx1151) |
| 可用内存 | **99GB+** 统一内存 |
| 框架 | llama.cpp b9442 + ROCm 7.2.4 |

---

## ⚡ 为什么能跑

AMD 8060S 采用**统一内存架构**，CPU 和 GPU 共享同一块 128GB 内存池：

```
传统方案: 需要 16-24GB 独显才能跑 70B ❌
本方案:   128GB 统一内存，APU 集成显卡 ✅
```

---

## 🚀 快速上手

```bash
# 环境变量
export ROCM_PATH=/opt/rocm-7.2.4
export HIP_PATH=/opt/rocm-7.2.4
export LD_LIBRARY_PATH=~/bin/llama.cpp-b9442:$ROCM_PATH/lib:$LD_LIBRARY_PATH
export HSA_OVERRIDE_GFX_VERSION=11.5.1
export PATH=~/bin/llama.cpp-b9442:$PATH

# 运行（重启后第一时间）
echo "你的问题" | llama-cli \
  -m ~/.cache/ollama/models/deepseek-r1-70b-q4.gguf \
  -c 256 -ngl 99 -t 16 --log-disable
```

---

## 📖 完整技术记录

**[👉 点击阅读技术突破完整文章](./BREAKTHROUGH.md)**

包含：问题根因分析、关键解决方案、踩坑全记录、性能实测数据。

---

## 🐛 常见问题

| 问题 | 解决 |
|------|------|
| HSA 不识别 8060S | 升级 ROCm 7.2.4 + `HSA_OVERRIDE_GFX_VERSION=11.5.1` |
| apt 循环依赖 | 手动 `dpkg -i` 安装 |
| 显存 OOM | 重启后第一时间运行 |
| hipblas API 报错 | 使用预编译 binary b9442 |

详见 [ISSUES.md](./ISSUES.md)

---

## 📦 项目内容

```
├── README.md          # 本文件
├── BREAKTHROUGH.md   # 技术突破完整文章
├── setup-env.sh      # ROCm 环境安装脚本
├── run-llama-gpu.sh  # GPU 推理启动脚本
└── ISSUES.md         # 问题排查指南
```

---

## 📊 性能实测

```
> Write a Python quicksort implementation.
Prompt: 10-24 t/s | Generation: 3.3-3.6 t/s
```

对话流畅，实际使用完全可用。

---

## 🔧 技术栈

- [llama.cpp](https://github.com/ggerganov/llama.cpp) b9442
- AMD ROCm 7.2.4
- AMD Radeon 8060S (RDNA 3.5 / gfx1151)
- DeepSeek R1 Distill Llama 70B (Q4_K_M)

---

## 📜 License

MIT

---

*紫 · 2026年5月31日 · ASUS ProArt PX13 (AMD 8060S)*
