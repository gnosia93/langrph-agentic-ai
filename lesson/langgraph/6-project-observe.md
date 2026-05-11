## 랭스미스 연동 ##

### 1. API Key 발급 ###

1. smith.langchain.com 사이트에 가서 계정을 생성한다. 

2. API Key 발급 받는다 (Settings page → API Keys → Create API Key).

 
### 2. 의존성 설치 ###
```
uv add langchain langchain-openai
```

### 3. 환경변수 설정 ###

랭스미스 API KEY 및 LLM API KEY 를 환경변수로 설정한다.
```
export LANGSMITH_TRACING=true
export LANGSMITH_ENDPOINT=https://aws.api.smith.langchain.com
export LANGSMITH_API_KEY=<your-api-key>
export LANGSMITH_PROJECT="agent-trace-001"
export OPENAI_API_KEY=<your-openai-api-key>
```

### 4. 에어전트 실행  ###
```
from langchain.agents import create_agent

def get_weather(city: str) -> str:
    """Get weather for a given city."""
    return f"It's always sunny in {city}!"

agent = create_agent(
    model="openai:gpt-5-mini",
    tools=[get_weather],
    system_prompt="You are a helpful assistant",
)

# Run the agent
agent.invoke(
    {"messages": [{"role": "user", "content": "What is the weather in San Francisco?"}]}
)
```

## 레퍼런스 ##

* https://docs.langchain.com/langsmith/home
