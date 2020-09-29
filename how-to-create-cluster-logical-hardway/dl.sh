wget https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/arm64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin

wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/etcd/v3.4.13/etcd-v3.4.13-linux-arm64.tar.gz"
tar -xvf etcd-v3.4.13-linux-arm64.tar.gz
sudo mv etcd-v3.4.13-linux-arm64/etcd* /usr/local/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo chmod 700 /var/lib/etcd

wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/arm64/kube-apiserver"
chmod +x kube-apiserver
sudo mv kube-apiserver /usr/local/bin/

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > how-to-create-cluster-logical-hardway/encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF

sudo mkdir -p /etc/kubernetes/config
sudo mkdir -p /var/lib/kubernetes/

wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/arm64/kube-controller-manager"
chmod +x kube-controller-manager
sudo mv kube-controller-manager /usr/local/bin/

wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/arm64/kube-scheduler"
chmod +x kube-scheduler
sudo mv kube-scheduler /usr/local/bin/

sudo apt update
sudo apt -y install socat conntrack ipset

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kubernetes \
  /etc/containerd
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.18.0/crictl-v1.18.0-linux-arm64.tar.gz \
  https://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-arm64-v0.8.6.tgz \
  https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/arm64/kubelet
tar -xvf crictl-v1.18.0-linux-arm64.tar.gz
sudo tar -xvf cni-plugins-linux-arm64-v0.8.6.tgz -C /opt/cni/bin/
chmod +x crictl kubelet
sudo mv crictl kubelet /usr/local/bin/
sudo apt -y install containerd runc

wget -q --show-progress --https-only --timestamping \
   https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/arm64/kube-proxy
chmod +x kube-proxy
sudo mv kube-proxy /usr/local/bin/
sudo mkdir -p /var/lib/kube-proxy

