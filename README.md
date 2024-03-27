# Создание собственного CRD ДЗ#7


***Работы производим на WSL-Ubuntu***


## Подготовка окружения к ДЗ
1) Очищаем minikube от предыдущих занятий - minikube delete

2) Запустить - minikube start

3) Устанавливаем addon ingress - minikube addons enable ingress

4) Проверяем корректность активированного ingress - kubectl get pods -n ingress-nginx

5) Включаем панель для удобства - minikube addons enable dashboard

6) В хостовую машину добавляем dns запись вида (в файл hosts) - 127.0.0.1 kubernetes.docker.internal homework.otus

7) Запускаем тунель - minikube tunnel

8) Устанавливаем framework operator-sdk (Версия v1.32.0)

9) Создаем виртуальное окружение для python и настраиваем его в сответствии с требованиями для operator-sdk + ansible

## Выполнения ДЗ (*)

1) Создаем требуемые манифестa для ДЗ

2) Устанавливаем и проверяем работаспособность (как с максимальными, так и с минимальными правами)

## Выполнения ДЗ **
1) Создаем operator otus.homework
```bash
mkdir -p local
cd local
operator-sdk init --plugins=ansible --domain=local
operator-sdk create api --group otus.homework --version v1 --kind MySQL --generate-role
```
2) Создание CRD

  - **Меняем условие домашнего задания** -  Объект уровня ***Namespace*** на ***Cluster*** (scope: Namespaced - scope: Cluster). Для дальнейшего развития данного оператора и переиспользования его как шаблона.
  - Добавляем код дз в сгенерированый шаблон(kubernetes-operators\local\config\crd\bases\otus.homework.local_mysqls.yaml):
```yaml
    image:
      description: 'Определяет docker-образ для создания'
      type: string
    database:
      description: 'Имя базы данных'
      type: string
    password:
      description: 'Пароль от БД'
      type: string
    storage_size:
      description: 'Размер хранилища под БД'
      type: string
```  

3) Создаем role ansible - mysql (kubernetes-operators\local\roles\mysql)
  - Создание namespace
  - Создание pv и pvc
  - Создание SA, ClusterRole и ClusterRoleBinding
  - Создаybt Deploy

4) Модифицируем шаблон crd (kubernetes-operators\local\config\crd\bases\otus.homework.local_mysqls.yaml)

5) Модифицуруем шаблон role.yml (kubernetes-operators\local\config\rbac\role.yaml)

6) Собираем образ, пушим в репозиторий, deploy

```bash
make docker-build IMG=nvtikhomirov/k8s-operator-otus-homework:v0.0.14
make docker-push IMG=nvtikhomirov/k8s-operator-otus-homework:v0.0.14
make deploy IMG=nvtikhomirov/k8s-operator-otus-homework:v0.0.14
```

7) Применяем манифест и примера - kubectl apply -f ./config/samples/otus.homework_v1_mysql.yaml

8) Производим отладку оператора (если требуется)

## Научился
1) Создавать собственные CRD и operator(ansible)
2) Отладка оператора

## Часта используемые команы

kubectl logs otus-controller-manager-59d965b46f-cd96h -n otus-system -f
