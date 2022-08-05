# Nginx Ingress Kubernetes

In Kubernetes, an Ingress is an object that allows access to your Kubernetes services from outside the Kubernetes cluster. You configure access by creating a collection of rules that define which inbound connections reach which services. This lets you consolidate your routing rules into a single resource.

### Install Kubernetes

_Refrensi_ : https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters

Deploy kubernetes

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/baremetal/deploy.yaml
```

Edit service kubernetes from NodePort to LoadBalancer

```bash
k edit -n ingress-nginx svc ingress-nginx-controller
```
```yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"app.kubernetes.io/component":"controller","app.kubernetes.io/instance":"ingress-nginx","app.kubernetes.io/name":"ingress-nginx","app.kubernetes.io/part-of":"ingress-nginx","app.kubernetes.io/version":"1.3.0"},"name":"ingress-nginx-controller","namespace":"ingress-nginx"},"spec":{"ports":[{"appProtocol":"http","name":"http","port":80,"protocol":"TCP","targetPort":"http"},{"appProtocol":"https","name":"https","port":443,"protocol":"TCP","targetPort":"https"}],"selector":{"app.kubernetes.io/component":"controller","app.kubernetes.io/instance":"ingress-nginx","app.kubernetes.io/name":"ingress-nginx"},"type":"NodePort"}}
  creationTimestamp: "2022-08-05T09:12:33Z"
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.3.0
  name: ingress-nginx-controller
  namespace: ingress-nginx
  resourceVersion: "5493"
  uid: ad9f534e-006b-4a1c-bd81-325574e9468a
spec:
  clusterIP: 10.111.210.6
  clusterIPs:
  - 10.111.210.6
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - appProtocol: http
    name: http
    nodePort: 31787
    port: 80
    protocol: TCP
    targetPort: http
  - appProtocol: https
    name: https
    nodePort: 32078
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
  sessionAffinity: None
  type: LoadBalancer # Default NodePort, change to LoadBalancer
status:
  loadBalancer: {}

```

Check nginx get external ip from metallb

```bash
k get svc -A
---

NAMESPACE        NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
default          kubernetes                           ClusterIP      10.96.0.1        <none>         443/TCP                      56m
ingress-nginx    ingress-nginx-controller             LoadBalancer   10.111.210.6     172.18.10.80   80:31787/TCP,443:32078/TCP   2m23s
ingress-nginx    ingress-nginx-controller-admission   ClusterIP      10.96.79.36      <none>         443/TCP                      2m23s
kube-system      kube-dns                             ClusterIP      10.96.0.10       <none>         53/UDP,53/TCP,9153/TCP       56m
metallb-system   webhook-service                      ClusterIP      10.102.247.183   <none>         443/TCP                      8m22s
```

### Example Ingress Nginx

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  ingressClassName: nginx
  rules:
    - host: example.tech
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx 
                port:
                  number: 80
```


