## PDF 문서 저장하기 (레이아웃 파싱/청킹/임베딩) ##

이 단계에서는 PDF 문서를 읽어 들여 의미 단위로 잘게 나누고(청킹), 각 조각을 벡터로 변환해(임베딩) Milvus에 저장한다. 이렇게 저장된 벡터는 이후 RAG 파이프라인에서 질의와 가장 유사한 문서 조각을 찾는 데 사용된다.

전체 과정은 다음과 같다.
```
PDF 파일 → 레이아웃 파싱 → 청킹 → 임베딩(벡터화) → Milvus 저장
```
아래 PDFVectorStore 클래스는 이 네 단계를 하나로 묶어 둔 래퍼이다. 다른 PDF 문서도 같은 방식으로 추가할 수 있도록 재사용 가능한 형태로 작성돼 있다.

### 1. 프로젝트 구조 ### 
```
rag/
├── PDFVectorStore.py       ← curl로 받은 파일
└── main.py                 ← 여기서 from PDFVectorStore import ...
```

### 2. 환경 준비 ###
작업 디렉토리를 만들고 필요한 패키지를 설치한다.

```
mkdir rag && cd rag
pip install pymilvus langchain langchain-community pymupdf sentence-transformers
```
각 패키지의 역할: 
* pymilvus : Milvus 벡터 DB 파이썬 클라이언트
* langchain, langchain-community : 문서 로더와 텍스트 스플리터 제공
* pymupdf : PDF 레이아웃 파싱(텍스트/페이지 정보 추출)
* sentence-transformers : 로컬에서 실행되는 오픈소스 임베딩 모델 (무료)



### 실행하기 ###
```
mkdir rag && cd rag
pip install pymilvus langchain langchain-community pymupdf sentence-transformers

curl -o PDFVectorStore.py
https://raw.githubusercontent.com/gnosia93/eks-agentic-ai/refs/heads/main/code/rag/PDFVectorStore.py
```

[main.py]
```
from PDFVectorStore import PDFVectorStore

store = PDFVectorStore(
    host="<리모트_IP_또는_호스트>",
    port="19530",
    collection_name="papers",
    reset=True,  # 처음 한 번만
)

store.add_pdf("LoRA_Low-Rank_Adaptation.pdf")
# 이후 다른 PDF도 계속
# store.add_pdf("another.pdf")
```
