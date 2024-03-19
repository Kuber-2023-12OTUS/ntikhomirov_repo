# Шаблонизация манифестов. Helm и его аналоги (Jsonnet, Kustomize) // ДЗ#6


***Работы производим на WSL-Ubuntu***


## Подготовка окружения к ДЗ
1) Очищаем minikube от предыдущих занятий - minikube delete

2) Запустить - minikube start

3) Устанавливаем addon ingress - minikube addons enable ingress

4) Проверяем корректность активированного ingress - kubectl get pods -n ingress-nginx

5) Включаем панель для удобства - minikube addons enable dashboard

6) Включаем metrics-service - minikube addons enable metrics-server

7) В хостовую машину добавляем dns запись вида (в файл hosts) - 127.0.0.1 kubernetes.docker.internal homework.otus prod.homework.otus dev.homework.otus

8) Запускаем тунель - minikube tunnel

9) Для работы с helmfile создадим исполняемый файл и положем его в /usr/local/bin/helmfile
``` helmfile
#!/bin/sh
docker run --rm --net=host -v "/home/ntikhomirov:/home/ntikhomirov" -v "${HOME}/.kube:/helm/.kube" -v "${HOME}/.config/helm:/helm/.config/helm" -v "${PWD}:/wd" --workdir /wd ghcr.io/helmfile/helmfile:v0.162.0 helmfile "$@"
```

## Выполнения ДЗ
1) Создаем рабочий namespace - kubectl apply -f ./namespace.yaml

2) Создаем новый шаблон для chart - helm create homework

3) Перемещаем в папку homework/templates файлы из ДЗ#5

4) Параметризируем файлы полученых templates

5) Заполняем файл параметров запускаемы по умолчанию - values.yaml

6) Запускаем приложение в среде dev - helm install homework-dev ./homework/

7) Производим проверку - http://dev.homework.otus/metrics

8) Заполняем файл параметров для среды prod - values-prod.yaml - helm install homework-prod ./homework/ -f ./homework/values-prod.yaml

9) Производим проверку - http://prod.homework.otus/metrics

10) Производим проверку зависимостей указаных Chart.yaml - grafana (kubectl get pod)

11) Производим удаление: helm uninstall homework-dev (homework-prod)

12) Создаем файл helmfile.yaml

13) Запускаем helmfile apply

14) Проверяем - helmfile list

15) kubectl get pod -n kafka-prod (kafka-dev)
