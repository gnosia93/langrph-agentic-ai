## LangGraph로 Agentic AI 만들기 ##


* 오전: 기본기 (A의 1~4)
* 오후 1부: 멀티 에이전트 — Supervisor 패턴, Swarm 패턴
* 오후 2부: LangGraph Platform — 커스텀 인증(OAuth), 리소스 ACL, Postgres 체크포인터
* 오후 3부: 관측성 — LangSmith로 트레이싱, 평가(evaluation) 파이프라인
결과물: 멀티 에이전트가 인증된 사용자별로 격리돼 작동하고, LangSmith에서 추적·평가까지 되는 시스템.

---
각 모듈 상세
```
M1. LangGraph 기본기 (60분)
목표: "그래프"라는 사고방식을 몸에 익힌다.

LangChain vs LangGraph — 체인에서 그래프로 넘어가는 이유
핵심 3요소: State, Node, Edge
StateGraph 컴파일과 호출(invoke, stream)
리듀서(add_messages) 개념
실습 1-1: "에코 그래프" — 사용자 메시지를 받아 대문자로 바꿔 돌려주는 단일 노드 그래프. 실습 1-2: 두 노드를 연결해 translate → summarize 직선 파이프라인 만들기.

체크포인트: graph.get_graph().draw_mermaid()로 그래프 구조를 그려 볼 수 있어야 통과.

M2. 도구 + 조건부 라우팅 + HITL (75분)
목표: 실제 업무 에이전트의 뼈대 패턴을 모두 경험한다.

@tool 데코레이터로 도구 정의
ToolNode와 tools_condition
조건부 엣지(add_conditional_edges)로 분기 설계
interrupt로 사람 승인 끼워 넣기
실습 2-1: 날씨 조회 + 계산기 도구를 가진 ReAct 에이전트. 실습 2-2: 도구가 외부에 쓰기 작업(예: 이메일 전송)을 할 때, 실행 직전에 interrupt로 멈추고 사람이 승인한 뒤에만 진행하도록 개조.

결과물: "민감 작업은 사람 승인, 나머지는 자동"으로 동작하는 에이전트.

M3. 멀티 에이전트 — Supervisor 패턴 (75분)
목표: 역할 분담이 필요한 시스템을 Supervisor로 조율한다.

Supervisor의 기본 아이디어: 한 명의 LLM 라우터가 하위 에이전트를 지휘
langgraph-supervisor 라이브러리 사용
하위 에이전트가 끝나면 Supervisor로 복귀하는 제어 흐름
Supervisor 자체 프롬프트 설계 요령
실습 3-1: 세 개의 전문가 에이전트 조합

researcher — 웹/DB 조회 도구 사용
coder — Python REPL 도구 사용
writer — 최종 보고서 작성
supervisor — 사용자의 질문을 보고 누구에게 맡길지 결정
시나리오: "최근 1주간 EC2 c7g 인스턴스 가격 변동을 조사해 파이썬으로 그래프를 그리고 보고서로 정리해 줘."

M4. Swarm 패턴 (60분)
목표: Supervisor 없이 에이전트끼리 직접 핸드오프하는 패턴을 이해한다.

langgraph-swarm의 핸드오프 개념
Supervisor와의 차이: 중앙 라우터가 없고, 마지막으로 말한 에이전트가 다음 턴을 받음
고객 상담 같은 "페르소나 간 전환" 시나리오에 잘 맞는 이유
실습 4-1: 여행 예약 Swarm

flight_agent, hotel_agent, car_rental_agent
각 에이전트가 "내 소관이 아니다 싶으면" 다른 에이전트로 핸드오프
```


### [1. 주피터 설정] ###

### [2. @tool 콜링](https://github.com/gnosia93/langgraph-agentic-ai/blob/main/lesson/6-tool-calling.md) ###

### 3. OAuth ###


### 4. 상태와 메모리 ###
  - LangGraph State: 그래프 전체에서 공유되는 상태
  - 단기 메모리: 대화 컨텍스트 (MessagesState)
  - 장기 메모리: 사용자 프로필, 선호도 (외부 저장소)
  - 실습: 이전 대화 기억하는 에이전트

### 5. 세션과 영속성 ###
  - Checkpointer: 대화 상태 저장/복구
  - 세션 ID 관리, 타임아웃
  - 실습: Redis/Postgres 체크포인터 붙이기

### [6. 관측성 (Langfuse)](https://github.com/gnosia93/langgraph-agentic-ai/blob/main/lesson/6-langfuse.md) ###

### [7. Open WebUI 연동](https://github.com/gnosia93/langgraph-agentic-ai/blob/main/lesson/6-llm-webui.md) ###
 
### 2. RAG를 에이전트 도구로 (L5와 연결) ###
  - L5에서 만든 RAG를 @tool로 감싸기
  - 에이전트가 "검색이 필요한지" 스스로 판단
  - 실습: 질문에 따라 RAG 쓸지 말지 결정하는 에이전트
