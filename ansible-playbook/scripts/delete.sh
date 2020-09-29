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

run_playbook() {

  INV_DIR=`set_inventriesdir`

  echo "!!------------!!"
  echo "  "$CEPH_TYPE" mode"
  echo "!!------------!!"
  # run create-cluster.yaml
  ansible-playbook -i $INV_DIR ../delete-cluster.yaml -e ceph_type=$CEPH_TYPE

}

run_playbook