#!/bin/bash
less $1 | sed -e '/^#/d' -e '/^$/d' > tmp.txt
. tmp.txt
rm tmp.txt

BASE_DIR="../inventories/"$STAGE

echo "----set the following value-----"
echo "stage: "$STAGE
echo "host type: "$HOSTS_TYPE
echo "ceph type: "$CEPH_TYPE
echo "ssh config path: "$SSH_CONFIG_PATH
echo "ssh public key: "$SSH_PUBLICKEY_PATH
echo "remoye host password: "$REMOTE_HOST_PASS
if [ $STAGE == 'prod' ];then
  echo "kube-apiserver vip: "$KUBE_API_VIP
fi
echo "-------------------------------"

set_inventriesdir() {

  if [ $STAGE == 'prod' ];then
    case $HOSTS_TYPE in
      "inside" ) echo $BASE_DIR"/inside_hosts.yaml" ;;
      "outside" ) echo $BASE_DIR"/outside_hosts.yaml" ;;
    esac

  elif [ $STAGE == 'dev' ];then
    case $HOSTS_TYPE in
      "mini" ) echo $BASE_DIR"/minimum_hosts.yaml" ;;
      "big" ) echo $BASE_DIR"/hosts.yaml" ;;
    esac

  fi

}

prepare_file() {

  # create ansible.cfg
  echo -n "[defaults]
ask_vault_pass = True
host_key_checking = False

[ssh_connection]
ssh_args = -F "$SSH_CONFIG_PATH > ansible.cfg

  # create roles/ssh-copy-id/tasks/ssh.yaml
  echo -n "- name: register public key.
  become: yes
  authorized_key:
    user: \"{{ item }}\"
    state: present
    key: \"{{ lookup('file', '"$SSH_PUBLICKEY_PATH"') }}\"
  with_items:
    - \"{{ ansible_ssh_user }}\"" > ../roles/ssh-copy-id/tasks/ssh.yaml

  # create $BASE_DIR/roup_vars/all/vault.yaml
  echo -n "ansible_sudo_pass: "$REMOTE_HOST_PASS > $BASE_DIR/group_vars/all/vault.yaml

  # encrypt $BASE_DIR/group_vars/all/vault.yaml
  ansible-vault encrypt $BASE_DIR/group_vars/all/vault.yaml

  # if $STAGE is 'dev', create $BASE_DIR/group_vars/all/keepalived_conf.yaml
  if [ $STAGE == 'dev' ];then
    echo -n "keepalived_configuration:
  ROUTER_ID: \"51\"
  AUTH_PASS: \"123\"
  APISERVER_VIP: \""$KUBE_API_VIP"\"" > $BASE_DIR/group_vars/all/keepalived_conf.yaml
  fi

}


run_playbook() {

  INV_DIR=`set_inventriesdir`
  # run prepare.yaml
  ansible-playbook -i $INV_DIR ../prepare.yaml -k

  echo "!!------------!!"
  echo "  "$CEPH_TYPE" mode"
  echo "!!------------!!"
  # run create-cluster.yaml
  ansible-playbook -i $INV_DIR ../create-cluster.yaml -e ceph_type=$CEPH_TYPE

}

prepare_file
run_playbook