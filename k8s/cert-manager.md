---
description: Easy manage your https certificate
---

# Cert Manager

Cert-manager adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.

Install cert manager

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml
```

#### Use Cert Manager

Membuat cluster-issuer

```bash
nano cluster-issuer.yaml
```

```yaml
apiVersion: cert-manager.io/v1                             
kind: ClusterIssuer                             
metadata:                               
  name: cluster-issuer                          
spec:                            
  acme:                                 
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@email.com
    privateKeySecretRef:                                                                   
      name: letsencrypt-cluster-issuer-key
    solvers:
    - http01:
        ingress:
          class: nginx
```

```bash
# apply cluster-issuer
kubectl apply -f cluster-issuer.yaml
```

#### Membuat Simple nginx deployment https

Setelah membuat cluster-issuer, kita membuat simple deployment nginx.

```yaml
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nginx
  replicas: 3 # tells deployment to run 1 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: default
  labels:
    app: nginx
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP

---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: cluster-issuer
  name: nginx-try
spec:
  ingressClassName: nginx
  rules:
  - host: test.ngurahbagus.tech
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: nginx
            port:
              number: 80
  tls: # < placing a host in the TLS config will determine what ends up in the cert's subjectAltNames
  - hosts:
    - test.ngurahbagus.tech
    secretName: nginx-cer
```

Refrensi :&#x20;

* [https://cert-manager.io/docs/installation/kubectl/](https://cert-manager.io/docs/installation/kubectl/)
* [https://towardsdatascience.com/ssl-tls-for-your-kubernetes-cluster-with-cert-manager-3db24338f17](https://towardsdatascience.com/ssl-tls-for-your-kubernetes-cluster-with-cert-manager-3db24338f17)

