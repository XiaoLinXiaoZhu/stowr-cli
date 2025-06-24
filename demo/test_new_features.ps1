# STOWR 新功能测试脚本 - 排除模式和owe --all

Write-Host "=== STOWR 新功能测试 ===" -ForegroundColor Green

# 清理之前的存储
Write-Host "`n清理存储..." -ForegroundColor Yellow
cargo run -- owe --all 2>$null

# 1. 创建测试目录结构
Write-Host "`n1. 创建测试目录结构:" -ForegroundColor Yellow
New-Item -ItemType Directory -Path "test_new\src" -Force | Out-Null
New-Item -ItemType Directory -Path "test_new\tests" -Force | Out-Null
New-Item -ItemType Directory -Path "test_new\docs" -Force | Out-Null
New-Item -ItemType Directory -Path "test_new\examples" -Force | Out-Null

# 2. 创建测试文件
Write-Host "`n2. 创建测试文件:" -ForegroundColor Yellow
"主程序" | Out-File -FilePath "test_new\src\main.rs" -Encoding UTF8
"库文件" | Out-File -FilePath "test_new\src\lib.rs" -Encoding UTF8
"模块文件" | Out-File -FilePath "test_new\src\mod.rs" -Encoding UTF8
"测试文件1" | Out-File -FilePath "test_new\tests\test_main.rs" -Encoding UTF8
"测试文件2" | Out-File -FilePath "test_new\tests\test_lib.rs" -Encoding UTF8
"文档" | Out-File -FilePath "test_new\docs\readme.md" -Encoding UTF8
"示例" | Out-File -FilePath "test_new\examples\example1.rs" -Encoding UTF8
"配置" | Out-File -FilePath "test_new\Cargo.toml" -Encoding UTF8

# 3. 测试排除模式功能
Write-Host "`n3. 创建带排除模式的文件列表:" -ForegroundColor Yellow

# 存储所有.rs文件但排除测试和模块文件
"# 存储所有Rust文件但排除测试和模块文件
test_new\**\*.rs
!test_new\tests\*.rs
!test_new\src\mod.rs" | Out-File -FilePath "store_with_exclusions.txt" -Encoding UTF8

Write-Host "`n4. 测试排除模式存储:" -ForegroundColor Yellow
cargo run -- store --list store_with_exclusions.txt

Write-Host "`n5. 查看存储的文件:" -ForegroundColor Yellow
cargo run -- list

# 6. 存储更多文件来测试owe --all
Write-Host "`n6. 存储更多文件:" -ForegroundColor Yellow
"test_new\docs\*.md
test_new\*.toml" | Out-File -FilePath "store_more.txt" -Encoding UTF8
cargo run -- store --list store_more.txt

Write-Host "`n7. 再次查看所有存储的文件:" -ForegroundColor Yellow
cargo run -- list

# 8. 删除所有原始文件
Write-Host "`n8. 删除所有原始文件进行测试:" -ForegroundColor Yellow
Remove-Item "test_new" -Recurse -Force

# 9. 测试owe --all功能
Write-Host "`n9. 测试owe --all功能（恢复所有文件）:" -ForegroundColor Yellow
cargo run -- owe --all

# 10. 验证文件是否恢复
Write-Host "`n10. 验证文件恢复情况:" -ForegroundColor Yellow
if (Test-Path "test_new\src\main.rs") {
    Write-Host "✓ main.rs 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ main.rs 恢复失败" -ForegroundColor Red
}

if (Test-Path "test_new\src\lib.rs") {
    Write-Host "✓ lib.rs 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ lib.rs 恢复失败" -ForegroundColor Red
}

if (Test-Path "test_new\src\mod.rs") {
    Write-Host "✗ mod.rs 不应该被恢复（已排除）" -ForegroundColor Red
} else {
    Write-Host "✓ mod.rs 正确排除" -ForegroundColor Green
}

if (Test-Path "test_new\tests\test_main.rs") {
    Write-Host "✗ test_main.rs 不应该被恢复（已排除）" -ForegroundColor Red
} else {
    Write-Host "✓ test_main.rs 正确排除" -ForegroundColor Green
}

if (Test-Path "test_new\docs\readme.md") {
    Write-Host "✓ readme.md 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ readme.md 恢复失败" -ForegroundColor Red
}

if (Test-Path "test_new\Cargo.toml") {
    Write-Host "✓ Cargo.toml 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ Cargo.toml 恢复失败" -ForegroundColor Red
}

# 11. 检查存储状态
Write-Host "`n11. 最终存储状态（应该为空）:" -ForegroundColor Yellow
cargo run -- list

# 12. 测试带排除模式的owe功能
Write-Host "`n12. 重新存储文件测试owe排除功能:" -ForegroundColor Yellow
"所有内容" | Out-File -FilePath "test_new\all_content.txt" -Encoding UTF8
"临时文件" | Out-File -FilePath "test_new\temp.tmp" -Encoding UTF8
"备份文件" | Out-File -FilePath "test_new\backup.bak" -Encoding UTF8

"# 存储所有文件
test_new\*.*" | Out-File -FilePath "store_all_files.txt" -Encoding UTF8
cargo run -- store --list store_all_files.txt

Write-Host "`n13. 删除原始文件并测试排除提取:" -ForegroundColor Yellow
Remove-Item "test_new" -Recurse -Force

"# 提取除了临时文件外的所有文件
test_new\*.*
!test_new\*.tmp
!test_new\*.bak" | Out-File -FilePath "owe_with_exclusions.txt" -Encoding UTF8

cargo run -- owe --list owe_with_exclusions.txt

Write-Host "`n14. 验证排除提取结果:" -ForegroundColor Yellow
if (Test-Path "test_new\all_content.txt") {
    Write-Host "✓ all_content.txt 已恢复" -ForegroundColor Green
} else {
    Write-Host "✗ all_content.txt 恢复失败" -ForegroundColor Red
}

if (Test-Path "test_new\temp.tmp") {
    Write-Host "✗ temp.tmp 不应该被恢复（已排除）" -ForegroundColor Red
} else {
    Write-Host "✓ temp.tmp 正确排除" -ForegroundColor Green
}

if (Test-Path "test_new\backup.bak") {
    Write-Host "✗ backup.bak 不应该被恢复（已排除）" -ForegroundColor Red
} else {
    Write-Host "✓ backup.bak 正确排除" -ForegroundColor Green
}

# 清理测试文件
Write-Host "`n清理测试文件..." -ForegroundColor Yellow
Remove-Item "test_new" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "store_*.txt", "owe_*.txt" -Force -ErrorAction SilentlyContinue

Write-Host "`n=== 新功能测试完成 ===" -ForegroundColor Green
