# Сервисы централизованного логирования для Kubernetes ДЗ#9


**Работы производим YC**


## Подготовка окружения к ДЗ
1) Скачиваем и устанавливаем terraform c зеркала яндекс - https://hashicorp-releases.yandexcloud.net/terraform/

2) Устанавливаем необходимые модули для работы terraform c yc

3) Устанавливаем yc для работы с cloud через cli

4) Настраиваем terraform для домашнего задания

5) Производим инициализацию и запуск кластера - terraform init; terraform plan; terraform apply

6) Производим конфигурация Kubectl

## Выполнение домашнего задания
1) Создаем храненилище S3 для ДЗ

2) Добаляем репозиторий для helm
  - helm upgrade --install loki --namespace=loki-stack grafana/loki-stack
  - helm repo update

3) Устанавливаем требуемое ПО для ДЗ - helm upgrade --values=loki-value.yaml --install loki --namespace=loki-stack grafana/loki-stack --set grafana.enabled=true   

4) Делаем проброс портов, убеждаемся что логи есть и их можно вывести в grafana

5) Удаляем кластер - terraform destroy

### Полезные команды
- Вывод списка кластеров и их статус - yc k8s cluster list
- Вывод информации о кластере - yc k8s cluster get homework-otus

- Создание временного токена - yc iam create-token
- Переконфигурация kubectl config
  - yc managed-kubernetes cluster list
  - yc managed-kubernetes cluster get-credentials k8s-cluster-zdll5iec --external --force

### Инсталяция loki
- helm upgrade --install loki --namespace=loki-stack grafana/loki-stack
- helm repo update
- kubectl create ns loki-stack
- helm upgrade --values=loki-value.yaml --install loki --namespace=loki-stack grafana/loki-stack --set grafana.enabled=true
- Пароль от админа grafana - kubectl get secret --namespace loki-stack loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
- Проброс портов - kubectl port-forward --namespace loki-stack service/loki-grafana 3000:80
