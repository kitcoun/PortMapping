# 设置脚本编码为 UTF-8 BOM
$PSDefaultParameterValues['*-FileEncoding'] = 'utf8'
# 设置输出编码为控制台编码
$OutputEncoding = [Console]::OutputEncoding

$portMappingsv4tov4 = netsh interface portproxy show v4tov4
# 删除所有查询的端口转发
foreach ($portMapping in $portMappingsv4tov4) {
    $address =($portMapping -replace '\s+', ',' -split ',')
    $localIp = $address[0]
    $localPort = $address[1]
    netsh interface portproxy delete v4tov4 listenport=$localPort listenaddress=$localIp
    Write-Host "删除 $localIp $localPort"
}

$portMappingsv6tov4 = netsh interface portproxy show v6tov4
# 删除所有查询的端口转发
foreach ($portMapping in $portMappingsv6tov4) {
    $address =($portMapping -replace '\s+', ',' -split ',')
    $localIp = $address[0]
    $localPort = $address[1]
    netsh interface portproxy delete v6tov4 listenport=$localPort listenaddress=$localIp
    Write-Host "删除 $localIp $localPort"
}

# 窗口不会关闭，直到您按下任意键
Read-Output -Prompt "按任意键继续..."
