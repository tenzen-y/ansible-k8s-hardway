sudo mv kubeconfig/kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig

NODE_NETWORK=`ip addr show eth0 | grep 'state UP' -A2 | tail -n1 | awk '{print $2}'`

cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: "/var/lib/kube-proxy/kubeconfig"
mode: "iptables"
clusterCIDR: "${NODE_NETWORK}"
EOF


cat <<EOF | sudo tee /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kube-proxy
sudo systemctl start kube-proxy
sudo systemctl status kube-proxy

NODE_NUM=`uname -n | cut -b 7`

for i in `seq 1 3`;do
  if [ "$i" != "${NODE_NUM}" ];then
    sudo ip route add 10.${i}.0.0/24 via 192.168.1.13${i} dev eth0
  fi
done

