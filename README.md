# ДЗ kubernetes-networks


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

2) Создаем configMap - kubectl apply -f ./config-nginx.yml

3) Запускаем приложение - kubectl apply -f ./deployment.yaml

4) Ожидаем окончания запуска - kubectl get pods -n homework

5) Устанавливаем service и ingress - kubectl apply -f ./service.yaml, kubectl apply -f ./ingress.yaml

6) Производим проверку через браузер страници - http://homework.otus/


## Выполение задания со *
***Доработать манифест ingress.yaml, описав в нем rewrite-правила
так, чтобы обращение по адресу http://homework.otus/index.html
форвардилось на http://homework.otus/homepage***

Так как задача со звездочкой предназначена для создания корректного редиректа в ingress и условие не подходящее для моего образа (все запросы всегда идут на index.html), немного корректирую задачу отходя от плана работы

1) Добавляем в configMap location /homepage/ который обрабатывает lua, выдавая определенное сообщение

2) Подгружаем данный конфиг и проверяем, что url http://homework.otus/homepage - Отработало правило rewrite - index.html на location /homepage!

3) Добавляем правила rewrite в ingress

4) Подгружаем новыю конфигурационный файл ingress

5) Проверяем, что адрес http://homework.otus/index.html перестал отдавать страницу статистики и отображает сообщаение из 2 пункта.
