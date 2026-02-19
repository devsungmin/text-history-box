# TextHistoryBox 📋

**TextHistoryBox**는 화면상의 텍스트를 인식하여 히스토리에 저장하고, 단축키로 간편하게 다시 복사할 수 있는 macOS용 텍스트 히스토리 관리 도구입니다.

## 🚀 주요 기능

- **화면 텍스트 인식**: 단축키를 사용하여 화면에 표시된 텍스트를 즉시 인식하고 복사합니다.
- **히스토리 관리**: 최근 복사된 텍스트를 최대 20개까지 저장하며, 클릭 한 번으로 다시 복사할 수 있습니다.
- **스마트 단축키**: 
  - 기본 단축키: `Command + Shift + H` (히스토리 박스 열기/닫기)
  - 텍스트 인식: `Command + Shift + 2`
  - 리스트 선택: 히스토리 박스에서 숫가 키(`1`~`0`)를 눌러 해당 항목을 즉시 복사할 수 있습니다.
- **다국어 지원**: 한국어와 영어를 기본적으로 인식합니다.
- **사용자 경험**: 텍스트 복사 후 히스토리 박스가 자동으로 숨겨지며, 직관적인 UI를 제공합니다.

## 🛠 시스템 요구 사항

- **OS**: macOS 13.0 (Ventura) 이상
- **Tool**: Swift 5.9 이상

## 📦 빌드 및 설치

제공된 `Makefile`을 사용하여 간편하게 빌드하고 설치할 수 있습니다.

### 디버그 빌드 및 실행
```bash
make run
```

### 애플리케이션 설치 (/Applications)
```bash
make install
```

### DMG 패키지 생성
```bash
make dmg
```

### 빌드 산출물 정리
```bash
make clean
```

## 📂 프로젝트 구조

- `Sources/TextHistoryBox`: 실제 로직 및 UI 코드
  - `HistoryManager.swift`: 복사된 텍스트 히스토리 관리
  - `ScreenCaptureManager.swift`: 화면 캡처 및 OCR 처리
  - `HotKeyManager.swift`: 전역 단축키 관리
  - `HistoryPanel.swift`, `HistoryView.swift`: 히스토리 인터페이스
  - `SettingsManager.swift`: 사용자 설정 관리
- `Package.swift`: Swift Package Manager 설정
- `Makefile`: 빌드 및 배포 자동화 스크립트

## ⚖️ License

이 프로젝트는 개인적인 용도로 개발되었습니다.
