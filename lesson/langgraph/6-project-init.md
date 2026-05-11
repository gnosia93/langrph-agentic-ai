## 프로젝트 생성하기 ##
본 워크샵에서는 uv 를 활용하여 파이썬 프로젝트를 관리한다. uv는 Astral에서 만든 Python 패키지 및 프로젝트 매니저로 Rust로 작성되어 있고, 기존 도구들(pip, pip-tools, virtualenv, pyenv, poetry 등)을 하나로 대체하는 걸 목표로 하고 있다. pip보다 10~100배 빠르고 uvx 명령어로 패키지를 격리된 환경에서 일회성으로 실행할 수 있다. 
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

[결과]
```
Hello from my-langchain-app!
```
