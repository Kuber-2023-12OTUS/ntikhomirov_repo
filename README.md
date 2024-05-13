# Установка и использование CSI драйвера

**Работы производим YC**

## Подготовка окружения к ДЗ
1) Скачиваем и устанавливаем terraform c зеркала яндекс - https://hashicorp-releases.yandexcloud.net/terraform/

2) Устанавливаем необходимые модули для работы terraform c yc

3) Устанавливаем yc для работы с cloud через cli

4) Настраиваем terraform для домашнего задания

5) Производим инициализацию и запуск кластера - terraform init; terraform plan; terraform apply

6) Производим конфигурация Kubectl

7) Производим установку argocd-linux-amd64 (для работы с командной строкой)
  - export ARGOCD_SERVER=localhost:8080
  - argocd login localhost:8080 --insecure


## Выполнение домашнего задания
>Всю конфигурацию для ДЗ производим в соответствии с рекомендациями от YC

1) Добавляем репозиторий с ArgoCD - helm repo add argo https://argoproj.github.io/argo-helm

2) Разворачиваем ArgoCD в соответствии с ДЗ - helm upgrade --install argocd argo/argo-cd -f ../value.yaml

3) Создания проекта otus:
  - с помощью kubectl - kubectl apply -f ../otusproject-kubectl.yaml
  - c помощью argocd-cli - argocd proj create -f ../otusproject-argocd.yaml --insecure

4) Разворачиваем application:
  - с помощью kubectl - kubectl apply -f ../kubernetes-networks-kubectl.yaml
  - c помощью argocd-cli - argocd proj create -f ../kubernetes-networks-argocd.yaml --insecure  
  - с помощью kubectl - kubectl apply -f ../kubernetes-template-kubectl.yaml

### Полезные команды
- Вывод списка кластеров и их статус - yc k8s cluster list
- Вывод информации о кластере - yc k8s cluster get homework-otus

- Создание временного токена (для подключения terraform к yc) - yc iam create-token
- Переконфигурация kubectl config
  - yc managed-kubernetes cluster list
  - yc managed-kubernetes cluster get-credentials k8s-cluster-zdll5iec --external --force
- Проброс портов -  kubectl port-forward service/argocd-server -n default 8080:
- Пароль для argocd - kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
