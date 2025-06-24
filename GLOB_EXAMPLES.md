# STOWR 通配符使用示例

## 基本通配符模式

### 单层通配符 (*)
```
# 匹配特定目录下的特定类型文件
src/*.rs          # 所有Rust源文件
docs/*.md         # 所有Markdown文档
logs/*.log        # 所有日志文件
```

### 递归通配符 (**)
```
# 递归匹配所有子目录
src/**/*.rs       # 递归匹配src下所有.rs文件
docs/**/*.md      # 递归匹配docs下所有.md文件
**/*.txt          # 递归匹配所有.txt文件
```

### 单字符通配符 (?)
```
# 匹配单个字符
data/file?.json   # 匹配 file1.json, file2.json, filea.json 等
log_??.txt        # 匹配 log_01.txt, log_99.txt, log_ab.txt 等
```

### 字符类 ([])
```
# 匹配指定字符范围
file[123].txt     # 匹配 file1.txt, file2.txt, file3.txt
log[a-z].log      # 匹配 loga.log, logb.log, ... logz.log
```

## 实际使用场景

### 场景1: 备份源代码项目
```bash
# 创建文件列表 backup_code.txt
src/**/*.rs
src/**/*.toml
tests/**/*.rs
docs/**/*.md

# 执行备份
stowr store --list backup_code.txt
```

### 场景2: 清理临时日志文件
```bash
# 创建文件列表 cleanup_logs.txt
logs/temp_*.log
cache/**/*.tmp
debug_?.log

# 存储后删除原文件进行清理
stowr store --list cleanup_logs.txt
# 手动删除原文件...
```

### 场景3: 恢复特定类型文件
```bash
# 创建文件列表 restore_docs.txt
docs/**/*.pdf
manuals/**/*.docx
guides/**/*.md

# 恢复文档文件
stowr owe --list restore_docs.txt
```

## 注意事项

1. **路径分隔符**: 在Windows下使用反斜杠 `\`，在Unix/Linux下使用正斜杠 `/`
2. **大小写敏感**: 通配符匹配是大小写敏感的
3. **注释支持**: 文件列表中以 `#` 开头的行会被忽略
4. **空行忽略**: 空行会被自动忽略

## 高级用法

### 排除模式
虽然STOWR不直接支持排除模式，但可以通过多个列表文件组合使用：

```bash
# 存储所有源文件但排除测试文件
# 文件: store_src_only.txt
src/**/*.rs
lib/**/*.rs
# 注意：不包括 tests/ 目录

# 单独处理测试文件
# 文件: store_tests.txt
tests/**/*.rs
```

### 批量操作工作流
```bash
# 1. 按类型分别存储
stowr store --list rust_files.txt      # 存储Rust文件
stowr store --list docs_files.txt      # 存储文档文件
stowr store --list config_files.txt    # 存储配置文件

# 2. 查看存储状态
stowr list

# 3. 按需要提取
stowr owe --list restore_critical.txt  # 恢复关键文件
```

## 排除模式 (!)

### 基本语法
```
# 包含模式 - 匹配所有.rs文件
src/**/*.rs

# 排除模式 - 排除测试文件
!src/**/test*.rs
!src/**/*_test.rs
```

### 实际应用场景

#### 场景1: 备份项目源码但排除测试
```bash
# 文件: backup_source_only.txt
src/**/*.rs
lib/**/*.rs
!src/**/test*.rs
!lib/**/test*.rs
!**/mod.rs
```

#### 场景2: 处理日志文件但排除调试日志
```bash
# 文件: process_production_logs.txt
logs/**/*.log
!logs/**/debug*.log
!logs/**/trace*.log
!logs/temp/*.log
```

#### 场景3: 文档归档但排除草稿
```bash
# 文件: archive_final_docs.txt
docs/**/*.md
docs/**/*.pdf
!docs/**/draft*.md
!docs/**/temp*.pdf
!docs/private/**/*
```

## 全量操作

### owe --all 命令
```bash
# 提取所有已存储的文件
stowr owe --all
```

**使用场景:**
- 系统迁移时批量恢复数据
- 清理存储空间前的完整备份
- 紧急情况下的快速数据恢复
