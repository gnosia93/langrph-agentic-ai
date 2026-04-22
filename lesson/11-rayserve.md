```
apiVersion: ray.io/v1
kind: RayService
metadata:
  name: vllm-llama-405b
  namespace: llm-serving
spec:
  serveConfigV2: |
    applications:
      - name: llm
        import_path: vllm_serve:app
        deployments:
          - name: VLLMDeployment
            num_replicas: 1
            ray_actor_options:
              num_gpus: 16
  rayClusterConfig:
    rayVersion: "2.35.0"
    headGroupSpec:
      rayStartParams:
        dashboard-host: "0.0.0.0"
      template:
        spec:
          containers:
            - name: ray-head
              image: vllm/vllm-openai:latest
              resources:
                limits:
                  nvidia.com/gpu: 8
    workerGroupSpecs:
      - replicas: 1
        minReplicas: 1
        maxReplicas: 1
        groupName: gpu-workers
        rayStartParams: {}
        template:
          spec:
            containers:
              - name: ray-worker
                image: vllm/vllm-openai:latest
                resources:
                  limits:
                    nvidia.com/gpu: 8

```
