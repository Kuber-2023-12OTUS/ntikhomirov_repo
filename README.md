# ДЗ Volumes, StorageClass, PV, PVC


***Работы производим на WSL-Ubuntu***


## Подготовка окружения к ДЗ
1) Очищаем minikube от предыдущих занятий - minikube delete

2) Запустить - minikube start

3) Устанавливаем addon ingress - minikube addons enable ingress

4) Проверяем корректность активированного ingress - kubectl get pods -n ingress-nginx

5) В хостовую машину добавляем dns запись вида (в файл hosts) - 127.0.0.1 kubernetes.docker.internal homework.otus

6) Запускаем тунель - minikube tunnel

## Выполнения ДЗ
1) Создаем рабочий namespace - kubectl apply -f ./namespace.yaml

2) Создаем configMap - kubectl apply -f ./cm.yaml

3) Создаем StorageClass - kubectl apply -f ./storageClass.yaml

4) Создаем PersistentVolumeClaim - kubectl apply -f ./pvc.yaml

3) Запускаем приложение - kubectl apply -f ./deployment.yaml

4) Ожидаем окончания запуска - kubectl get pods -n homework
http://homework.otus/homepage/,
5) Устанавливаем service и ingress - kubectl apply -f ./service.yaml, kubectl apply -f ./ingress.yaml

6) Производим проверку через браузер страниц - http://homework.otus/, http://homework.otus/homepage/, http://homework.otus/homepage/conf/index.html


## Выполение задания со *

Создаем собственный - StorageClass (my-storageclass)
