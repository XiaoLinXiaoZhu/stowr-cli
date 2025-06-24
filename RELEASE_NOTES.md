# Release Notes

## Version 0.1.0

### 🎉 Initial Release

STOWR (Store + Owe) is a dynamic file compression and storage tool written in Rust.

### ✨ Features

- **Dynamic Compression**: Automatic file compression using gzip
- **Flexible Indexing**: Support for both JSON and SQLite indexing modes
- **Glob Pattern Support**: Advanced wildcard pattern matching for file operations
- **Exclude Patterns**: Powerful exclusion syntax using `!` prefix
- **Batch Operations**: Process multiple files using pattern lists
- **Complete CLI**: Full command-line interface for all operations
- **Cross-Platform**: Works on Windows, macOS, and Linux

### 🚀 Commands

- `stowr config` - Manage configuration settings
- `stowr store` - Store files with compression
- `stowr owe` - Extract files from storage
- `stowr owe --all` - Extract all stored files
- `stowr rename` - Rename stored files
- `stowr move` - Move stored files
- `stowr delete` - Delete stored files
- `stowr list` - List all stored files
- `stowr version` - Show version information

### 🔧 Configuration

- **storage.path**: Configure storage location
- **index.mode**: Choose between auto, json, or sqlite indexing

### 📁 Glob Patterns

- `*` - Match any characters in single directory level
- `**` - Recursive match across directories
- `?` - Match single character
- `[abc]` - Character class matching
- `!pattern` - Exclude pattern

### 🎯 Use Cases

- Project backup with selective file inclusion/exclusion
- Temporary file cleanup and archival
- System migration and data recovery
- Development workspace optimization

### 📦 Installation

Download the appropriate binary for your platform from the releases page.

### 🔗 Documentation

See the included README.md and documentation files for detailed usage examples.

---

**Note**: This is the initial release. Please report any issues on the GitHub repository.
