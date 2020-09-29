NODE1="192.168.1.131"
NODE2="192.168.1.132"
NODE3="192.168.1.133"

cat <<EOF | sudo tee -a /etc/nginx/nginx.conf

stream {

    log_format stream '\$remote_addr - - [\$time_local] \$protocol '
                        '\$status \$bytes_sent \$bytes_received \$session_time "\$upstream_addr"';

    access_log  /var/log/nginx/stream-access.log  stream;
    error_log /var/log/nginx/stream-error.log;
    include /etc/nginx/stream/kube-apiserver.conf;
}
EOF

sudo mkdir -p /etc/nginx/stream
cat <<EOF | sudo tee /etc/nginx/stream/kube-apiserver.conf
upstream stream_backend {
    least_conn;
    server ${NODE1}:6444;
    server ${NODE2}:6444;
    server ${NODE3}:6444;
}

server {
    listen        6443;
    proxy_pass    stream_backend;
}
EOF

sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl restart nginx

