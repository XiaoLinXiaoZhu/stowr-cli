# STOWR 功能测试脚本

Write-Host "=== STOWR 功能测试 ===" -ForegroundColor Green

# 1. 显示版本信息
Write-Host "`n1. 测试版本信息:" -ForegroundColor Yellow
cargo run -- version

# 2. 显示帮助信息
Write-Host "`n2. 测试帮助信息:" -ForegroundColor Yellow
cargo run -- help

# 3. 查看默认配置
Write-Host "`n3. 查看默认配置:" -ForegroundColor Yellow
cargo run -- config --list

# 4. 创建测试文件
Write-Host "`n4. 创建测试文件:" -ForegroundColor Yellow
"This is test content for STOWR.`nLine 2`nLine 3" | Out-File -FilePath "test1.txt" -Encoding UTF8
"Another test file with different content." | Out-File -FilePath "test2.txt" -Encoding UTF8

# 5. 存储单个文件
Write-Host "`n5. 存储单个文件:" -ForegroundColor Yellow
cargo run -- store test1.txt

# 6. 存储多个文件
Write-Host "`n6. 存储多个文件:" -ForegroundColor Yellow
"test2.txt" | Out-File -FilePath "batch_list.txt" -Encoding UTF8
cargo run -- store --list batch_list.txt

# 7. 列出存储的文件
Write-Host "`n7. 列出存储的文件:" -ForegroundColor Yellow
cargo run -- list

# 8. 重命名文件
Write-Host "`n8. 重命名文件:" -ForegroundColor Yellow
cargo run -- rename test1.txt renamed_test.txt

# 9. 再次列出文件确认重命名
Write-Host "`n9. 确认重命名:" -ForegroundColor Yellow
cargo run -- list

# 10. 删除原始文件，测试提取
Write-Host "`n10. 删除原始文件并测试提取:" -ForegroundColor Yellow
Remove-Item test2.txt -ErrorAction SilentlyContinue
cargo run -- owe test2.txt

# 11. 验证文件已恢复
Write-Host "`n11. 验证文件已恢复:" -ForegroundColor Yellow
if (Test-Path test2.txt) {
    Write-Host "文件 test2.txt 已成功恢复" -ForegroundColor Green
    Get-Content test2.txt
} else {
    Write-Host "文件恢复失败" -ForegroundColor Red
}

# 12. 检查文件是否从存储中移除
Write-Host "`n12. 检查文件是否从存储中移除:" -ForegroundColor Yellow
cargo run -- list

# 13. 删除存储的文件
Write-Host "`n13. 删除存储的文件:" -ForegroundColor Yellow
cargo run -- delete renamed_test.txt

# 14. 最终检查
Write-Host "`n14. 最终检查存储状态:" -ForegroundColor Yellow
cargo run -- list

# 15. 修改配置测试
Write-Host "`n15. 测试配置修改:" -ForegroundColor Yellow
cargo run -- config index.mode sqlite
cargo run -- config --list

# 清理测试文件
Write-Host "`n清理测试文件..." -ForegroundColor Yellow
Remove-Item test1.txt, test2.txt, batch_list.txt -ErrorAction SilentlyContinue

Write-Host "`n=== 测试完成 ===" -ForegroundColor Green
