## 프로젝트 생성하기 ##

본 워크샵에서는 uv 를 활용하여 파이썬 프로젝트를 관리한다. uv 는 파이썬 패키지 관리자이다. 
```
curl -LsSf https://astral.sh/uv/install.sh | sh
```

프로젝트를 생성하고 필요한 파이썬 패키지를 설치한다.
```
mkdir my-langchain-app
cd my-langchain-app
uv init
```
[결과]
```
Initialized project `my-langchain-app`
```
uv init 로 생성된 프로젝트 파일을 확인한다. 
```
ls -la
```

[결과]
```
drwxr-xr-x@   8 soonbeom  staff   256  5 11 19:50 .
drwxr-x---+ 237 soonbeom  staff  7584  5 11 19:50 ..
drwxr-xr-x@   9 soonbeom  staff   288  5 11 19:50 .git
-rw-r--r--@   1 soonbeom  staff   109  5 11 19:50 .gitignore
-rw-r--r--@   1 soonbeom  staff     5  5 11 19:50 .python-version
-rw-r--r--@   1 soonbeom  staff    94  5 11 19:50 main.py
-rw-r--r--@   1 soonbeom  staff   162  5 11 19:50 pyproject.toml
-rw-r--r--@   1 soonbeom  staff     0  5 11 19:50 README.md
```
에이전트 개발에 필요한 패키지를 설치한다. 
```
uv add langchain langchain-openai langchain-anthropic langchain-community langgraph python-dotenv
uv run python main.py
```
