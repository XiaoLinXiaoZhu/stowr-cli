## Stowr Cli

[![Crates.io](https://img.shields.io/crates/v/stowr-core.svg)](https://crates.io/crates/stowr-cli)
[![Documentation](https://docs.rs/stowr-core/badge.svg)](https://docs.rs/stowr-cli)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

### 为什么叫做STOWR？
STOWR是一个由“Store”和“Owe”,两个单词组合而成的名称。它能够实现动态的 压缩/解压 文件功能，实现小文件的优化存储。

当文件被存储时，它对于 STOWR 来说处于“Store”状态；而对于文件读写来说，它处于“Owe”状态。当文件被解压后，它将被从STOWR中删除，STOWR将不再拥有该文件。

当处于“Owe”状态时，文件的内容是不可见的，但是你仍然可以将其重命名、移动或删除。

想要查看文件内容，你需要首先使用 STOWR 将其提取出来，提取之后，stowr 将不再 “store” 该文件,“owe"关系也会被解除。

想想看：`stowr owe me_a_file.txt` stowr 你欠我一个文件！

### STOWR的功能

- **智能压缩/解压文件**：支持 gzip、zstd、lz4 多种压缩算法
- **优化存储小文件**：特别适合存储大量小文件场景
- **智能去重存储**：自动检测重复文件，实现零冗余存储
- **差分压缩技术**：对相似文件使用差分存储，大幅减少存储空间
- **文件管理操作**：在存储时，重命名、移动或删除文件
- **灵活提取功能**：支持单文件、批量、通配符等多种提取方式
- **多线程处理**：支持并行处理大量文件，提升性能
- **双索引系统**：自动选择最优索引方式（JSON/SQLite）

### 🎯 特别适用场景

STOWR 的去重和差分功能特别适合以下使用场景：

#### 📁 游戏资源文件存储
- **贴图文件**：不同LOD级别的贴图、差分贴图
- **模型文件**：魔改模型、原版模型的变体
- **光照贴图**：在多个模型间重复使用的光照文件
- **配置文件**：游戏的各种配置文件变体

#### 💾 开发项目存储
- **代码文件**：相似的代码文件、模板文件
- **文档文件**：不同版本的文档、翻译文件
- **资源文件**：图标、UI元素的多个版本

**使用示例：**
```bash
# 存储第一个贴图文件（作为基础文件）
stowr store texture_original.png

# 存储相似的贴图文件（自动使用差分存储）
stowr store texture_modified.png
stowr store texture_lod1.png
stowr store texture_lod2.png

# 存储完全相同的文件（自动去重）
stowr store texture_copy.png
```

在这个例子中，如果文件具有足够的相似性，系统会自动：
- 将 `texture_original.png` 作为基础文件存储
- 将 `texture_modified.png` 等文件存储为差分文件
- 将 `texture_copy.png` 作为重复文件引用，不占用额外空间

### STOWR的使用

STOWR是一个命令行工具，你可以通过以下命令来使用它：

```bash
stowr [COMMAND] [OPTIONS...] [ARGS...]
```

#### 1. **config** — 管理配置项

```bash
stowr config <key> <value>
stowr config --list
```

- 设置或列出全局配置项。
- 示例：
  ```bash
  stowr config storage.path /home/user/files
  stowr config --list
  ```
---

可配置项有：
- `storage.path`：指定存储文件的路径。
- `index.mode`：指定索引模式，可选择为 `auto`、`json` 或 `sqlite` 作为索引库的实现方式。auto模式下会根据存储的文件数量切换索引方式。当存储文件数目小于 1000 时，使用 `json` 模式；当存储文件数目大于等于 1000 时，使用 `sqlite` 模式。
- `multithread`：指定多线程数量（默认值1），用于控制压缩和解压操作时启用的线程数量。当设置大于1时，批量操作将使用多线程并行处理以提升性能。
- `compression.algorithm`：指定压缩算法（默认值gzip），可选择：
  - `gzip`：通用性好，压缩率中等，速度中等（默认选择）
  - `zstd`：现代高效算法，压缩率高，速度快，推荐用于新项目
  - `lz4`：压缩速度极快，压缩率较低，适合实时处理场景
- `compression.level`：指定压缩级别，不同算法支持不同范围：
  - gzip: 0-9（默认6）
  - zstd: 1-22（默认3）
  - lz4: 无级别配置（专注于速度）
- `dedup.enable`：启用/禁用内容去重功能（默认值true），自动检测重复文件并实现零冗余存储
- `delta.enable`：启用/禁用差分压缩功能（默认值true），对相似文件使用差分存储技术
- `delta.similarity_threshold`：差分压缩的相似度阈值（默认值0.7），范围0.0-1.0，值越高要求相似度越高
- `delta.algorithm`：差分算法类型（默认值simple），可选择：
  - `simple`：简单差分算法，通用性好，速度快
  - `xdelta`：高效的二进制差分算法（待实现）
  - `bsdiff`：专业的二进制差分算法（待实现）

**压缩算法配置示例：**
```bash
# 使用zstd高压缩率
stowr config compression.algorithm zstd
stowr config compression.level 15

# 使用lz4高速度（无需设置level）
stowr config compression.algorithm lz4

# 使用gzip兼容性
stowr config compression.algorithm gzip
stowr config compression.level 9
```

**去重和差分存储配置示例：**
```bash
# 启用内容去重（自动检测重复文件）
stowr config dedup.enable true

# 启用差分压缩（相似文件差分存储）
stowr config delta.enable true

# 设置相似度阈值为80%
stowr config delta.similarity_threshold 0.8

# 查看当前所有配置
stowr config --list

# 针对游戏资源文件的推荐配置
stowr config compression.algorithm zstd    # 高压缩率
stowr config compression.level 10          # 中等压缩级别
stowr config dedup.enable true             # 启用去重
stowr config delta.enable true             # 启用差分
stowr config delta.similarity_threshold 0.7  # 70%相似度
stowr config multithread 4                 # 4线程并行处理
```

#### 2. **store** — 存储文件

```bash
stowr store <file>
stowr store --list <file>
stowr store --del <file>
stowr store --list <file> --del
```

- 将指定文件存储到系统中，**自动应用去重和差分存储优化**。
- 系统会自动检测重复文件和相似文件，选择最优存储策略：
  - **完全相同的文件**：仅存储一份，其他作为引用（零冗余）
  - **相似的文件**：使用差分存储，只保存差异部分
  - **独特的文件**：作为基础文件完整存储
- 若使用 `--list`，则读取 `<file>` 中列出的所有路径并依次存储。
- 若使用 `--del`，则在存储完成后删除源文件。
- **支持通配符模式**：在文件列表中可以使用通配符模式匹配多个文件。
- **支持多线程处理**：当配置了 multithread > 1 且批量操作时，自动启用多线程并行处理。
- 示例：
  ```bash
  stowr store texture.png                    # 存储单个文件
  stowr store --list texture_files.txt       # 批量存储纹理文件
  stowr store texture.png --del              # 存储后删除源文件
  stowr store --list models.txt --del        # 批量存储并删除源文件
  ```

**存储优化说明：**
```bash
# 当存储相似文件时，系统会自动优化
stowr store base_texture.png       # 第一个文件：作为基础文件存储
stowr store mod_texture.png        # 相似文件：使用差分存储
stowr store copy_texture.png       # 重复文件：仅创建引用

# 存储结果可能显示：
# base_texture.png stored as base (compression: 85.2%)
# mod_texture.png stored as delta (similarity: 78.5%, compression: 25.1%)
# copy_texture.png deduplicated (reference created)
```

**通配符支持：**

在使用 `--list` 选项时，文件列表中的每一行都可以使用通配符模式：

- `*` - 匹配单个目录层级中的任意字符（不包括路径分隔符）
- `**` - 递归匹配任意深度的目录
- `?` - 匹配单个字符（不包括路径分隔符）
- `[abc]` - 匹配字符类中的任意一个字符

**排除模式支持：**

文件列表中以 `!` 开头的行表示排除模式，用于排除某些不需要的文件：

```bash
# 文件列表内容示例 (files_with_exclusions.txt)
src/**/*.rs       # 包含src目录下所有.rs文件
!src/**/test*.rs  # 排除测试文件
!src/**/mod.rs    # 排除模块文件
docs/**/*.md      # 包含所有文档
!docs/internal/*  # 排除内部文档
```

---

#### 3. **owe** — 提取或查看文件内容

```bash
stowr owe <file>
stowr owe --list <file>
stowr owe --all
```

- 如果文件处于"Owe"状态，则提取该文件；否则不做任何操作。
- **智能重建文件**：系统会自动处理不同类型的存储文件：
  - **基础文件**：直接解压缩提取
  - **差分文件**：自动与基础文件合并重建原文件
  - **引用文件**：从原始存储位置提取内容
- 若使用 `--list`，则提取列表中的所有文件。
- **支持通配符模式**：在文件列表中可以使用通配符模式匹配已存储的文件。
- **支持排除模式**：在文件列表中以 `!` 开头的行可以排除特定文件。
- **支持多线程处理**：当配置了 multithread > 1 且批量操作时，自动启用多线程并行处理。
- 若使用 `--all`，则提取所有已存储的文件。
- 示例：
  ```bash
  stowr owe texture.png                      # 提取单个文件
  stowr owe --list texture_files.txt         # 批量提取文件
  stowr owe --all                            # 提取所有文件
  ```

**提取过程说明：**
```bash
# 提取不同类型的文件时的处理过程
stowr owe base_texture.png      # 基础文件：直接解压缩
stowr owe mod_texture.png       # 差分文件：重建 = 基础文件 + 差分数据
stowr owe copy_texture.png      # 引用文件：从原始存储提取
```

**通配符提取示例：**
```bash
# 文件列表内容示例 (extract.txt)
logs/*.log        # 提取所有存储的.log文件
docs/**/*.pdf     # 递归提取docs目录下的所有.pdf文件
temp/data_*.json  # 提取匹配模式的JSON文件
!logs/debug.log   # 排除调试日志文件
!temp/temp_*.json # 排除临时JSON文件
```

---

#### 4. **rename** — 重命名文件

```bash
stowr rename <old_name> <new_name>
```

- 在存储系统中重命名文件。
- 示例：
  ```bash
  stowr rename old_name.txt new_name.txt
  ```

---

#### 5. **move** — 移动文件

```bash
stowr move <file> <new_location>
```

- 将文件移动到新的位置（路径）。
- 示例：
  ```bash
  stowr move document.docx /backup/
  ```

---

#### 6. **delete** — 删除文件

```bash
stowr delete <file>
```

- 从存储系统中删除指定文件。
- 示例：
  ```bash
  stowr delete temp.log
  ```

---

#### 7. **list** — 列出所有存储的文件

```bash
stowr list
```

- 显示当前存储系统中所有已保存的文件详细信息，包括：
  - **文件名和路径**
  - **原始大小和压缩后大小**
  - **压缩率**
  - **存储类型**：基础文件、差分文件或引用文件
  - **相似度信息**：对于差分文件显示与基础文件的相似度
  - **引用计数**：对于被引用的文件显示引用次数
- 示例：
  ```bash
  stowr list
  ```

**输出示例：**
```
Stored Files:
├── textures/base.png          [1.2MB → 850KB, 70.8%, Base]
├── textures/modified.png      [1.1MB → 180KB, 16.4%, Delta, Similarity: 82.3%]
├── textures/copy.png          [1.2MB → 0B, 0.0%, Reference, Refs: 2]
├── models/character.obj       [2.5MB → 1.8MB, 72.0%, Base]
└── docs/readme.txt           [15KB → 8KB, 53.3%, Base]

Storage Summary:
- Total files: 5
- Unique files: 3  
- Duplicates: 1
- Delta files: 1
- Space saved: 2.3MB (65.7%)
```

---

#### 8. **search** — 搜索存储的文件

```bash
stowr search <pattern>
```

- 根据通配符模式搜索已存储的文件。
- 支持标准通配符语法：
  - `*` - 匹配任意字符序列
  - `?` - 匹配单个字符
  - `[abc]` - 匹配字符类中的任意一个字符
  - `**` - 递归匹配目录（用于路径匹配）
- 显示方式与 `list` 命令一致，包含文件大小、压缩率等信息。
- 示例：
  ```bash
  stowr search "*.png"           # 搜索所有PNG图片
  stowr search "**/*.log"        # 搜索所有日志文件
  stowr search "document.?"      # 搜索类似document.x的文件
  stowr search "*report*"        # 搜索包含report的文件
  ```

---

#### 9. **help** — 显示帮助信息

```bash
stowr help
```

- 显示完整的帮助文档。
- 示例：
  ```bash
  stowr help
  ```

---

#### 10. **version** — 显示版本信息

```bash
stowr version
```

- 查看当前工具的版本号。
- 示例：
  ```bash
  stowr version
  ```



### STOWR 实现概述

当 STOWR 首次运行时，它会创建一个配置文件在 `~/.stowr/config.json`，该文件包含了默认的存储路径和其他配置项，包括去重和差分存储的相关设置。

数据默认存储在 `~/.stowr/storage/` 目录下。每个存储的文件都会生成一个唯一的标识符，并将其元信息存储在索引系统中（JSON 或 SQLite）。

#### 智能存储流程

当你使用 `stowr store` 命令存储文件时，STOWR 会执行以下智能存储流程：

1. **文件检查**：检查文件是否已存在于存储中
2. **内容哈希计算**：计算文件的 SHA256 哈希值
3. **去重检测**：
   - 如果哈希值已存在 → 创建引用，不占用额外空间
   - 如果是新文件 → 继续下一步
4. **相似度分析**（如果启用差分存储）：
   - 与现有文件计算相似度
   - 如果相似度超过阈值 → 创建差分文件
   - 如果相似度不足 → 作为新的基础文件存储
5. **压缩存储**：使用配置的压缩算法压缩文件
6. **索引更新**：更新文件索引，记录存储类型和关联信息

#### 智能提取流程

当你使用 `stowr owe` 命令提取文件时，STOWR 会根据文件类型执行不同的提取流程：

1. **类型检测**：检查文件是基础文件、差分文件还是引用文件
2. **智能重建**：
   - **基础文件**：直接解压缩到原始位置
   - **差分文件**：先获取基础文件，应用差分数据重建原文件
   - **引用文件**：从原始存储位置提取内容
3. **引用计数管理**：更新引用计数，安全删除不再需要的存储文件
4. **索引清理**：从索引中移除文件记录

#### 存储优化效果

通过去重和差分存储技术，STOWR 可以显著减少存储空间占用：

- **重复文件**：零额外空间占用
- **相似文件**：通常可节省 60-90% 的存储空间
- **独特文件**：通过压缩算法优化存储

**典型使用场景的空间节省：**
- 游戏资源文件：60-80% 空间节省
- 开发项目文件：40-70% 空间节省  
- 文档和配置文件：30-60% 空间节省
