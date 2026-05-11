
uv 를 설치한다.
```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

프로젝트를 생성하고 필요한 파이썬 패키지를 설치한다.
```
mkdir my-langchain-app
cd my-langchain-app
uv init
uv add langchain langchain-openai langchain-anthropic langchain-community langgraph python-dotenv
```
