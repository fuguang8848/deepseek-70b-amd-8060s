# 🐛 问题排查与解决

## ROCm 问题

### HSA 无法识别 gfx1151 (8060S)

**症状:**
```
rocm-smi: hsa runtime not available
HSA error: failed to enumerate devices
```

**原因:** ROCm 6.2.2 不支持 Strix Point (gfx1151)

**解决:** 升级到 ROCm 7.2.4

---

### apt 循环依赖

**症状:**
```
The following packages have unmet dependencies:
 hsa-rocr : Depends: rocm-llvm (= x.x.x) but it is not going to be installed
```

**原因:** `hsa-rocr` 和 `rocm-llvm` 互相依赖

**解决:** 手动下载 individual deb 包用 `dpkg -i` 安装，跳过 apt 依赖检查

---

## llama.cpp 问题

### hipblas API 编译错误

**症状:**
```
error: unknown type name 'hipblasDatatype_t'
error: no matching function for call to 'hipblasGemmEx'
```

**原因:** ROCm 7.2.4 移除了 hipblas 旧 API (cublasComputeType_t 等)

**解决:** 使用官方预编译 binary (b9442)，已针对 ROCm 7.2 编译

---

### 显存分配失败 (OOM)

**症状:**
```
cudaMalloc failed: out of memory
allocating 39979.48 MiB on device 0: out of memory
```

**原因:**
1. 桌面合成器占用 GPU 内存
2. 预编译版用 `hipMalloc` 只能访问 VRAM 窗口
3. VRAM 碎片化导致无法分配 40GB 连续空间

**解决:**
- 重启后第一时间运行
- 或减少 `-ngl` 参数（部分 GPU 层）
- 确保 `HSA_OVERRIDE_GFX_VERSION=11.5.1` 正确设置

---

### TUI spinner 在后台无法捕获

**症状:** 交互模式下 `llama-cli` 的进度条 spinner 无法在重定向输出中显示

**解决:** 使用 `echo "prompt" | llama-cli ...` 非交互 pipe 模式

---

## 性能问题

### 生成速度慢 (<1 t/s)

**检查:**
1. 是否使用了 GPU 加速 (`-ngl 99`)
2. `HSA_OVERRIDE_GFX_VERSION` 是否设置
3. GPU 检测是否正常 (`--list-devices`)

**优化方向:**
- 增加 `-tb` (batch size)
- 减少 context `-c` 长度
- 测试不同 `-ngl` 值

---

## 统一内存问题

### ROCm 只显示 4GB VRAM

**症状:** `rocm-smi` 显示 VRAM 只有 4GB，但实际有 128GB

**原因:** ROCm 默认只报告专用 VRAM 窗口大小

**说明:** 8060S 是统一内存架构，llama.cpp 的 HSA 后端可以访问全部 128GB，不需要在意 rocm-smi 显示的 VRAM 大小

**验证:** `llama-cli --list-devices` 显示的 "free" 才是实际可用内存（应该是 60-100GB）
