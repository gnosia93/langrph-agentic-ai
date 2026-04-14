
![](https://github.com/gnosia93/eks-agentic-ai/blob/main/lesson/images/security-toolcall-ssrf.png)

아키텍처 주요 구성 요소 설명

* AI Agent (Sandbox Container/VM): 에이전트가 실행되는 환경은 호스트 시스템과 분리된 격리된 샌드박스 내에 위치. 이를 통해 코드 실행이나 도구 호출이 시스템 전체에 영향을 미치는 것을 방지.
* Egress Filter/Firewall (네트워크 경계): 에이전트에서 나가는 모든 트래픽을 검사하는 관문
  * ❌ 차단 대상: 루프백 주소(127.0.0.1), 사설망(Internal Services), 클라우드 메타데이터 엔드포인트(169.254.169.254) 등 민감한 내부 자원에 대한 접근을 물리적으로 차단
  * ✅ 허용 대상 (Allowlist): 사전에 승인된 외부 API(예: OpenAI, Serper, 특정 기업 API)로의 통신만 화이트리스트 기반으로 허용
* Proxy Server (선택 사항): 모든 외부 요청을 중앙 프록시를 거치게 하여, 요청 내용을 로깅하고 비정상적인 패턴을 탐지하는 추가적인 보안 계층을 구성할 수 있음.
* 이러한 Egress 관리는 에이전트가 공격자의 유도로 인해 내부 서버를 공격하거나 기밀 정보를 외부로 반출하는 것을 막는 가장 강력한 방어선
