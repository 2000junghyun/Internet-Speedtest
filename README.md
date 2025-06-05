# Internet-Speedtest
Script for testing internet speed automatically
## 구현 방법
### 1. Speedtest CLI 설치
- 공식 Ookla CLI 다운로드
- Windows 기준: C:\SpeedtestCLI\speedtest.exe에 설치

### 2. 측정 PowerShell 스크립트 작성
- 다운로드, 업로드, 핑 정보를 측정
- 측정 결과를 CSV 형식으로 저장
- 날짜별 파일 구분 없이 하나의 파일에 누적 저장 방식 채택

### 3. 백그라운드에서 PowerShell 실행 (팝업 제거 처리)
- .ps1 파일을 직접 실행하지 않음
- .vbs 파일을 중개하여 PowerShell 창이 보이지 않도록 처리

### 4. 작업 스케줄러 설정
- 5분 간격 실행 설정
- 트리거 반복 시작 & 종료 시간 설정
- 실행 경로: wscript.exe "C:\SpeedtestCLI\RunSpeedtest.vbs"

### 5. 최종 검증 및 운영
- 로그 파일 자동 생성 확인
- 시스템 재부팅 이후에도 자동 측정 유지 확인
