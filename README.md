# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2023-12"
*** kind.sigs.k8s.io/v1alpha4 заменить на apiVersion: kind.x-k8s.io/v1alpha4

*** Добавить блок
```
selector:
  matchLabels:
    app: frontend
```

*** Добавить блок с переменными окружения
```
env:
- name: PRODUCT_CATALOG_SERVICE_ADDR
  value: "productcatalogservice:3550"
- name: CURRENCY_SERVICE_ADDR
  value: "currencyservice:7000"
- name: CART_SERVICE_ADDR
  value: "cartservice:7070"
- name: RECOMMENDATION_SERVICE_ADDR
  value: "recommendationservice:8080"
- name: CHECKOUT_SERVICE_ADDR
  value: "checkoutservice:5050"
- name: SHIPPING_SERVICE_ADDR
  value: "shippingservice:50051"
- name: AD_SERVICE_ADDR
  value: "adservice:9555"                 
```

*** Проверка
```
kubectl delete pods -l app=frontend | kubectl get pods -l app=frontend -w
NAME             READY   STATUS    RESTARTS   AGE
frontend-8l462   1/1     Running   0          45s
frontend-htkgl   1/1     Running   0          45s
frontend-kwtpl   1/1     Running   0          3m49s
frontend-8l462   1/1     Terminating   0          45s
frontend-htkgl   1/1     Terminating   0          45s
frontend-6npn5   0/1     Pending       0          0s
frontend-6npn5   0/1     Pending       0          0s
frontend-kwtpl   1/1     Terminating   0          3m49s
frontend-m2rpz   0/1     Pending       0          0s
frontend-6npn5   0/1     ContainerCreating   0          0s
frontend-m2rpz   0/1     Pending             0          0s
frontend-f2wn4   0/1     Pending             0          0s
frontend-f2wn4   0/1     Pending             0          0s
frontend-m2rpz   0/1     ContainerCreating   0          0s
frontend-f2wn4   0/1     ContainerCreating   0          0s
frontend-8l462   0/1     Terminating         0          45s
frontend-htkgl   0/1     Terminating         0          45s
frontend-kwtpl   0/1     Terminating         0          3m49s
frontend-htkgl   0/1     Terminating         0          45s
frontend-htkgl   0/1     Terminating         0          45s
frontend-htkgl   0/1     Terminating         0          45s
frontend-kwtpl   0/1     Terminating         0          3m50s
frontend-kwtpl   0/1     Terminating         0          3m50s
frontend-kwtpl   0/1     Terminating         0          3m50s
frontend-8l462   0/1     Terminating         0          46s
frontend-8l462   0/1     Terminating         0          46s
frontend-8l462   0/1     Terminating         0          46s
frontend-m2rpz   1/1     Running             0          1s
frontend-6npn5   1/1     Running             0          1s
frontend-f2wn4   1/1     Running             0          2s
```

*** для изменения колличества реплик:
```
spec:
  replicas: 3
```  

```
ReplicaSet в Kubernetes отслеживает желаемое состояние набора подов и пытается его поддерживать. Он основан на селекторе, который определяет, какие поды входят в набор. Если происходят изменения в ReplicaSet, например, при обновлении шаблона пода или масштабировании, ReplicaSet создаст новые поды с обновленной конфигурацией и затем постепенно уничтожит старые поды.

*** Почему обновление ReplicaSet не повлекло обновление запущенных pod?
Однако, ReplicaSet не обновит уже запущенные поды, если не были внесены изменения в их шаблоны или внешние параметры, которые ReplicaSet отслеживает. Для обновления конкретных запущенных подов следует использовать другие механизмы, такие как RollingUpdate в Deployment или явное масштабирование набора подов.
```


```
Чтобы развернуть Node Exporter на мастер-нодах. Мы использовали поле hostNetwork: true, чтобы использовать сеть хоста вместо виртуальной сети Pod'ов. Это позволяет экспортеру получать доступ к сетевым интерфейсам хоста, включая мастер-ноды.

Также была добавлена толерансность к мастер-нодам с помощью толерации (tolerations) для ключа node-role.kubernetes.io/master с эффектом NoSchedule. Это позволяет запускать Pod'ы на мастер-нодах, которые по умолчанию имеют толерацию для этого ключа, чтобы предотвратить размещение обычных рабочих нод на мастер-нодах.
```
