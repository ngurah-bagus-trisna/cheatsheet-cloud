# Deploy code-server kubernetes

1. Create secret for auth code-server

```bash
kubectl create secret generic secret-code-server --from-literal=PASSWORD='<password>'
```

2. Create deployment 

```yaml
# pvc

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-code-server
spec:
  storageClassName: local-path
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---

# service

apiVersion: v1
kind: Service
metadata:
  name: code-server
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8443
  selector:
    app: code-server
  type: ClusterIP
---

# Deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  name: code-server
spec:
  selector:
    matchLabels:
      app: code-server
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: code-server
    spec:
      containers:
      - image: linuxserver/code-server:latest
        name: code-server
        envFrom:
        - secretRef:
            name: secret-code-server
        ports:
        - containerPort: 8443
          name: code-server
        volumeMounts:
        - name: pv-code-server
          mountPath: /config
      volumes:
      - name: pv-code-server
        persistentVolumeClaim:
          claimName: pvc-code-server
          
---

# Ingress

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: code-server-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: code-server 
                port:
                  number: 80
```

3. Deploy

```bash
k apply -f code-server.yaml
```
