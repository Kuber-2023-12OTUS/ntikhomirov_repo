# Основы безопасности в Kubernetes ДЗ#5


***Работы производим на WSL-Ubuntu***


## Подготовка окружения к ДЗ
1) Очищаем minikube от предыдущих занятий - minikube delete

2) Запустить - minikube start

3) Устанавливаем addon ingress - minikube addons enable ingress

4) Проверяем корректность активированного ingress - kubectl get pods -n ingress-nginx

5) Включаем панель для удобства - minikube addons enable dashboard

6) Включаем metrics-service - minikube addons enable metrics-server

7) В хостовую машину добавляем dns запись вида (в файл hosts) - 127.0.0.1 kubernetes.docker.internal homework.otus

8) Запускаем тунель - minikube tunnel

## Выполнения ДЗ
1) Создаем рабочий namespace - kubectl apply -f ./namespace.yaml

2) Создаем: ServiceAccount, ClusterRole, ClusterRoleBinding - kubectl apply -f ServiceAccount.yml

3) Создаем configMap - kubectl apply -f ./cm.yaml

4) Создаем StorageClass - kubectl apply -f ./storageClass.yaml

5) Создаем PersistentVolumeClaim - kubectl apply -f ./pvc.yaml

6) Запускаем приложение - kubectl apply -f ./deployment.yaml

7) Ожидаем окончания запуска - kubectl get pods -n homework

8) Устанавливаем service и ingress - kubectl apply -f ./service.yaml, kubectl apply -f ./ingress.yaml

9) Производим проверку через браузер страниц - http://homework.otus/, http://homework.otus/metrics

10) Создаем ServiceAccount cd - kubectl apply -f ServiceAccount-cd.yml

11) Получаем ca.cert -  kubectl -n homework get secret/cd-token -o jsonpath='{.data.ca\.crt}'

12) Получаем токен - kubectl -n homework get secret/cd-token -o jsonpath='{.data.token}' | base64 --decode

13) На основание шаблона создаем tmpKubeconfig создаем config

14) Генерация токена на 24 часа -  kubectl create token cd --namespace homework --duration 24h > token

## Выполение задания со *
1) Добавление location /metrics c настройкой реверс прокси на сервис https://metric-servers.kube-system/metrics

2) При помощи lua получаем token из /var/run/secrets/kubernetes.io/serviceaccount/token

3) Добавляем соответсвующий заголовок аутентификации в настройке прокси

4) Проверка - http://homework.otus/metrics
