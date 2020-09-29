cat <<EOF | sudo tee /etc/keepalived/keepalived.conf
global_defs {
    router_id LVS_DEVEL
}
vrrp_script check_apiserver {
  interval 3
  weight -2
  fall 10
  rise 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    authentication {
        auth_type PASS
        auth_pass 123
    }
    virtual_ipaddress {
        192.168.1.130
    }
}
EOF

sudo systemctl daemon-reload
sudo systemctl enable keepalived
sudo systemctl restart keepalived
sudo systemctl status keepalived
