# STOWR

STOWR (Store + Owe) 是一个动态文件压缩和存储工具，使用 Rust 语言开发。

## 项目结构

```
src/
├── main.rs          # 主程序入口
├── config.rs        # 配置管理模块
├── index.rs         # 索引管理模块 (JSON/SQLite)
├── storage.rs       # 文件存储和压缩模块
└── commands.rs      # 命令行处理模块
```

## 构建和运行

```bash
# 构建项目
cargo build

# 运行项目
cargo run -- [COMMAND] [OPTIONS...]

# 构建 release 版本
cargo build --release

# 安装到系统
cargo install --path .
```

## 功能特点

- **动态压缩**: 使用 gzip 压缩算法自动压缩文件
- **灵活索引**: 支持 JSON 和 SQLite 两种索引模式，可根据文件数量自动切换
- **命令行界面**: 完整的 CLI 工具，支持所有操作
- **批量处理**: 支持从文件列表批量存储和提取文件
- **通配符支持**: 在文件列表中支持通配符模式匹配多个文件
- **配置管理**: 可配置存储路径和索引模式

## 通配符功能

STOWR 在使用 `--list` 选项时支持强大的通配符模式：

### 支持的通配符

- `*` - 匹配单个目录层级中的任意字符（不包括路径分隔符）
- `**` - 递归匹配任意深度的目录
- `?` - 匹配单个字符（不包括路径分隔符）
- `[abc]` - 匹配字符类中的任意一个字符

### 通配符使用示例

```bash
# 存储特定模式的文件
src/*.rs              # 存储src目录下所有.rs文件
docs/**/*.md          # 递归存储docs目录下所有.md文件
logs/error_?.log      # 存储如error_1.log, error_2.log等
backup/**/*           # 递归存储backup目录下所有文件

# 提取特定模式的文件
*.txt                 # 提取所有.txt文件
data/temp_*.json      # 提取匹配模式的JSON文件
**/*.pdf              # 递归提取所有PDF文件
```

### 实现原理

- **存储时**: 使用 `glob` crate 在文件系统中匹配通配符模式
- **提取时**: 将通配符模式转换为正则表达式，在已存储的文件索引中匹配

## 技术实现

### 依赖库

- `clap`: 命令行参数解析
- `serde/serde_json`: JSON 序列化
- `rusqlite`: SQLite 数据库支持
- `flate2`: gzip 压缩
- `uuid`: 唯一标识符生成
- `dirs`: 用户目录获取
- `anyhow`: 错误处理
- `chrono`: 时间处理

### 核心算法

1. **文件存储**: 
   - 生成 UUID 作为文件标识符
   - 使用 gzip 压缩文件
   - 在索引中记录文件信息

2. **文件提取**: 
   - 从索引查找文件信息
   - 解压缩文件到原始位置
   - 删除存储的压缩文件和索引记录

3. **索引管理**: 
   - 小于 1000 个文件时使用 JSON 索引
   - 大于等于 1000 个文件时使用 SQLite 索引
   - 支持手动设置索引模式

## 使用示例

```bash
# 查看帮助
stowr help

# 存储单个文件
stowr store document.txt

# 批量存储文件
stowr store --list files_to_store.txt

# 提取文件
stowr owe document.txt

# 列出所有存储的文件
stowr list

# 重命名文件
stowr rename old_name.txt new_name.txt

# 移动文件
stowr move file.txt /new/location/

# 删除文件
stowr delete file.txt

# 配置管理
stowr config --list
stowr config storage.path /custom/path
stowr config index.mode sqlite
```

## 配置文件

配置文件位于 `~/.stowr/config.json`，包含以下设置：

```json
{
  "storage_path": "/home/user/.stowr/storage",
  "index_mode": "Auto"
}
```

## 文件状态

- **Store 状态**: 文件被压缩存储在 STOWR 系统中
- **Owe 状态**: 文件可以被重命名、移动或删除，但内容不可见
- **提取后**: 文件恢复到原始位置，从 STOWR 系统中移除

## 开发说明

项目使用模块化设计：

- `config.rs`: 处理配置文件的加载、保存和验证
- `index.rs`: 实现 JSON 和 SQLite 两种索引方式，支持 trait 对象动态分发
- `storage.rs`: 处理文件的压缩、解压缩和存储管理
- `commands.rs`: 实现各种命令行操作和参数解析

## 测试

项目包含完整的功能测试，验证了所有核心功能：

- 文件存储和提取
- 批量操作
- 重命名和移动
- 配置管理
- 索引切换

压缩率通常在 50-80% 之间，具体取决于文件类型和内容。

### 新增功能

#### 排除模式
- **语法**: 在文件列表中以 `!` 开头的行表示排除模式
- **用途**: 可以在包含大量文件时排除特定的文件或目录
- **应用**: 同时支持存储(store)和提取(owe)操作中的排除

#### 全量提取
- **命令**: `stowr owe --all`
- **功能**: 一键提取所有已存储的文件
- **用途**: 快速恢复所有数据，常用于数据迁移或系统恢复场景
