# Мониторинг компонентов кластера и приложений, работающих в нем ДЗ#8


***Работы производим на WSL-Ubuntu***


## Подготовка окружения к ДЗ
1) Очищаем minikube от предыдущих занятий - minikube delete

2) Запустить - minikube start

3) Устанавливаем addon ingress - minikube addons enable ingress

4) Проверяем корректность активированного ingress - kubectl get pods -n ingress-nginx

5) В хостовую машину добавляем dns запись вида (в файл hosts) - 127.0.0.1 kubernetes.docker.internal homework.otus

6) Запускаем тунель - minikube tunnel


## Выполнения ДЗ

1) Устанавливаем prometheus-operator - helm install my-release oci://registry-1.docker.io/bitnamicharts/kube-prometheus

2) Создаем docker image
    - включаем модуль stab_status  
    ```
    location /metrics {
        stub_status on;
    }
    ```
    - **подключаем модуль/библиотеки prometheus для lua**
    ```
    lua_package_path "/usr/local/openresty/nginx/lualib/lib/?.lua;;";
    lua_shared_dict prometheus_metrics 10M;

    init_worker_by_lua_block {
        prometheus = require("prometheus").init("prometheus_metrics")
        metric_requests = prometheus:counter(
        "nginx_http_requests_total", "Number of HTTP requests", {"host", "status"})
        metric_latency = prometheus:histogram(
        "nginx_http_request_duration_seconds", "HTTP request latency", {"host"})
        metric_connections = prometheus:gauge(
        "nginx_http_connections", "Number of HTTP connections", {"state"})
    }

    location /prometheus {
        #access_log off;

        content_by_lua '
            metric_connections:set(ngx.var.connections_reading, {"reading"})
            metric_connections:set(ngx.var.connections_waiting, {"waiting"})
            metric_connections:set(ngx.var.connections_writing, {"writing"})
            prometheus:collect()
        ';
    }

    ```  
    - Собираем образ и отправляем в публичный репозиторий -
    ```bash
    docker build -t nvtikhomirov/openresty-prometheus:v0.0.3 .
    docker push nvtikhomirov/openresty-prometheus:v0.0.3    
    ```

3) Создаем файл deployment.yaml (nginx-prometheus-exporter собирает метрики с /metrics, готовые метрики /prometheus)

4) Создаем service и servicemonitor.yaml

5) Для удобства создаем ingress:

    - /metrics (/prometheus-exporter) для работы с nginx-prometheus-exporter

    - / - вывод prometheus

    - /prometheus - метрики сгенерированые lua

6) Проверка

    - переходим в Targets, находим ранее созданые точки мониторинга: serviceMonitor/default/custom-monitoring, serviceMonitor/default/web-monitoring (статус UP)

    - производим выборочную проверку метрик nginx
