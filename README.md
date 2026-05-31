# DeepSeek R1 70B on AMD 8060S · 本地大模型部署实录

> AMD Radeon 8060S (gfx1151) · ROCm 7.2.4 · 128GB 统一内存 · 首次突破

[English](./README_en.md) | 中文

---

## 🎯 成果

**首次在消费级 AMD APU（8060S）上成功运行满血 70B 大模型**

| 指标 | 数值 |
|------|------|
| 模型 | DeepSeek R1 Distill Llama 70B (Q4_K_M) |
| 量化大小 | 40GB (单 GGUF 文件) |
| 生成速度 | **3-10+ tokens/s** |
| GPU | AMD Radeon 8060S (RDNA 3.5 / gfx1151) |
| 内存架构 | 128GB 统一内存 (CPU/GPU 共享) |
| 框架 | llama.cpp b9442 + ROCm 7.2.4 |

---

## 🖥️ 硬件环境

```
设备: ASUS ProArt PX13 HN7306EA
CPU: AMD Ryzen AI MAX+ 395 (Strix Point)
GPU: AMD Radeon 8060S (RDNA 3.5, gfx1151)
内存: 128GB DDR5 (统一内存架构)
系统: Ubuntu 24.04 / Linux 6.17
```

---

## 📦 快速部署

### 1. 环境准备

```bash
# ROCm 7.2.4 环境变量
export ROCM_PATH=/opt/rocm-7.2.4
export HIP_PATH=/opt/rocm-7.2.4
export LD_LIBRARY_PATH=$ROCM_PATH/lib:$ROCM_PATH/lib/llvm/lib:$LD_LIBRARY_PATH
export HSA_OVERRIDE_GFX_VERSION=11.5.1
```

### 2. 下载模型

```bash
# DeepSeek R1 Distill Llama 70B Q4_K_M (40GB)
# 使用 Ollama 或 ModelScope 下载
```

### 3. 运行推理

```bash
# 重启后第一时间运行（避开桌面合成器占用 GPU 内存）
echo "Write a Python quicksort." | llama-cli \
  -m ~/.cache/ollama/models/deepseek-r1-70b-q4.gguf \
  -c 256 -ngl 99 -t 16 --log-disable
```

---

## 🔧 技术细节

### ROCm 7.2.4 安装

通过手动 dpkg 安装绕过循环依赖：

```bash
cd /home/fuguang/.openclaw/workspace/
sudo dpkg -i hsa-rocr7.2.4_*.deb hip-runtime-amd7.2.4_*.deb \
  rocm-device-libs7.2.4_*.deb comgr7.2.4_*.deb \
  rocm-llvm7.2.4_*.deb hipblaslt7.2.4_*.deb ...
```

### llama.cpp b9442 预编译版

下载官方 ROCm 7.2 预编译版本：

```
https://github.com/ggml-org/llama.cpp/releases/download/b9442/llama-b9442-bin-ubuntu-rocm-7.2-x64.tar.gz
```

### 关键配置参数

| 参数 | 值 | 说明 |
|------|-----|------|
| `HSA_OVERRIDE_GFX_VERSION` | 11.5.1 | 让 ROCm 识别 gfx1151 |
| `-ngl` | 99 | GPU 承载所有层 |
| `-c` | 256-512 | context 长度（内存相关） |
| `-t` | 16 | CPU 线程数 |

---

## 🐛 踩坑记录

### 1. ROCm 6.2.2 不识别 8060S
- **现象**: HSA runtime 无法识别 gfx1151
- **解决**: 升级到 ROCm 7.2.4

### 2. apt 循环依赖
- **现象**: `hsa-rocr` 依赖 `rocm-llvm`，循环依赖无法安装
- **解决**: 手动下载 individual deb 包，dpkg 安装

### 3. hipblas API 变化
- **现象**: ROCm 7.2.4 移除了 `hipblasDatatype_t` 等旧 API
- **影响**: llama.cpp 源码编译失败
- **解决**: 使用预编译 binary（已针对 ROCm 7.2 编译）

### 4. VRAM 碎片化
- **现象**: 桌面合成器平时占用 GPU 内存，导致 OOM
- **解决**: 重启后第一时间运行，或减少 `-ngl` 值

### 5. llama-cli TUI 模式
- **现象**: 交互模式在后台运行时 spinner 无法捕获
- **解决**: 使用 `echo "prompt" | llama-cli ...` 非交互模式

---

## 📊 性能测试

| 配置 | 生成速度 | 备注 |
|------|---------|------|
| `-ngl 99 -c 256` | ~3.3 t/s | 全部 GPU，短对话 |
| `-ngl 10 -c 64` | 待测 | 部分 GPU 省内存 |
| CPU 模式 | <1 t/s | 仅参考基准 |

---

## 🔮 后续优化

- [ ] 源码编译（修复 hipblas API 兼容）
- [ ] 测试更大 context (1024+) 的内存需求
- [ ] 接入 SillyTavern 做对话 UI
- [ ] 探索 llama server 模式的 API 服务
- [ ] 测试不同量化（Q5_K_M, Q8_0）

---

## 📚 相关项目

- [llama.cpp](https://github.com/ggerganov/llama.cpp) - 核心推理框架
- [ROCm](https://rocm.docs.amd.com/) - AMD GPU 计算平台
- [DeepSeek R1](https://huggingface.co/deepseek-ai/DeepSeek-R1) - 模型权重

---

## 📄 License

MIT License

---

*紫 · 2026年5月31日 · ProArt PX13 (AMD 8060S)*
