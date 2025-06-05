# 측정 시간
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# speedtest.exe의 경로
$speedtestPath = "C:\SpeedtestCLI\speedtest.exe"

# 측정 실행 후 결과를 JSON으로 파싱
$json = & $speedtestPath --format=json | ConvertFrom-Json

# Mbps 단위로 변환 (bandwidth는 bytes/sec)
$downloadMbps = [math]::Round($json.download.bandwidth * 8 / 1000000, 2)
$uploadMbps = [math]::Round($json.upload.bandwidth * 8 / 1000000, 2)
$pingMs = [math]::Round($json.ping.latency, 2)

# 저장할 행 구성
$row = "$timestamp,$pingMs,$downloadMbps,$uploadMbps"

# 날짜별로 파일명 지정 (예: 2025-06-05.csv)
$today = Get-Date -Format "yyyy-MM-dd"
$csvPath = "C:\SpeedtestCLI\$today.csv"

# 파일이 없으면 헤더 추가
if (!(Test-Path $csvPath)) {
    "Timestamp,Ping (ms),Download (Mbps),Upload (Mbps)" | Out-File -FilePath $csvPath -Encoding utf8
}

# 측정 결과를 파일에 추가
$row | Out-File -Append -FilePath $csvPath -Encoding utf8

Write-Host "Speedtest completed: $row"