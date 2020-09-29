cat <<EOF | kubectl apply --kubeconfig kubeconfig/admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

cat <<EOF | kubectl apply --kubeconfig kubeconfig/admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF

kubectl get node --kubeconfig kubeconfig/admin.kubeconfig
kubectl apply -f coredns-1.7.0.yaml --kubeconfig kubeconfig/admin.kubeconfig
kubectl run test1 --image busybox:1.28 --restart Never -it --rm -- nslookup kubernetes --kubeconfig kubeconfig/admin.kubeconfig
kubectl run test2 --image busybox:1.28 --restart Never -it --rm -- nslookup google.com --kubeconfig kubeconfig/admin.kubeconfig

kubectl create secret generic kubernetes-the-hard-way \
  --from-literal="mykey=mydata" --kubeconfig kubeconfig/admin.kubeconfig


sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem \
  /registry/secrets/default/kubernetes-the-hard-way | hexdump -C

kubectl create deployment nginx --image=nginx --kubeconfig kubeconfig/admin.kubeconfig
kubectl get pods -l app=nginx --kubeconfig kubeconfig/admin.kubeconfig

kubectl expose deployment nginx --port 80 --type NodePort --kubeconfig kubeconfig/admin.kubeconfig
kubectl get svc --kubeconfig kubeconfig/admin.kubeconfig


