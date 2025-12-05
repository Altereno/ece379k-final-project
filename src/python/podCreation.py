import time
import numpy as np
from kubernetes import client, config
from kubernetes.client.rest import ApiException

NAMESPACE = "default"
TOTAL_REQUESTS = 1000

config.load_kube_config()

v1 = client.CoreV1Api()

bad_pod_manifest = client.V1Pod(
    metadata=client.V1ObjectMeta(
        generate_name="bench-bad-",
        labels={"benchmark": "true", "type": "bad"}
    ),
    spec=client.V1PodSpec(
        containers=[client.V1Container(
            name="nginx",
            image="nginx:alpine",
            security_context=client.V1SecurityContext(
                privileged=True
            )
        )],
        restart_policy="Never"
    )
)

good_pod_manifest = client.V1Pod(
    metadata=client.V1ObjectMeta(
        generate_name="bench-good-",
        labels={"benchmark": "true", "type": "good"}
    ),
    spec=client.V1PodSpec(
        containers=[client.V1Container(
            name="nginx",
            image="nginx:alpine",
            security_context=client.V1SecurityContext(
                allow_privilege_escalation=False,
                run_as_non_root=True,
                run_as_user=1000,
                capabilities=client.V1Capabilities(drop=["ALL"]),
                seccomp_profile=client.V1SeccompProfile(type="RuntimeDefault")
            )
        )],
        restart_policy="Never"
    )
)

latencies = []
results = {
    "allowed_good": 0, "allowed_bad": 0,
    "denied_good": 0, "denied_bad": 0,
    "errors": 0
}

print(f"Starting Benchmark: {TOTAL_REQUESTS} requests.")
print(f"Target: 50% Compliant, 50% Non-Compliant")

start_time_total = time.time()

for i in range(TOTAL_REQUESTS):
    is_good_turn = (i % 2 == 0)
    target_pod = good_pod_manifest if is_good_turn else bad_pod_manifest
    
    req_start = time.time()
    try:
        v1.create_namespaced_pod(namespace=NAMESPACE, body=target_pod)
        if is_good_turn:
            results["allowed_good"] += 1 
        else:
            results["allowed_bad"] += 1  # False Negative
            
    except ApiException as e:
        if e.status == 403:
            if is_good_turn:
                results["denied_good"] += 1 # False Positive
            else:
                results["denied_bad"] += 1  # True Negative
        else:
            print(f"Unexpected error: {e.status} {e.reason}")
            results["errors"] += 1

    req_end = time.time()
    
    latencies.append((req_end - req_start) * 1000)

end_time_total = time.time()

p99 = np.percentile(latencies, 99)
avg = np.mean(latencies)

print("\n" + "="*40)
print("Results:")
print("="*40)
print(f"Total Duration:     {end_time_total - start_time_total:.2f} seconds")
print(f"Throughput:         {TOTAL_REQUESTS / (end_time_total - start_time_total):.2f} req/sec")
print("-" * 40)
print(f"Latency (Avg):      {avg:.2f} ms")
print(f"Latency (P99):      {p99:.2f} ms")
print("-" * 40)
print("Policy Results:")
print(f"Good Pods Allowed:  {results['allowed_good']}")
print(f"Bad Pods Denied:    {results['denied_bad']}")
print(f"Good Pods Denied:   {results['denied_good']}")
print(f"Bad Pods Allowed:   {results['allowed_bad']}")
print(f"Errors:             {results['errors']}")
print("="*40)

print("\nCleaning up benchmark pods.")
try:
    v1.delete_collection_namespaced_pod(
        namespace=NAMESPACE,
        label_selector="benchmark=true",
        grace_period_seconds=0
    )
    print("Cleanup initiated.")
except ApiException as e:
    print(f"Cleanup failed: {e}")