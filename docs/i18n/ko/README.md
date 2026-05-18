> [!WARNING]
> 🇰🇷 **ko / 한국어**
> 
> ⚠️ **참고**: 이 README는 AI 비서(Antigravity)에 의해 자동 번역되었으며, 번역 오류나 부정확한 내용이 포함되어 있을 수 있습니다. 가장 정확하고 최신 문서가 필요한 경우 영문 원본 [README.md](../../../README.md)를 참조하십시오.

<div align="center">

# Zonk's CC:Tweaked Automation Suite 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

마인크래프트 **CC:Tweaked** 컴퓨터용 모듈식 **Feature-Core** 구조, 프리미엄 UI 디자인 및 강력한 설치 프로그램을 특징으로 하는 전문 자동화 스크립트 모음집입니다.

---

## 🚀 설치 방법

**고급 컴퓨터 (Advanced Computer)**에서 다음 명령을 실행합니다.

1. 리포지토리에서 `install.lua` 파일을 다운로드합니다.
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. 다운로드한 `install.lua` 파일을 실행합니다.
```bash
install.lua
```

---

## 📦 이용 가능한 패키지

| ID | 이름 | 설명 | 핵심 기능 |
|:---|:---|:---|:---|
| `mekanism_portal_hub` | **Portal Dialer Hub** | 고급 터치스크린 포털 다이얼러. | 이동 가능한 UI, 버튼 테두리 강조, 페이지 자동 초기화. |
| `mekanism_recall_sender`| **Portal Recall Sender** | 원격 무선 활성화 트리거. | 하드웨어 자가 진단 및 감지, 실시간 상태 모니터링. |
| `create_crafter` | **Mechanical Crafter** | 자동 조합 그리드 시스템. | 인게임 레시피 녹화 및 보정, 다단계 레시피 지원. |
| `powah_orb` | **Energizing Orb** | 병렬 충전 조합 시스템. | ME Bridge 연동, 걸림 현상 및 정전 시 자동 복구 기능. |
| `developer_suite` | **CC Developer Suite** | 시스템 디버그 및 진단 도구. | 이벤트 스니퍼, 주변 장치 포트 모니터링. |

---

## 🏗️ 아키텍처: Feature-Core Skeleton 모듈 구조

본 저장소는 향후 유지보수의 용이함과 가벼운 동작 성능을 위해 모듈식 뼈대 구조로 설계되었습니다.

### **핵심 라이브러리 모듈 (`lib/core`)**
반복되는 범용 유틸리티는 정리하기 쉽도록 숨겨진 코어 패키지로 따로 분류되어 있습니다:
- **`core.base`**: `ConfigStore` (JSON 기반 데이터 저장 및 유지) 등의 기본 시스템 로직.
- **`core.peripherals`**: 연결된 모뎀 주변 장치의 안전한 감지 및 래핑 기능 (`PeripheralScanner`).
- **`core.network`**: 표준화된 무선 통신용 모뎀 프로토콜 (`RednetProtocol`).
- **`core.redstone`**: 레드스톤 출력 인터랙션 도우미 (`RedstoneController`).
- **`core.ui`**: 재사용 가능한 UI 렌더링 모듈 (`ButtonGrid`).
- **`core.inventory`**: 표준화된 아이템 이동 및 수량 핸들링 (`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: JSON 기반 저장소에 레시피 패턴을 로드 및 검색하는 기능 (`RecipeStore`).

### **의존성 자동 해결 기능**
설치 프로그램은 패키지의 의존 관계를 재귀적으로 자동 탐색합니다. 예를 들어 `create_crafter`를 단독 설치하더라도 작동에 필수적인 `core.inventory` 및 `core.redstone` 라이브러리를 자동으로 탐색하고 설치합니다. 애플리케이션 코드는 저장소의 루트에 놓이며 코어 라이브러리는 `lib/core/` 하위 경로에 위치합니다 (`startup.lua`에서 라이브러리 탐색 절대 경로를 보정합니다).

---

## 🛠️ 개발 지침서

### **새 앱 등록 방법**
1. 새로운 폴더를 생성합니다 (예: `My New App`).
2. 기존 `lib/core` 라이브러리를 활용하여 작동 로직을 작성합니다.
3. `manifest.lua`에 자신의 새로운 애플리케이션을 선언합니다.
4. 코어 라이브러리를 사용하는 경우 의존성을 정의합니다.

### **새 코어 라이브러리 추가 방법**
1. 모듈을 `lib/core/<카테고리>/ModuleName.lua`에 생성합니다.
2. `manifest.lua`에 숨겨진 라이브러리 패키지로 지정합니다 (`hidden = true`).

---

## ⚖️ 안전 규정 & 실행 수칙

이 저장소에 존재하는 모든 Lua 스크립트는 **[AGENTS.md](./AGENTS.md)**에 명시된 규칙을 따릅니다:
- **안전 환경 (Strict Mode)**: 애플리케이션 스크립트와 실행 파일은 의도치 않은 전역 변수 오염을 방지하기 위해 엄격한 격리 환경에서 시작됩니다 (공용 코어 모듈들은 번거로움을 줄이기 위해 엄격 환경 규칙에서 제외되어 있습니다).
- **비파괴적 다운로드**: 설치기는 사용자의 기존 파일을 사전에 고지 없이 지우지 않습니다 (설치 완료 후 제거되는 임시 선언용 파일 `manifest.lua`와 `install.lua` 또는 업그레이드로 인한 신규 덮어쓰기는 예외).
- **설치 이력 캐시 저장**: 설치기는 `.install_state.json` 이라는 숨겨진 파일을 생성하여 각 파일의 버전을 기억합니다. 이를 통해 다음 실행 속도를 비약적으로 늘리며 변경점이 없는 파일 다운로드를 건너뜁니다 (`CACHED`로 표기). 이 파일은 지우더라도 다음 설치 시 전체 다운로드로 동작할 뿐, 언제든 자유롭게 지워도 작동에 무방합니다.
- **강제 재부팅 금지**: 설치기는 스크립트 설치 후 앱을 자동으로 켜거나 재부팅하기 전 확인 과정을 거칩니다.
- **1컴퓨터 1프로그램 권장**: 여러 애플리케이션 충돌과 오버라이드를 방지하기 위해 각 고급 컴퓨터마다 단 하나의 애플리케이션만 올려두고 작동하기를 권장합니다. 여러 개를 설치하는 경우 `startup.lua` 또는 `Dashboard.lua`가 서로 덮어쓰여 작동에 문제가 발생할 수 있습니다.

---

## 📝 크레딧 & 문제 해결 가이드

개발자: **Antigravity** (Advanced Agentic Coding 이니시아티브의 일원으로 구현됨)
작동에 문제가 발생하는 경우:
1. 해당 컴퓨터가 **Advanced Computer** (금색 컴퓨터)인지 확인하세요.
2. `install.lua --validate`를 터미널에 넣어 설치 정보 무결성을 체크해보세요.
3. 각 프로그램 폴더 내부에 포함된 개별 `README.md`를 열고 세부 기계장치 설정을 살펴보세요.

**[오픈소스 라이선스](./LICENSE)**: MIT
