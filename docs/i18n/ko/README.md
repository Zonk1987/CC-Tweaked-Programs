> [!WARNING]
> 🇰🇷 **ko / Korean**
> 
> 참고: 이 README는 AI 보조원(반중력)에 의해 자동으로 번역되었으며 번역 오류나 부정확한 내용이 포함될 수 있습니다. 가장 정확하고 최신 문서를 보려면 영어 원본을 참조하십시오. [README.md](../../../README.md).

🌐 **Languages:** [English](../../../README.md) | [Deutsch](../de/README.md) | [Español](../es/README.md) | [Français](../fr/README.md) | [Português (Brasil)](../pt-BR/README.md) | [日本語](../ja/README.md) | [한국어](../ko/README.md) | [Русский](../ru/README.md) | [简体中文](../zh-CN/README.md)

<div 정렬="중앙">

# Zonk의 CC:Tweaked 자동화 제품군 🚀

![CI Quality Checks](https://img.shields.io/github/actions/workflow/status/Zonk1987/CC-Tweaked-Programs/ci-checks.yml?branch=main&style=for-the-badge&label=CI%20Quality%20Checks)
![License](https://img.shields.io/github/license/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Zonk1987/CC-Tweaked-Programs/main?style=for-the-badge)
![Top Language](https://img.shields.io/github/languages/top/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)
![Open Issues](https://img.shields.io/github/issues/Zonk1987/CC-Tweaked-Programs?style=for-the-badge)

![Lua](https://img.shields.io/badge/Lua-5.1-blue?style=for-the-badge&logo=lua)
![CC:Tweaked](https://img.shields.io/badge/CC%3ATweaked-Compatible-orange?style=for-the-badge)
![Manifest Installer](https://img.shields.io/badge/Installer-Manifest--Driven-purple?style=for-the-badge)

</div>

모듈식 **기능 핵심** 아키텍처, 프리미엄 UI 미학, 강력한 매니페스트 기반 설치 프로그램을 특징으로 하는 Minecraft **CC:Tweaked**용 전문가급 자동화 스크립트 컬렉션입니다.


---

## 🚀 설치

**고급 컴퓨터**에서 이 명령을 실행하세요.

1. 저장소에서 install.lua 파일을 다운로드합니다.
```bash
wget https://raw.githubusercontent.com/Zonk1987/CC-Tweaked-Programs/main/install.lua
```
2. install.lua 파일을 실행하세요
```bash
install.lua
```

---

## 📦 사용 가능한 패키지

| ID | 이름 | 설명 | 주요 특징 |
|:---|:---|:---|:---|
| `메카니즘_포털_허브` | [**포털 다이얼러 허브**](../../../Mekanism%20Portal%20Dialer%20Hub/docs/i18n/ko/README.md) | 프리미엄 터치스크린 다이얼러. | 이동식 UI, 악센트 줄무늬, 페이지 재설정. |
| `mekanism_recall_sender` | [**포털 리콜 발신자**](../../../Mekanism%20Portal%20Dialer%20Recall%20Sender/docs/i18n/ko/README.md) | 원격 무선 트리거. | 하드웨어 진단, 실시간 상태 모니터링. |
| `create_crafter` | [**기계 제작가**](../../../Create%20Mechanical%20Crafter%20Automation/docs/i18n/ko/README.md) | 그리드 제작 자동화. | 기록 및 교정, 다단계 레시피. |
| `포와_구` | [**에너자이징 오브**](../../../Powah%20Energizing%20Orb%20Automation/docs/i18n/ko/README.md) | 병렬 제작 자동화. | ME Bridge 통합, 자동 복구. |
| `developer_suite` | [**CC 개발자 제품군**](../../../CC%20Developer%20Suite/docs/i18n/ko/README.md) | 진단 툴킷. | 이벤트 스니퍼, 주변 장치 검사자. |

---

## 🏗️ 아키텍처: 기능 핵심 뼈대

이 저장소는 모듈식 뼈대를 사용하여 유지 관리 및 성능을 위해 구축되었습니다.

### **핵심 모듈(`lib/core`)**
중복을 줄이기 위해 일반 유틸리티가 숨겨진 핵심 패키지로 추출됩니다.
- **`core.base`**: `ConfigStore`(JSON 지속성)와 같은 기본 논리.
- **`core.peripherals`**: 안전한 주변 장치 검색 및 래핑(`PeripheralScanner`).
- **`core.network`**: 표준화된 통신 프로토콜(`RednetProtocol`).
- **`core.redstone`**: Redstone 상호 작용 도우미(`RedstoneController`).
- **`core.ui`**: 재사용 가능한 UI 구성요소(`ButtonGrid`).
- **`core.inventory`**: 표준화된 인벤토리 처리(`InventoryAdapter`, `ItemMatcher`).
- **`core.recipes`**: JSON 지원 레시피 저장소(`RecipeStore`).

### **종속성 해결**
설치 프로그램은 자동으로 종속성을 재귀적으로 해결합니다. 예를 들어 `create_crafter`를 설치하면 필수 `core.inventory` 및 `core.redstone` 모듈이 자동으로 풀됩니다. 애플리케이션 파일은 루트 디렉터리에 배치되는 반면 핵심 라이브러리는 `lib/core/` 계층 구조(`startup.lua`에서 조정된 패키지 경로를 통해 액세스 가능)에 유지됩니다.

---

## 🛠️ 개발 지침

### **새 앱 추가**
1. 앱 폴더(예: 'My New App')를 만듭니다.
2. 기존 `lib/core` 모듈을 활용하여 로직을 구현합니다.
3. `manifest.lua`에 앱을 등록하세요.
4. 핵심 모듈을 사용하는 경우 종속성을 추가합니다.

### **핵심 모듈 추가**
1. `lib/core/<category>/ModuleName.lua`에 모듈을 배치합니다.
2. `manifest.lua`에 `hidden = true` 패키지로 등록합니다.

---

## ⚖️ 안전 및 규칙

이 저장소의 모든 코드는 **[AGENTS.md](../../../AGENTS.md)**에 의해 관리됩니다.
- **엄격 모드**: 응용 프로그램 스크립트와 항목 파일은 실수로 인한 전역 변수를 방지하기 위해 엄격한 환경을 사용합니다(현재 핵심 라이브러리는 현지화 상용구를 줄이기 위해 이를 우회합니다).
- **삭제 없음**: 설치 프로그램은 기존 사용자 파일을 절대 삭제하지 않습니다(완료 후 `manifest.lua` 및 `install.lua`와 같은 자체 임시 파일을 정리하거나 업데이트 중 이전 버전을 교체하는 경우 제외).
- **설치 상태 캐시**: 설치 프로그램은 설치된 파일 버전을 기억하기 위해 숨겨진 파일 `.install_state.json`을 생성합니다. 이렇게 하면 변경되지 않은 파일(`CACHED`로 표시됨)을 건너뛰어 향후 실행 속도를 높일 수 있습니다. 언제든지 이 파일을 삭제해도 안전합니다. 다음 설치 시 모든 항목을 다시 다운로드하기만 하면 됩니다.
- **자동 재부팅 없음**: 설치 프로그램은 항목 파일을 실행하기 전에 묻고 허가 없이 시스템을 재부팅하지 않습니다.
- **단일 앱 정책**: 고급 컴퓨터당 **하나**의 애플리케이션만 지원됩니다. 동일한 컴퓨터에 여러 앱을 설치하면 파일 충돌이 발생하고 'startup.lua' 또는 'Dashboard.lua'와 같은 중요한 파일을 덮어쓰게 됩니다.

---

## 📝 크레딧 및 문제 해결
Advanced Agentic Coding 이니셔티브의 일부로 **Antgravity**에서 개발했습니다.
문제가 발생하는 경우:
1. **고급 컴퓨터**를 사용하고 있는지 확인하세요.
2. `install.lua --validate`를 실행하여 매니페스트 오류를 ​​확인합니다.
3. 하드웨어별 설정을 보려면 각 응용 프로그램 폴더 내의 'README.md'를 확인하세요.

**[라이센스](../../../LICENSE)**: MIT





