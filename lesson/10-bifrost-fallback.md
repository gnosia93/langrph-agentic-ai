## Bifrost로 LLM 게이트웨이 구축하기 ##
### Bifrost 란 ###
Bifrost는 Maxim AI가 Go로 만든 고성능 오픈소스 AI 게이트웨이다. OpenAI·Anthropic·AWS Bedrock·Google Vertex·Azure 등 20개 이상의 LLM 프로바이더를 단일 OpenAI 호환 API로 묶어 준다. 애플리케이션 코드에서는 base_url만 Bifrost로 바꾸면, 뒤쪽 프로바이더는 마음껏 교체·조합할 수 있다.

공식 벤치마크 기준 5,000 RPS 부하에서 요청당 약 11µs의 오버헤드만 추가한다고 밝히고 있어, LiteLLM 같은 Python 기반 게이트웨이의 대안으로 자리 잡고 있다. (Content was rephrased for compliance with licensing restrictions — 출처: Bifrost GitHub)

### 핵심 기능 ###
* Unified API: 모든 프로바이더를 OpenAI 호환 스키마로 호출
* Automatic Fallback / Load Balancing: 프로바이더·API 키 단위의 장애 조치와 부하 분산
* Semantic Caching: 의미 기반 응답 캐싱으로 비용·지연 절감
* MCP Gateway: Model Context Protocol 클라이언트/서버 양쪽으로 동작, 외부 도구를 모델에 연결
* Governance: 가상 키, 팀/고객별 예산, 속도 제한, 접근 제어
* Observability: Prometheus 메트릭, 분산 추적, 요청 로그
* Drop-in Replacement: OpenAI/Anthropic/GenAI SDK의 엔드포인트만 교체하면 끝

### 언제 쓰나 ###
* 여러 프로바이더를 쓰는데 SDK가 제각각이라 코드가 지저분해질 때
* 한 모델이 장애 났을 때 다른 모델로 자동 전환하고 싶을 때
* 팀·고객별로 API 키 사용량과 비용을 통제해야 할 때
* Claude Code 같은 도구를 Anthropic 외의 모델(OpenAI, Gemini 등)로 돌리고 싶을 때
* MCP 기반 에이전트를 하나의 엔드포인트로 집약하고 싶을 때

## 레퍼런스 ##
* https://github.com/maximhq/bifrost
