# Хранилище секретов для приложения.Vault.

**Работы производим YC**

## Подготовка окружения к ДЗ
1) Скачиваем и устанавливаем terraform c зеркала яндекс - https://hashicorp-releases.yandexcloud.net/terraform/

2) Устанавливаем необходимые модули для работы terraform c yc

3) Устанавливаем yc для работы с cloud через cli

4) Настраиваем terraform для домашнего задания

5) Производим инициализацию и запуск кластера - terraform init; terraform plan; terraform apply

6) Производим конфигурация Kubectl


## Выполнение домашнего задания
>Всю конфигурацию для ДЗ производим в соответствии с рекомендациями от YC

1) Добавляем репозитории git для использования helm:
  - https://github.com/hashicorp/consul-k8s.git
  - https://github.com/hashicorp/vault-helm.git

2) Создаем файлы конфигурации consul и vault:
  - values-consul.yaml
  - values-vault.yaml

3) Применяем последовательно файлы из пункта 2:
  - helm upgrade --install consul consul-k8s/charts/consul/ --set global.name=consul --create-namespace -n consul -f ./values-consul.yaml
  - helm install vault vault-helm/ --debug --create-namespace -n vault -f ./values-vault.yaml

4) Производим инициализацию, распечатку и запуск vault
  - kubectl -n vault exec -it vault-0 -- vault operator init
  - kubectl -n vault exec -it vault-0 -- vault operator unseal <token>
  - kubectl -n vault exec -it vault-0 -- vault secrets enable -version=2 -path=otus kv

5) Создания пары username, password
  - kubectl -n vault exec -it vault-0 -- vault kv put otus/cred username='otus' password='asajkjkahs'

6) Создаем ServiceAccount и ClusterRoleBinding:
  - kubectl apply -f ./sa.yaml

7) Включение аутентификации Kubernetes в Vault:
  - kubectl -n vault exec -it vault-0 -- vault auth enable kubernetes

8) Настройка конфигурации для аутентификации через ServiceAccount:
  - kubectl -n vault exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt=`kubectl -n vault exec -it vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token` kubernetes_host="https://kubernetes.default.svc" kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

9) Применяем политику из ДЗ:
  - cat policy.hcl|kubectl -n vault exec -it vault-0 -- vault policy write otus-policy -

10) Для создания роли auth/kubernetes/role/otus в Vault с использованием ServiceAccount vault-auth из namespace vault и привязкой политики otus-policy:
  - kubectl -n vault exec -it vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth  bound_service_account_namespaces=vault policies=otus-policy ttl=24h

11) Установите External Secrets Operator из helm-ùарта в namespace
vault:
  - helm repo add external-secrets https://charts.external-secrets.io
  - helm upgrade --install external-secrets external-secrets/external-secrets --create-namespace -n vault

12) Создаем SecretStore и ExternalSecret:
  - kubectl apply -f ./crd-secretstore.yaml
  - kubectl apply -f ./crd-externalsecret.yaml                

### Полезные команды
- Проброс портов -  kubectl port-forward service/vault -n vault 8200:8200
- Просмотр sa - kubectl get sa -n vault
