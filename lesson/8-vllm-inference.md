## vLLM 배포하기 ##

Qwen2.5-27B 모델을 g6e.12xlarge (L40S 48GB * 4EA, TP=4) 설정으로 2개의 파드로 구성한다.
g6e.12xlarge 인스턴스는 2대가 필요하다.



```bash
kubectl -f https://raw.githubusercontent.com/gnosia93/eks-agentic-ai/refs/heads/main/code/yaml/vllm-deployment.yaml
```
* vLLM 파라미터 
  * --model                     어떤 모델 쓸지
  * --tensor-parallel-size      GPU 몇 장에 나눌지
  * --max-model-len             최대 시퀀스 길이
  * --gpu-memory-utilization    GPU 메모리 몇 % 쓸지


