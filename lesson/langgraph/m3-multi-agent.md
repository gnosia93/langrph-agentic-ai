## 멀티 에이전트 ##

한 에이전트에 도구 10개, 프롬프트 5천 토큰을 몰아넣으면 금세 무너진다. 증상은 뻔하다.

* 도구 선택이 부정확해짐 (선택지 과다)
* 프롬프트가 길어져 초반 지시를 잊음
* 한 역할(코드 작성)의 실수가 다른 역할(분석)의 맥락을 오염
해결책은 역할별로 에이전트를 나누고, 조율자를 두는 것이다. 그 조율자를 Supervisor라고 부른다.

### 1. 수퍼바이저 패턴 ###
```
                 사용자
                   │
                   ▼
            ┌──────────────┐
            │  Supervisor  │   ← 라우터 역할 LLM
            └──────┬───────┘
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │analyst │ │architect│ │ writer │
   └────────┘ └────────┘ └────────┘
        │          │          │
        └──────────┴──────────┘
                   │
             끝나면 복귀
```
#### 핵심 원칙 세 가지 ####
* Supervisor는 직접 일을 하지 않는다. 누가 다음에 일할지만 고른다.
* 하위 에이전트는 자기 역할만 안다. 다른 에이전트가 뭘 하는지 몰라도 된다.
* 모든 제어권은 Supervisor로 복귀한다. 하위 에이전트가 끝나면 반드시 Supervisor가 다음을 결정한다.
이 구조 덕분에 각 에이전트의 프롬프트와 도구 목록을 작게 유지할 수 있다. 이게 멀티 에이전트의 진짜 이득이다.

### 2. 핵심 개념 ###
#### 2-1. create_react_agent로 하위 에이전트 만들기
이전 챕터에서 직접 그래프를 짰지만, 실무에선 헬퍼 함수를 쓴다. 내부적으로 ReAct 루프가 구현돼 있다.
```
from langgraph.prebuilt import create_react_agent

analyst = create_react_agent(
    model=llm,
    tools=[list_ec2_instances, get_pricing],
    name="analyst",              # Supervisor가 이 이름으로 호출
    prompt="너는 AWS 인프라 현황 분석 담당이다. ...",
)
```
name 인자가 중요하다. Supervisor가 이 이름으로 라우팅한다.

#### 2-2. langgraph-supervisor로 조율자 만들기 ###
직접 Supervisor를 짤 수도 있지만, 공식 라이브러리를 쓰면 핸드오프·라우팅 로직이 이미 들어 있어 편하다.
```
uv add langgraph-supervisor
```
```
from langgraph_supervisor import create_supervisor

workflow = create_supervisor(
    agents=[analyst, architect, writer],
    model=llm,
    prompt=(
        "너는 에이전트 팀의 조율자다. "
        "사용자 요청을 분석해 적절한 에이전트에게 위임하라. "
        "analyst: 현재 인프라 조사\n"
        "architect: 대안 설계와 절감액 추정\n"
        "writer: 최종 보고서 작성\n"
        "필요하면 여러 에이전트를 순차적으로 호출하라. "
        "작업이 모두 끝나면 FINISH를 반환하라."
    ),
)
app = workflow.compile()
```
내부 동작: Supervisor LLM에 "다음에 누구에게 넘길까?"를 묻는 도구(transfer_to_analyst 같은)가 바인딩되고, 선택된 에이전트가 실행된 뒤 결과가 다시 Supervisor로 돌아온다.

#### 2-3. 제어 흐름 ####
```
사용자
  ▼
Supervisor ──"analyst에게 넘겨"──▶ analyst ──결과──▶ Supervisor
                                                         │
                                  "architect에게 넘겨" ──┤
                                                         ▼
                                                   architect ──결과──▶ Supervisor
                                                                          │
                                                       "writer에게 넘겨" ──┤
                                                                          ▼
                                                                    writer ──결과──▶ Supervisor
                                                                                       │
                                                                                "FINISH" ──▶ END
```
중요한 지점: 하위 에이전트가 다른 에이전트에게 직접 넘기지 못한다. 항상 Supervisor를 거친다. 이게 Swarm 패턴과의 결정적 차이다.

#### 2-4. Supervisor 프롬프트 설계 요령 ####
Supervisor의 성패는 프롬프트가 70%다. 아래 네 가지를 반드시 넣어라.

* 각 에이전트의 역할을 구체적으로. "researcher가 조사한다"가 아니라 "researcher: EC2 인스턴스 목록과 가격을 조회한다"처럼.
* 호출 순서에 대한 힌트. "보통 analyst → architect → writer 순으로 진행된다" 같은 문장.
* 중복 호출 방지 지시. "이미 완료된 작업은 다시 위임하지 않는다."
* 종료 조건 명시. "writer가 보고서를 완성하면 FINISH를 반환한다."

[프롬프트 예시]
```
# 나쁨
너는 조율자다. 에이전트들을 잘 써라.

# 좋음
너는 인프라 분석 팀의 팀장이다.
아래 에이전트를 보유하고 있다:
 - analyst: AWS 리소스 현황과 가격을 조사. describe_instances, get_pricing 도구 사용.
 - architect: Graviton 전환 후보 식별과 절감액 추정.
 - writer: 최종 보고서 작성.

작업 흐름:
 1. 사용자 요청을 읽고 분석이 필요한지 판단
 2. 필요한 정보가 없으면 analyst 호출
 3. 대안 설계가 필요하면 architect 호출
 4. 모든 재료가 모이면 writer 호출
 5. 보고서가 완성되면 FINISH

규칙:
 - 이미 확보한 정보는 다시 조사하지 않는다
 - 네가 직접 답변을 작성하지 마라. writer에게 맡겨라
```

### 3. 실습 ###
패키지를 설치한다.
```
uv add langgraph-supervisor
```
[샘플코드]
```
"""
실습: AWS 인프라 의사결정 에이전트 팀
TODO 표시된 곳을 채워 완성하세요.
"""
from dotenv import load_dotenv
from langchain_aws import ChatBedrockConverse
from langchain_core.tools import tool
from langgraph.prebuilt import create_react_agent
from langgraph_supervisor import create_supervisor

load_dotenv()


# ── 1) 도구 정의 (M2에서 재활용 + 확장) ───────────────────────

PRICING = {
    "c7i.large": 0.1020, "c7i.xlarge": 0.2040,
    "c7g.large": 0.0816, "c7g.xlarge": 0.1632,
    "c8g.large": 0.0870,
}

INSTANCES = [
    {"id": "i-001", "type": "c7i.large",  "region": "us-west-2"},
    {"id": "i-002", "type": "c7i.xlarge", "region": "us-west-2"},
    {"id": "i-003", "type": "c7g.large",  "region": "us-west-2"},
]

GRAVITON_MAP = {
    "c7i.large":  "c7g.large",
    "c7i.xlarge": "c7g.xlarge",
}


@tool
def list_ec2_instances(region: str) -> list[dict]:
    """지정한 리전의 EC2 인스턴스 목록을 반환한다."""
    return [i for i in INSTANCES if i["region"] == region]


@tool
def get_pricing(instance_type: str) -> str:
    """EC2 인스턴스 타입의 시간당 가격(USD)을 조회한다."""
    price = PRICING.get(instance_type)
    return f"{instance_type}: ${price}/hour" if price else f"{instance_type}: N/A"


@tool
def recommend_graviton_alternative(instance_type: str) -> str:
    """x86 인스턴스 타입에 대응하는 Graviton 대안을 반환한다."""
    alt = GRAVITON_MAP.get(instance_type)
    return f"{instance_type} → {alt}" if alt else f"{instance_type}: 대안 없음"


@tool
def estimate_savings(
    current_type: str, alternative_type: str, hours_per_month: int = 730
) -> str:
    """두 인스턴스 타입의 월간 비용 차이를 계산한다."""
    cur = PRICING.get(current_type)
    alt = PRICING.get(alternative_type)
    if cur is None or alt is None:
        return "가격 정보 부족"
    saving = (cur - alt) * hours_per_month
    pct = (cur - alt) / cur * 100
    return f"월간 절감액: ${saving:.2f} ({pct:.1f}%)"


# ── 2) 모델 ───────────────────────────────────────────────────

llm = ChatBedrockConverse(
    model="anthropic.claude-3-5-sonnet-20241022-v2:0",
    region_name="ap-northeast-2",
    temperature=0,
    max_tokens=2048,
)


# ── 3) 하위 에이전트 정의 ─────────────────────────────────────

# TODO 1: analyst 에이전트를 만드세요.
# - name="analyst"
# - tools=[list_ec2_instances, get_pricing]
# - prompt는 "현재 인프라 조사" 역할에 맞게
analyst = ...

# TODO 2: architect 에이전트를 만드세요.
# - name="architect"
# - tools=[recommend_graviton_alternative, estimate_savings]
architect = ...

# TODO 3: writer 에이전트를 만드세요. (도구 없음)
# - name="writer"
# - 최종 보고서를 마크다운으로 작성하도록 프롬프트 설계
writer = ...


# ── 4) Supervisor 정의 ────────────────────────────────────────

SUPERVISOR_PROMPT = """\
너는 AWS 인프라 분석 팀의 팀장이다.

보유 에이전트:
 - analyst: AWS 리소스 현황과 가격을 조사한다
 - architect: Graviton 전환 후보 식별과 절감액 추정을 한다
 - writer: 최종 보고서를 마크다운으로 작성한다

작업 흐름:
 1. 사용자 요청을 읽고 무엇이 필요한지 판단
 2. 현황 정보가 없으면 analyst 호출
 3. 대안 설계가 필요하면 architect 호출
 4. 모든 재료가 모이면 writer 호출
 5. 보고서가 완성되면 작업 종료

규칙:
 - 이미 확보한 정보는 다시 조사하지 않는다
 - 네가 직접 본문을 작성하지 마라. writer에게 맡겨라
"""


def build_team():
    # TODO 4: create_supervisor(...)로 workflow를 만들고 compile()해서 반환
    ...


# ── 5) 실행 ───────────────────────────────────────────────────

if __name__ == "__main__":
    team = build_team()

    result = team.invoke({
        "messages": [
            ("user",
             "us-west-2 인프라를 점검하고 Graviton 전환 계획을 보고서로 만들어줘.")
        ]
    })

    # 최종 메시지 출력
    print(result["messages"][-1].content)

    # 각 에이전트가 어떻게 호출됐는지 추적
    print("\n" + "=" * 60)
    print("에이전트 호출 순서:")
    for m in result["messages"]:
        name = getattr(m, "name", None)
        if name:
            print(f"  - {name}: {m.content[:80]}...")
```
[정답]
```
analyst = create_react_agent(
    model=llm,
    tools=[list_ec2_instances, get_pricing],
    name="analyst",
    prompt=(
        "너는 AWS 인프라 현황 조사 담당이다. "
        "list_ec2_instances와 get_pricing을 사용해 "
        "현재 실행 중인 인스턴스와 각각의 시간당 가격을 수집하라. "
        "추측하지 말고 반드시 도구 결과만 보고하라."
    ),
)

architect = create_react_agent(
    model=llm,
    tools=[recommend_graviton_alternative, estimate_savings],
    name="architect",
    prompt=(
        "너는 Graviton 전환 설계 담당이다. "
        "주어진 인스턴스 목록에서 Graviton 대안이 있는 항목을 찾고, "
        "각 전환에 따른 월간 절감액을 계산하라."
    ),
)

writer = create_react_agent(
    model=llm,
    tools=[],
    name="writer",
    prompt=(
        "너는 기술 보고서 작성자다. "
        "앞선 에이전트들이 수집한 정보를 바탕으로 "
        "마크다운 형식의 보고서를 작성하라. "
        "구성: 현황 요약, 전환 제안, 예상 절감액, 권고사항."
    ),
)


def build_team():
    workflow = create_supervisor(
        agents=[analyst, architect, writer],
        model=llm,
        prompt=SUPERVISOR_PROMPT,
    )
    return workflow.compile()
```

### 4. 정리 ###

* Supervisor는 라우터다. 일 자체가 아니라 "누가 일할지"를 결정한다.
* 하위 에이전트는 작고 전문적이어야 한다. 프롬프트와 도구 목록을 작게 유지.
* 제어 흐름은 항상 Supervisor로 복귀한다. 이게 Swarm과의 결정적 차이.

#### 언제 Supervisor 패턴을 쓰나 ####
* 작업이 단계적으로 흘러갈 때 (조사 → 설계 → 작성)
* 각 역할이 명확히 분리될 때
* 감사 로그가 필요할 때 (누가 무엇을 했는지 Supervisor가 다 기록)
* 통제권이 중요한 조직적 워크플로
* Swarm은 반대로 역할 간 경계가 흐릿하고, 에이전트끼리 직접 넘기는 상황에 맞다.

