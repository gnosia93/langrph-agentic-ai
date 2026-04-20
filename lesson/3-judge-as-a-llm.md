## LLM-as-a-Judge ##
```
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="dummy")

def llm_judge(question, answer, criteria="정확성, 완전성, 실용성"):
    response = client.chat.completions.create(
        model="Qwen/Qwen3.5-27B",
        messages=[
            {"role": "system", "content": "당신은 AI 응답 품질 평가 전문가입니다."},
            {"role": "user", "content": f"""
다음 답변을 평가하세요.

[질문] {question}
[답변] {answer}
[평가 기준] {criteria}

각 기준별 1~5점과 이유를 JSON으로 출력:
{{"정확성": {{"score": N, "reason": "..."}}, "완전성": {{"score": N, "reason": "..."}}, "실용성": {{"score": N, "reason": "..."}}}}
"""}
        ],
        temperature=0
    )
    return response.choices[0].message.content

# 사용
result = llm_judge(
    question="EFA와 일반 네트워크의 차이점은?",
    answer="EFA는 OS bypass로 저지연 통신을 제공합니다."
)
print(result)
```
* 평가 LLM은 평가 대상 모델보다 같거나 더 강한 모델을 써야 한다. (보통 GPT-4, Claude 등)
* 자기 자신을 평가하면 자기 편향(self-bias)이 생김
* Pairwise에서 답변 순서를 바꿔서 2번 평가하면 위치 편향(position bias)을 줄일 수 있음
  
프로덕션에서는 사용자 요청과 LLM 응답을 로깅하고, 로그중 일부를 샘플링하여 비동기로 백그라운드에서 LLM Judge를 돌리고, 결과를 Prometheus 메트릭으로 수집하는 방식으로 운영.
* 도구: MT-Bench, AlpacaEval, G-Eval, 직접 구현
* 방식: Single Rating, Pairwise Comparison, Reference-based

