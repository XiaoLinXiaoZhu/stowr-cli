# STOWR 通配符功能测试脚本

Write-Host "=== STOWR 通配符功能测试 ===" -ForegroundColor Green

# 清理之前的存储
Write-Host "`n清理存储..." -ForegroundColor Yellow
cargo run -- delete move_test.txt 2>$null
cargo run -- delete test_file.txt 2>$null
cargo run -- delete "Cargo.toml" 2>$null
cargo run -- delete "src/main.rs" 2>$null

# 1. 创建测试目录结构
Write-Host "`n1. 创建测试目录结构:" -ForegroundColor Yellow
New-Item -ItemType Directory -Path "test_glob\src" -Force | Out-Null
New-Item -ItemType Directory -Path "test_glob\docs" -Force | Out-Null
New-Item -ItemType Directory -Path "test_glob\docs\api" -Force | Out-Null
New-Item -ItemType Directory -Path "test_glob\logs" -Force | Out-Null

# 2. 创建测试文件
Write-Host "`n2. 创建测试文件:" -ForegroundColor Yellow
"源代码文件1" | Out-File -FilePath "test_glob\src\main.rs" -Encoding UTF8
"源代码文件2" | Out-File -FilePath "test_glob\src\lib.rs" -Encoding UTF8
"配置文件" | Out-File -FilePath "test_glob\src\config.toml" -Encoding UTF8

"文档1" | Out-File -FilePath "test_glob\docs\readme.md" -Encoding UTF8
"API文档" | Out-File -FilePath "test_glob\docs\api\guide.md" -Encoding UTF8
"用户手册" | Out-File -FilePath "test_glob\docs\manual.pdf" -Encoding UTF8

"日志1" | Out-File -FilePath "test_glob\logs\app.log" -Encoding UTF8
"错误日志" | Out-File -FilePath "test_glob\logs\error.log" -Encoding UTF8

"数据文件1" | Out-File -FilePath "test_glob\data1.json" -Encoding UTF8
"数据文件2" | Out-File -FilePath "test_glob\data2.json" -Encoding UTF8

# 3. 创建通配符模式测试文件
Write-Host "`n3. 创建通配符模式测试文件:" -ForegroundColor Yellow

# 存储所有Rust文件
"# 存储所有Rust源文件
test_glob\src\*.rs" | Out-File -FilePath "store_rust.txt" -Encoding UTF8

# 存储所有Markdown文件（递归）
"# 递归存储所有Markdown文件
test_glob\**\*.md" | Out-File -FilePath "store_markdown.txt" -Encoding UTF8

# 存储所有日志文件
"# 存储所有日志文件
test_glob\logs\*.log" | Out-File -FilePath "store_logs.txt" -Encoding UTF8

# 存储所有JSON文件
"# 存储JSON数据文件
test_glob\data?.json" | Out-File -FilePath "store_json.txt" -Encoding UTF8

# 混合模式
"# 混合通配符模式
test_glob\src\*.rs
test_glob\docs\**\*.md
test_glob\*.json
test_glob\logs\*.log" | Out-File -FilePath "store_mixed.txt" -Encoding UTF8

# 4. 测试各种通配符模式
Write-Host "`n4. 测试存储 - 所有Rust文件:" -ForegroundColor Yellow
cargo run -- store --list store_rust.txt

Write-Host "`n5. 测试存储 - 递归Markdown文件:" -ForegroundColor Yellow
cargo run -- store --list store_markdown.txt

Write-Host "`n6. 测试存储 - 日志文件:" -ForegroundColor Yellow
cargo run -- store --list store_logs.txt

Write-Host "`n7. 测试存储 - JSON文件模式:" -ForegroundColor Yellow
cargo run -- store --list store_json.txt

Write-Host "`n8. 查看所有存储的文件:" -ForegroundColor Yellow
cargo run -- list

# 9. 测试通配符提取
Write-Host "`n9. 删除部分原始文件进行提取测试:" -ForegroundColor Yellow
Remove-Item "test_glob\src\*.rs" -Force
Remove-Item "test_glob\logs\*.log" -Force

Write-Host "`n10. 创建提取模式文件:" -ForegroundColor Yellow
"# 提取Rust源文件
test_glob\src\*.rs
# 提取日志文件
test_glob\logs\*.log" | Out-File -FilePath "extract_test.txt" -Encoding UTF8

Write-Host "`n11. 测试通配符提取:" -ForegroundColor Yellow
cargo run -- owe --list extract_test.txt

Write-Host "`n12. 验证文件已恢复:" -ForegroundColor Yellow
if (Test-Path "test_glob\src\main.rs") {
    Write-Host "✓ main.rs 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ main.rs 恢复失败" -ForegroundColor Red
}

if (Test-Path "test_glob\logs\app.log") {
    Write-Host "✓ app.log 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ app.log 恢复失败" -ForegroundColor Red
}

Write-Host "`n13. 最终存储状态:" -ForegroundColor Yellow
cargo run -- list

# 14. 高级通配符测试
Write-Host "`n14. 高级通配符测试 - 递归存储所有文件:" -ForegroundColor Yellow
"# 递归存储test_glob下所有文件
test_glob\**\*" | Out-File -FilePath "store_all.txt" -Encoding UTF8

cargo run -- store --list store_all.txt

Write-Host "`n15. 最终文件统计:" -ForegroundColor Yellow
cargo run -- list

# 清理测试文件
Write-Host "`n清理测试文件..." -ForegroundColor Yellow
Remove-Item "test_glob" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "store_*.txt", "extract_test.txt" -Force -ErrorAction SilentlyContinue

Write-Host "`n=== 通配符功能测试完成 ===" -ForegroundColor Green
