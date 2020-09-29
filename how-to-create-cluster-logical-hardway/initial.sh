NODE1=192.168.1.131
NODE2=192.168.1.132
NODE3=192.168.1.133

sudo apt update -y
sudo apt upgrade -y
sudo apt install haproxy nginx keepalived golang-cfssl

echo "
k8s-ra1 ${NODE1}
k8s-ra2 ${NODE2}
k8s-ra3 ${NODE3}" | sudo tee -a /etc/hosts

mkdir -p -m 700 ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

for i in `seq 1 3`;do
  ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no k8s-ra${i}
done

