# Диагностика и отладка кластера и приложений в нем.

**Работы производим minikube**

## Подготовка окружения к ДЗ
1) Создать 4VM

## Выполнение домашнего задания
### Набор команд для настройки мастер ноды
```bash
#!/bin/bash
apt update
apt install mc containerd -y
systemctl enable containerd
systemctl start containerd
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install kubeadm kubelet kubectl -y
apt-mark hold kubeadm kubelet kubectl
kubeadm version
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "overlay" >> /etc/modules-load.d/containerd.conf
echo "br_netfilter" >> /etc/modules-load.d/containerd.conf
modprobe overlay
modprobe br_netfilter
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/kubernetes.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/kubernetes.conf
sysctl --system
echo 'KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"' >> /etc/default/kubelet
systemctl daemon-reload && systemctl restart kubelet
kubeadm init --control-plane-endpoint=master-node --upload-certs >> logs.txt
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
systemctl stop apparmor && systemctl disable apparmor
systemctl restart containerd.service
```

### Набор команд для настройки рабочих нод
```bash
#!/bin/bash
apt update
apt install mc containerd -y
systemctl enable containerd
systemctl start containerd
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update
apt install kubeadm kubelet kubectl -y
apt-mark hold kubeadm kubelet kubectl
kubeadm version
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo "overlay" >> /etc/modules-load.d/containerd.conf
echo "br_netfilter" >> /etc/modules-load.d/containerd.conf
modprobe overlay
modprobe br_netfilter
echo "net.bridge.bridge-nf-call-ip6tables = 1" >> /etc/sysctl.d/kubernetes.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/kubernetes.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/kubernetes.conf
sysctl --system
echo 'KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"' >> /etc/default/kubelet
systemctl daemon-reload && systemctl restart kubelet
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
systemctl stop apparmor && systemctl disable apparmor
systemctl restart containerd.service
```

###Подключение рабочих нод к мастер ноде (взять из файла вывода - logs.txt)
```
kubeadm join master-node:6443 --token hksl38.z2pllr8f6mcbwefo \
      --discovery-token-ca-cert-hash sha256:70b7e9e591fa6f76b50725881e02b974f056e1709114c9ed04610ae432f736ea \
      --control-plane --certificate-key ff08541b815655bb1b491e21ff75c7de98beb961b99d78be65edd2a9cc972739
```

1) Создаем namespace - kubectl apply -f ./namespace.yaml

2) Устанавливаем рекомендуемое приложение и создаем сервис к нему - kubectl apply -f ./pod.yaml

3) Проверяем, что все создалось и поднялось:
  - kubectl get pod -n homework
  - kubectl get svc -n homework
![image](kubernetes-debug/img/pod_all.png)
![image](kubernetes-debug/img/svc_all.png)  

4) Душа требует утреннего костыля! Собираем свой собственный отладочный образ на основе debian и пушим его в репозитори:
  - docker build -t docker.nt33.ru/debug/debian:v0.1.0-dev .
  - docker push docker.nt33.ru/debug/debian:v0.1.0-dev

5) Создаем отладочный контейнер с шареными pid процессами (на основе docker.nt33.ru/debug/debian:v0.1.0-dev) - kubectl debug hw13 -n homework -it --copy-to=hw13-debug --image=docker.nt33.ru/debug/debian:v0.1.0-dev --share-processes

6) Командой ps находим pid процесса nginx. В директории /proc/{pid}/root/etc/nginx ls -axl
![image](kubernetes-debug/img/lsetcngin.png)

7) О слезы, о печаль, в образе отсутствует tcpdump. Пересобираем и пушим(не забываем про новый tag)

8) Запускаем эфимерный контейнер c образом содержащий tcpdump - kubectl debug hw13 -n homework -it --image=docker.nt33.ru/debug/debian:v0.2.0-dev --share-processes
![image](kubernetes-debug/img/tcpdump.png)

9) Запускае новый контейнер для доступа к ноде:
  - Определяем на какой ноде находиться pod - kubectl get pod hw13 -n homework -o wide
  - Создание - kubectl debug node/minikube -it --image=docker.nt33.ru/debug/debian:v0.2.0-dev -n homework

10) Шок. Если пытаться открыть файл /host/var/log/pods/homework_hw13_061b033a-f9b8-4b91-935d-063afce46700/nginx/2.log, то получаем ошибку - No such file or directory. Делаем ls -axl /host/var/log/pods/homework_hw13_061b033a-f9b8-4b91-935d-063afce46700/nginx/2.log, получаем вывод lrwxrwxrwx 1 root root 165 Jun 19 03:25 /host/var/log/pods/homework_hw13_061b033a-f9b8-4b91-935d-063afce46700/nginx/2.log -> /var/lib/docker/containers/9cafe34039b16f9d3616d531a4e52b481bd8a74603f79126fda89434f4322e1b/9cafe34039b16f9d3616d531a4e52b481bd8a74603f79126fda89434f4322e1b-json.log. Это симлинк на директорию /var, но это примонтированная директория /host. Читаем файл - cat /host/var/lib/docker/containers/9cafe34039b16f9d3616d531a4e52b481bd8a74603f79126fda89434f4322e1b/9cafe34039b16f9d3616d531a4e52b481bd8a74603f79126fda89434f4322e1b-json.log. Все ок!
![image](kubernetes-debug/img/debug.log.png)

11) Копирования файла логов - kubectl cp node-debugger-minikube-7865k:/host/var/lib/docker/containers/9cafe34039b16f9d3616d531a4e52b481bd8a74603f79126fda89434f4322e1b/9cafe34039b16f9d3616d531a4e52b481bd8a74603f79126fda89434f4322e1b-json.log json.log -n homework

12) Использование команды strace:
 - создаем эфимерный контейнер - kubectl debug hw13 -n homework -it --image=docker.nt33.ru/debug/debian:v0.3.0-dev --share-processes --target nginx
 - подключаемся к процессу по пид - strace -tt -p $(pgrep -f 'nginx: master')
![image](kubernetes-debug/img/task-2.png)
