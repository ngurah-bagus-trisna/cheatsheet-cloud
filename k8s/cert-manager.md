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

Refrensi :&#x20;

* [https://cert-manager.io/docs/installation/kubectl/](https://cert-manager.io/docs/installation/kubectl/)
* [https://towardsdatascience.com/ssl-tls-for-your-kubernetes-cluster-with-cert-manager-3db24338f17](https://towardsdatascience.com/ssl-tls-for-your-kubernetes-cluster-with-cert-manager-3db24338f17)

