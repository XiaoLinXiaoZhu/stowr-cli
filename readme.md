## STOWR

### 为什么叫做STOWR？

STOWR是一个由“Store”和“Owe”,两个单词组合而成的名称。它能够实现动态的 压缩/解压 文件功能，实现小文件的优化存储。

当文件被存储时，它对于 STOWR 来说处于“Store”状态；而对于文件读写来说，它处于“Owe”状态。当文件被解压后，它将被从STOWR中删除，STOWR将不再拥有该文件。

当处于“Owe”状态时，文件的内容是不可见的，但是你仍然可以将其重命名、移动或删除。

想要查看文件内容，你需要首先使用 STOWR 将其提取出来，提取之后，stowr 将不再 “store” 该文件,“owe"关系也会被解除。


### STOWR的功能

- 压缩/解压文件
- 优化存储小文件
- 在存储时，重命名、移动或删除文件
- 提取文件内容

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
- `compression.level`：指定压缩级别（默认值6），范围是0-9。0表示无压缩（最快），9表示最大压缩（最慢）。较高的压缩级别可以减少存储空间，但会增加CPU使用时间。

#### 2. **store** — 存储文件

```bash
stowr store <file>
stowr store --list <file>
stowr store --del <file>
stowr store --list <file> --del
```

- 将指定文件存储到系统中。
- 若使用 `--list`，则读取 `<file>` 中列出的所有路径并依次存储。
- 若使用 `--del`，则在存储完成后删除源文件。
- **支持通配符模式**：在文件列表中可以使用通配符模式匹配多个文件。
- **支持多线程处理**：当配置了 multithread > 1 且批量操作时，自动启用多线程并行处理。
- 示例：
  ```bash
  stowr store notes.txt
  stowr store --list file_list.txt
  stowr store notes.txt --del
  stowr store --list file_list.txt --del
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
- 若使用 `--list`，则提取列表中的所有文件。
- **支持通配符模式**：在文件列表中可以使用通配符模式匹配已存储的文件。
- **支持排除模式**：在文件列表中以 `!` 开头的行可以排除特定文件。
- **支持多线程处理**：当配置了 multithread > 1 且批量操作时，自动启用多线程并行处理。
- 若使用 `--all`，则提取所有已存储的文件。
- 示例：
  ```bash
  stowr owe report.pdf
  stowr owe --list files_to_owe.txt
  stowr owe --all
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

- 显示当前存储系统中所有已保存的文件名。
- 示例：
  ```bash
  stowr list
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

当 STOWR 首次运行时，它会创建一个 配置文件在 `~/.stowr/config.json`，该文件包含了默认的存储路径和其他配置项。

数据默认存储在 `~/.stowr/storage/` 目录下。每个存储的文件都会生成一个唯一的标识符，并将其存储在配置文件中。

当你使用 `stowr store` 命令存储文件时，STOWR 会执行以下操作：
1. 检查文件是否已存在于存储中。
2. 如果不存在，则生成一个唯一的标识符。
3. 使用 gzip 压缩文件。
4. 将压缩后的文件移动到存储目录，并更新配置文件。
5. 返回存储文件的唯一标识符。

当你使用 `stowr owe` 命令提取文件时，STOWR 会执行以下操作：
1. 检查文件是否存在于存储中。
2. 如果存在，则解压缩文件到原始位置。
3. 删除存储的压缩文件和配置文件中的记录。
4. 返回提取的文件路径。
