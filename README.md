# Automation: Internet-Speedtest
Script for testing internet speed automatically

## 1. Speedtest CLI 설치

### 공식 다운로드

1. https://www.speedtest.net/apps/cli
2. Windows용 `.zip` 파일 다운로드 (예: `speedtest-win64.zip`)
3. 압축 해제 후, `C:\SpeedtestCLI\` 폴더에 저장

### `speedtest.exe` 설치 확인

1. speedtest.exe 실행 (더블 클릭)
2. PowerShell 관리자 모드로 실행
3. 다음 명령 실행 (폴더로 이동하거나 전체 경로 지정):

```powershell
cd C:\SpeedtestCLI
.\speedtest.exe --version
```

## 2. 인터넷 속도 측정

아직 자동화는 하지 않고, 직접 한 번 실행

### PowerShell에서 측정 준비

1. Powershell 관리자 모드로 실행
2. PowerShell 스크립트 실행 허용

```vbnet
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

### 인터넷 속도 테스트

```powershell
cd C:\SpeedtestCLI
.\speedtest.exe --format=json

{"type":"result","timestamp":"2025-06-16T16:14:42Z","ping":{"jitter":3.592,"latency":5.581,"low":3.328,"high":10.580},"download":{"bandwidth":65047341,"bytes":624157784,"elapsed":15008,"latency":{"iqm":40.610,"low":5.286,"high":60.373,"jitter":11.604}},"upload":{"bandwidth":65693153,"bytes":691259582,"elapsed":11325,"latency":{"iqm":26.971,"low":3.811,"high":262.895,"jitter":17.044}},"packetLoss":0,"isp":"Cox Business","interface":{"internalIp":"10.1.0.123","name":"","macAddr":"18:93:41:7D:EF:6F","isVpn":false,"externalIp":"70.168.153.114"},"server":{"id":16620,"host":"speedtest.rd.oc.cox.net","port":8080,"name":"Cox - Orange County","location":"Orange County, CA","country":"United States","ip":"184.182.243.145"},"result":{"id":"780b15e4-e9a9-49a2-b967-d98038e85418","url":"https://www.speedtest.net/result/c/780b15e4-e9a9-49a2-b967-d98038e85418","persisted":true}}
```

## 3. CSV 파일로 저장 (PowerShell)

### 로그 디렉토리 생성 (`C:\SpeedtestCLI\Logs`)

### 스크립트 작성 (`speedtest_logger.ps1`)

```vbnet
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$speedtestPath = "C:\SpeedtestCLI\speedtest.exe"

# 측정 실행 후 결과를 JSON으로 파싱
$json = & $speedtestPath --format=json | ConvertFrom-Json

# Mbps 단위로 변환
$downloadMbps = [math]::Round($json.download.bandwidth * 8 / 1000000, 2)
$uploadMbps = [math]::Round($json.upload.bandwidth * 8 / 1000000, 2)
$pingMs = [math]::Round($json.ping.latency, 2)

# 저장할 행 구성
$row = "$timestamp,$pingMs,$downloadMbps,$uploadMbps"

# 날짜별로 파일명 지정
$today = Get-Date -Format "yyyy-MM-dd"
$csvPath = "C:\SpeedtestCLI\Logs\$today.csv"

# 파일이 없으면 헤더 추가
if (!(Test-Path $csvPath)) {
    "Timestamp,Ping (ms),Download (Mbps),Upload (Mbps)" | Out-File -FilePath $csvPath -Encoding utf8
}

# 측정 결과를 파일에 추가
$row | Out-File -Append -FilePath $csvPath -Encoding utf8

Write-Host "Speedtest completed: $row"
```

- 다운로드, 업로드, 핑 정보를 측정
- 측정 결과를 CSV 형식으로 저장
- 날짜별 파일 구분 없이 **하나의 파일에 누적 저장**

### 스크립트 테스트

```powershell
cd C:\SpeedtestCLI
.\speedtest_logger.ps1

Speedtest completed: 2025-06-16 09:15:29,3.44,706.14,495.54
```

CSV 파일이 아래 경로에 생성:

📄 `C:\SpeedtestCLI\Logs\2025-06-16.csv`

### VBScript 파일 생성 (`RunSpeedtest.vbs`)

- .vbs 파일을 중개하여 PowerShell 창이 보이지 않도록 처리
- 저장 경로: `C:\SpeedtestCLI\RunSpeedtest.vbs`

```
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""C:\SpeedtestCLI\speedtest_logger.ps1""", 0, False
```

## 4. 작업 스케줄러 설정

### Search > Task scheduler

1. **"Create Task"** 클릭

2. **General**
    - Name: `Speedtest Logger`
    - Description: `인터넷 속도 자동 측정 및 CSV 기록`
    - “Run with highest privileges” 체크
    - Configure for: **Windows 10 이상** 선택
3. **Triggers**
    - Settings: One time
    - Start: `2025-06-05 08:00:00`
    - Repeat task every: `10 minutes`
    - **For a duration of:** `12 hours`
4. **Actions**
    - Action: Start a program
    - Program/script:
        
        ```
        wscript.exe
        ```
        
    - Add arguments (optional):
        
        ```
        "C:\SpeedtestCLI\RunSpeedtest.vbs"
        ```
        
5. **Conditions**
    - 모두 체크 해제
6. **Settings (아래 항목 체크)**
    - Allow task to be run on demand
    - Run task as soon as possible after a scheduled start is missed
    - Stop the task if it runs longer then: 2 hours
    - If the running task does not end when requested, force it to stop

### `C:\SpeedtestCLI\Logs` 안에 `.csv 파일`이 생기고 결과가 쌓이면 성공!
