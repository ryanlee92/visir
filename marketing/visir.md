# Visir Product Specification & Analysis

**Visir**는 분산된 커뮤니케이션 채널(이메일, 메신저)과 업무 관리 도구(캘린더, 투두리스트)를 하나의 인터페이스로 통합한 **AI 기반 올인원 생산성 플랫폼(Unified Productivity Platform)**입니다.

사용자의 커뮤니케이션 데이터(Input)를 즉시 실행 가능한 태스크(Action)로 변환하는 워크플로우에 최적화되어 있으며, 전체 데이터를 관장하는 AI 에이전트를 통해 맥락(Context) 기반의 업무 보조를 수행합니다.

---

## 1. 핵심 UI/UX 구조 (User Interface Structure)

Visir는 정보의 밀도를 높이면서도 가독성을 유지하는 **3-Pane Layout**을 채택하고 있습니다.

### A. Navigation Rail (Left Sidebar)
각 탭의 주요 모듈 간 이동을 담당하는 영역입니다.
* **Home Mode:** 전체 업무 현황을 보여주는 인텔리전트 대시보드.
* **Agent:** 사용자의 데이터와 연동된 AI와의 대화형 인터페이스.
* **Project:** 사용자 정의 프로젝트별 분류 (예: WAVE Corp, Viral, Release 등). 이메일, 슬랙 채널 등을 프로젝트 단위로 묶어서 관리.
* **Calendar:** 일정 및 태스크 통합 뷰.
* **View Type:** 캘린더/태스크 뷰 기간 설정 (1일, 2일, 3일... 1주 등).

### B. Main Workspace (Center)
선택한 모듈의 핵심 콘텐츠가 표시되는 영역입니다.
* 대시보드 위젯, 칸반 보드, 캘린더 타임라인, 채팅방 목록 등이 상황에 맞게 렌더링됩니다.

### C. Context Panel (Right Sidebar)
현재 작업의 맥락을 유지하며 보조 정보를 표시하는 영역입니다.
* **Next Schedule:** 다가오는 일정을 타임라인 형태로 고정 표시.
* **Detail Overlay:** 이메일이나 메시지를 클릭했을 때 화면 전환 없이 오버레이 형태로 내용을 표시하여 즉시 처리 가능.

---

## 2. 주요 기능 및 워크플로우 (Key Features & Workflow)

### A. Home Mode (Intelligent Dashboard)
사용자가 접속 시 가장 먼저 마주하는 화면으로, "지난 24시간 동안 처리해야 할 인박스 항목"을 요약합니다.
* **Project Cards:** 각 프로젝트별 이슈를 시각화 (예: WAVE Corp - 중요 2건, 긴급 1건).
* **Inbox Highlights:** 이메일, 시스템 알림, 메신저 대화를 AI가 분석하여 여러가지 카테고리로 자동 분류.
    EX.
    * `Customer Contact` (고객 연락)
    * `Question` (질문/요청)
    * `Info Sharing` (정보 공유)
    * `Announcement` (공지사항)

### B. 통합 인박스 & 액션 변환 (Unified Inbox to Action)
Visir의 핵심 가치는 **"읽는 행위"와 "계획하는 행위"의 통합**입니다.
* **Drag & Drop Time Blocking:** 인박스에 있는 이메일이나 메시지 카드를 마우스로 드래그하여 우측 'Next Schedule' 타임라인의 특정 시간대로 옮기면, 즉시 해당 시간에 할당된 일정/태스크가 됩니다.
* **Convert to Task:** 이메일/챗 본문을 읽는 도중 상단 툴바의 버튼을 통해 즉시 `Task` 또는 `Event`로 변환할 수 있습니다.
* **Contextual Overlay:** 메일/챗을 열어도 전체 화면이 바뀌지 않고 팝업 형태로 떠서, 기존 작업을 방해하지 않고 내용을 확인/처리할 수 있습니다.
* **On-Window Reply:** 캘린더뷰나 inbox에서 팝업 형태로 메일/챗을 열수 있을 뿐 아니라 바로 reply할수도 있습니다. 계획이나 플래닝을 하는 도중에 집중을 깨지 않고 contextual-conversation을 이어갈수 있습니다.

### C. AI Agent (Context-Aware Assistant)
단순한 챗봇이 아닌, 사용자의 캘린더, 이메일, 완료된 태스크 로그에 접근 권한을 가진 에이전트입니다.
* **Natural Language Query:** "오늘 내가 뭘 했지?", "이번 주 중요 일정 요약해줘"와 같은 자연어 질문 처리.
* **Activity Search:** 연결된 캘린더와 태스크 완료 기록을 검색하여 구체적인 업무 내역("Review app status 완료함" 등)을 요약 답변.
* **System Prompt Customization:** 사용자가 AI의 페르소나나 응답 방식을 설정 메뉴에서 직접 커스터마이징 가능.
* **Previous Context Summurizing:** Up Next 섹션에서 다가올 미팅 / 할일의 이전 context를 요약해서 확인하고 일정을 진행할 수 있습니다.
* **Tagged Context Conversation:** 메일, 챗, 테스크, 이벤트를 버튼 클릭이나 control + l 단축키로 태그하여 ai chat 을 시작할 수 있음.

### D. Vertical Productivity Apps For Each Tabs
* **Chat Integration:** Slack과 같은 메신저가 'Channel' 탭에 통합됨. 채널별 대화를 Visir 내에서 읽고, 중요 메시지를 핀(Pin)하거나 태스크화 가능.
* **Mail Client:** Gmail, Outlook 등과 연동. "Turn mail into tasks" 기능이 상시 활성화되어 있어 이메일 처리가 업무 관리로 직결됨.
* **Task Client:** Visir 앱 자체의 Task 앱. Todoist와 같은 할일 관리를 위한 기능을 제공함
* **Calendar Client:** Google Calendar, Outlook calendar 등과 연동. task, calendar event를 모두 하나의 캘린더에서 관리. side calendar로 월별 뷰를 항상 볼수 있고, main calendar에서는 상세한 일정 관리

---

## 3. 시스템 설정 및 기술 사양 (Preferences & Specs)

### Integrations (연동성)
외부 서비스 계정을 연결하여 Visir를 허브로 사용합니다.
* **Calendar:** Google Calendar, Outlook Calendar
* **Email:** Gmail, Outlook
* **Chat:** Slack (Channels, DMs)

### AI Configuration
* **API Key:** 사용자의 OpenAI API Key를 직접 입력하여 연동 가능.
* **Plans:** 구독 모델(Pro/Ultra)에 따라 월간 AI 토큰 제공량(100K ~ 500K) 및 모델 지원 범위 차등.

### Project Management
* **Grouping:** 파편화된 소스를 하나의 'Project'로 맵핑하여 관리. Task의 경우 Ai 가 추천하거나 유저가 직접 project를 지정할수 있으며, inbox의 경우 ai-suggestion을 기준으로 project id 할당
* **Tree Structure:** 프로젝트간의 부모-자식 구조화 가능. 특정 프로젝트에 대한 ai 요청을 실행할때 해당 프로젝트와 자식 프로젝트에 속한 task들을 ai context에 포함.

---

## 4. AI 이해를 위한 요약 (Summary for AI Context)

> **Visir는 단순한 생산성 도구가 아니라, 사용자의 디지털 파편(이메일, 메시지, 일정)을 모아 '실행'으로 연결하는 오케스트레이터입니다.**
>
> 가장 큰 특징은 UI/UX적으로 **Input(수신함) → Output(캘린더/태스크)**의 장벽을 허물었다는 점입니다(Drag & Drop). 또한 내장된 AI는 이 모든 연결된 데이터의 맥락을 이해하고 있어, 사용자의 비서로서 과거를 회고하고 미래를 계획하는 데 실질적인 도움을 줄 수 있습니다.