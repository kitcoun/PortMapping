# powershell脚本本金自动映射docker

# 设置脚本编码为 UTF-8 BOM
$PSDefaultParameterValues['*-FileEncoding'] = 'utf8'
# 设置输出编码为控制台编码
$OutputEncoding = [Console]::OutputEncoding

 #首先随意执行一条wsl指令，确保wsl启动，这样后续步骤才会出现WSL网络
echo "正在检测wsl运行状态..."
 wsl --cd ~ -e ls
#  启用docker
 wsl sudo service docker start
 

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

# 获取 WSL2 宿主机的 IP地址
$wslIpv4 =  (wsl hostname -I).Trim().Split(' ')[0]
Write-Host "WSL2的IP地址:$wslIpv4"
# netsh interface portproxy add v4tov4  listenport=8096 listenaddress=0.0.0.0  connectport=8096 connectaddress=$wslIpv4
# netsh interface portproxy add v4tov4  listenport=8920 listenaddress=0.0.0.0  connectport=8920 connectaddress=$wslIpv4
# netsh interface portproxy add v4tov4  listenport=1900 listenaddress=0.0.0.0  connectport=1900 connectaddress=$wslIpv4
# netsh interface portproxy add v4tov4  listenport=7359 listenaddress=0.0.0.0  connectport=7359 connectaddress=$wslIpv4

$containers = wsl docker container ls --format '{{json .}}' | ConvertFrom-Json
$portMapping = @{}
foreach ($container in $containers) {
    # 获取端口映射信息
    $remotePorts = $container.Ports.Split(',') | ForEach-Object { $_.Split('->')[0].Split(':')[-1] }
    foreach ($ports in $remotePorts) {
        $portMapping[$ports] = $ports
        # Write-Host $ports
    }
}

# 输出 Docker 所有容器使用的端口
foreach ($key in $portMapping.Keys) {
    $port = $portMapping[$key]    
    netsh interface portproxy add v4tov4  listenport=$key listenaddress=0.0.0.0  connectport=$key connectaddress=$wslIpv4
    netsh interface portproxy add v6tov4  listenport=$key listenaddress=::  connectport=$key connectaddress=$wslIpv4
    Write-Host "Docker映射到主机端口 $port"
}

# $wslIpv6 =  ((wsl ip addr show eth0 | Select-String -Pattern "inet6").ToString().Split() | Select-String -Pattern "/64").ToString().Split('/')[0].Trim()
# netsh interface portproxy add v6tov6 listenaddress=:: listenport=8096 connectaddress=$wslIpv6  connectport=8096
# netsh interface portproxy add v6tov6 listenaddress=:: listenport=8920 connectaddress=$wslIpv6  connectport=8920
# netsh interface portproxy add v6tov6 listenaddress=:: listenport=1900 connectaddress=$wslIpv6  connectport=1900
# netsh interface portproxy add v6tov6 listenaddress=:: listenport=7359 connectaddress=$wslIpv6  connectport=7359

netsh interface portproxy show all
# 窗口不会关闭，直到您按下任意键
Read-Host -Prompt "按任意键继续..."
