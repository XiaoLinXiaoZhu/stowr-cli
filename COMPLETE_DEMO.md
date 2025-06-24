# STOWR 完整功能演示

## 项目结构示例
```
my_project/
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── mod.rs
│   └── tests/
│       ├── test_main.rs
│       └── test_lib.rs
├── docs/
│   ├── readme.md
│   ├── api.md
│   └── draft_notes.md
├── logs/
│   ├── app.log
│   ├── error.log
│   └── debug.log
└── Cargo.toml
```

## 演示命令序列

### 1. 配置STOWR
```bash
# 查看当前配置
stowr config --list

# 设置自定义存储路径
stowr config storage.path /custom/backup/path

# 设置索引模式
stowr config index.mode sqlite
```

### 2. 选择性存储（带排除）
```bash
# 创建存储规则文件: selective_backup.txt
echo "# 备份源码但排除测试文件" > selective_backup.txt
echo "my_project/src/**/*.rs" >> selective_backup.txt
echo "!my_project/src/tests/*.rs" >> selective_backup.txt
echo "!my_project/src/mod.rs" >> selective_backup.txt
echo "my_project/*.toml" >> selective_backup.txt

# 执行选择性存储
stowr store --list selective_backup.txt
```

### 3. 存储文档（排除草稿）
```bash
# 创建文档存储规则: docs_backup.txt
echo "# 存储正式文档" > docs_backup.txt
echo "my_project/docs/*.md" >> docs_backup.txt
echo "!my_project/docs/draft*.md" >> docs_backup.txt

# 存储文档
stowr store --list docs_backup.txt
```

### 4. 日志文件管理
```bash
# 创建日志存储规则: logs_backup.txt
echo "# 存储重要日志" > logs_backup.txt
echo "my_project/logs/*.log" >> logs_backup.txt
echo "!my_project/logs/debug.log" >> logs_backup.txt

# 存储日志
stowr store --list logs_backup.txt
```

### 5. 查看存储状态
```bash
# 列出所有已存储文件
stowr list
```

### 6. 文件管理操作
```bash
# 重命名存储的文件
stowr rename my_project/src/main.rs my_project/src/main_v1.rs

# 移动文件到新位置
stowr move my_project/logs/app.log my_project/archive/

# 删除不需要的存储文件
stowr delete my_project/logs/error.log
```

### 7. 选择性恢复
```bash
# 创建恢复规则: restore_critical.txt
echo "# 恢复关键源码文件" > restore_critical.txt
echo "my_project/src/main*.rs" >> restore_critical.txt
echo "my_project/src/lib.rs" >> restore_critical.txt
echo "my_project/*.toml" >> restore_critical.txt

# 执行选择性恢复
stowr owe --list restore_critical.txt
```

### 8. 全量恢复
```bash
# 一键恢复所有存储的文件
stowr owe --all
```

## 高级使用技巧

### 1. 分层备份策略
```bash
# 第一层：核心代码
echo "src/**/*.rs" > backup_core.txt
echo "!src/**/test*.rs" >> backup_core.txt
stowr store --list backup_core.txt

# 第二层：配置和文档
echo "*.toml" > backup_config.txt
echo "docs/**/*.md" >> backup_config.txt
echo "!docs/draft*.md" >> backup_config.txt
stowr store --list backup_config.txt

# 第三层：其他文件
echo "**/*" > backup_others.txt
echo "!src/**/*.rs" >> backup_others.txt
echo "!*.toml" >> backup_others.txt
echo "!docs/**/*.md" >> backup_others.txt
stowr store --list backup_others.txt
```

### 2. 临时文件清理
```bash
# 存储临时文件后清理磁盘空间
echo "temp/**/*" > cleanup_temp.txt
echo "cache/**/*.tmp" >> cleanup_temp.txt
echo "logs/debug*.log" >> cleanup_temp.txt

stowr store --list cleanup_temp.txt
# 手动删除原始文件以释放空间
rm -rf temp/ cache/ logs/debug*.log
```

### 3. 项目迁移
```bash
# 在旧机器上备份
stowr store --list project_complete.txt

# 在新机器上恢复
stowr owe --all
```

## 最佳实践

1. **使用注释**: 在列表文件中使用 `#` 注释说明每个模式的用途
2. **测试模式**: 先用小范围测试通配符模式，确认匹配结果
3. **分类存储**: 按文件类型或重要性分别创建存储规则
4. **定期检查**: 使用 `stowr list` 检查存储状态
5. **备份配置**: 保存好存储规则文件，便于重复使用
