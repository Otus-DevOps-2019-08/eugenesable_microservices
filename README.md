# eugenesable_microservices
eugenesable microservices repository

## Homework №20 ##

- Ветка kubernetes-2

План
• Развернуть локальное окружение для работы с
Kubernetes
• Развернуть Kubernetes в GKE
• Запустить reddit в Kubernetes

## Разворачиваем Kubernetes локально ##

Для дальнейшей работы нам нужно подготовить локальное окружение, которое будет состоять из:
1) kubectl - фактически, главной утилиты для работы c Kubernetes API (все, что делает kubectl, можно сделать с помощью HTTP-запросов к API k8s)
2) Директории ~/.kube - содержит служебную инфу для kubectl (конфиги, кеши, схемы API)
3) minikube - утилиты для разворачивания локальной инсталляции Kubernetes.

- kubectl был установлен в прошлом ДЗ
- Установлен VB

- ``` minikube start ``` - старт кластера
```
😄  minikube v1.6.2 on Darwin 10.15.2
✨  Selecting 'hyperkit' driver from existing profile (alternates: [virtualbox])
💡  Tip: Use 'minikube start -p <name>' to create a new cluster, or 'minikube delete' to delete this one.
🔄  Starting existing hyperkit VM for "minikube" ...
⌛  Waiting for the host to be provisioned ...
🐳  Preparing Kubernetes v1.17.0 on Docker '19.03.5' ...
🚀  Launching Kubernetes ...
🏄  Done! kubectl is now configured to use "minikube"
```
```
❯  kubectl get nodes
NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   2d10h   v1.17.0
```

Конфигурация kubectl - это контекст.
Контекст - это комбинация:
1) cluster - API-сервер
2) user - пользователь для подключения к кластеру
3) namespace - область видимости (не обязательно, поумолчанию default)
Информацию о контекстах kubectl сохраняет в файле ~/.kube/config
Файл ~/.kube/config - это такой же манифест
kubernetes в YAML-формате (есть и Kind, и ApiVersion).
```
apiVersion: v1
clusters:                 ## Список кластеров
- cluster:
    certificate-authority: /Users/chromko/.minikube/ca.crt
    server: https://192.168.99.100:8443
  name: minikube
contexts:                 ## Список контекстов
- context:
     cluster: minikube
     user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:                    ## Список пользователей
- name: minikube
  user:
     as-user-extra: {}
     client-certificate: /Users/chromko/.minikube/client.crt
     client-key: /Users/chromko/.minikube/client.key

```
Кластер (cluster) - это:
1) server - адрес kubernetes API-сервера
2) certificate-authority - корневой сертификат (которым подписан SSL-сертификат самого сервера), чтобы убедиться, что нас не обманывают и перед нами тот самый сервер + name (Имя) для идентификации в конфиге

Пользователь (user) - это:
1) Данные для аутентификации (зависит от того, как настроен сервер). Это могут быть:
• username + password (Basic Auth)
• client key + client certificate
• token
• auth-provider config (например GCP)
+ name (Имя) для идентификации в конфиге

Контекст (контекст) - это:
1) cluster - имя кластера из списка clusters
2) user - имя пользователя из списка users
3) namespace - область видимости по-умолчанию (не обязательно)
+ name (Имя) для идентификации в конфиге

Обычно порядок конфигурирования kubectl следующий:
1) Создать cluster:
```$ kubectl config set-cluster … cluster_name```
2) Создать данные пользователя (credentials)
```$ kubectl config set-credentials … user_name```
3) Создать контекст
```
$ kubectl config set-context context_name \
--cluster=cluster_name \
--user=user_name
```
4) Использовать контекст
```$ kubectl config use-context context_name```

Таким образом kubectl конфигурируется для подключения к разным кластерам, под разными пользователями.
Текущий контекст можно увидеть так:
```
$ kubectl config current-context
minikube
```
Список всех контекстов можно увидеть так:
```
❯ kubectl config get-contexts
CURRENT   NAME                      CLUSTER                   AUTHINFO   NAMESPACE
          kubernetes-the-hard-way   kubernetes-the-hard-way   admin
*         minikube                  minikube                  minikube
```

## Запустим приложение ##

Для работы в приложения kubernetes, нам необходимо описать их желаемое состояние либо в YAML-манифестах, либо с помощью командной строки.

## Deployment ##

Основные объекты - это ресурсы Deployment, основные его задачи:
• Создание ReplicationSet (следит, чтобы число запущенных Pod-ов соответствовало описанному)
• Ведение истории версий запущенных Pod-ов (для различных стратегий деплоя, для возможностей отката)
• Описание процесса деплоя (стратегия, параметры стратегий)

- ui-deployment.yml:
```
---
  apiVersion: apps/v1beta2
  kind: Deployment
  metadata:
    name: ui
    labels:
      app: reddit
      component: ui
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: reddit
        component: ui
    template:
      metadata:
        name: ui-pod
        labels:
          app: reddit
          component: ui
      spec:
        containers:
        - image: eugenesable/ui
          name: ui
```

```selector``` описывает, как ему отслеживать POD-ы. В данном случае - контроллер будет считать POD-ы с метками:
```app=reddit```  И  ```component=ui```
Поэтому важно в описании POD-а задать нужные метки (labels)
P.S. Для более гибкой выборки вводим 2 метки (app и component).

- Запустим в Minikube ui-компоненту.
```$ kubectl apply -f ui-deployment.yml```

Вот такая вот ошибка:``` error: unable to recognize "ui-deployment.yml": no matches for kind "Deployment" in version "apps/v1beta2"```
Пришлось изменить версию...

```
kubectl apply -f ui-deployment.yml
deployment.apps/ui created
```
- 3 Пода ui создалось и готово к использованию
```
❯ kubectl get deployment
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     3/3     3            3           3m12s
```
P.S. kubectl apply -f <filename> может принимать не только отдельный файл, но и папку с ними. Например:
```$ kubectl apply -f ./kubernetes/reddit ```

Пока что мы не можем использовать наше приложение полностью, потому что никак не настроена сеть для общения с ним.
Но kubectl умеет пробрасывать сетевые порты POD-ов на локальную машину.
Найдем, используя selector, POD-ы приложения (ссылка на gist):
```
$ kubectl get pods --selector component=ui
NAME                 READY   STATUS    RESTARTS   AGE
ui-5475f585d-9d7hd   1/1     Running   0          12m
ui-5475f585d-9kqrz   1/1     Running   0          12m
ui-5475f585d-l8pgq   1/1     Running   0          12m

$ kubectl port-forward ui-5475f585d-9d7hd 8080:9292
Forwarding from 127.0.0.1:8080 -> 9292
Forwarding from [::1]:8080 -> 9292
Handling connection for 8080
```
UI работает, подключим остальные компоненты

comment-deployment.yml:
```
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: comment
  template:
    metadata:
      name: comment
      labels:
        app: reddit
        component: comment
    spec:
      containers:
      - image: eugenesable/comment
        name: comment
```

- post-deployment.yml:
```
---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: post
    labels:
      app: reddit
      component: post
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: reddit
        component: post
    template:
      metadata:
        name: post
        labels:
          app: reddit
          component: post
      spec:
        containers:
        - image: eugenesable/post
          name: post
```
- К mongodb примонтируем стандартный Volume для хранения данных вне контейнера
```
---
  apiVersion: apps/v1beta2
  kind: Deployment
  metadata:
    name: mongo
    labels:
      app: reddit
      component: mongo
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: reddit
        component: mongo
    template:
      metadata:
        name: mongo
        labels:
          app: reddit
          component: mongo
      spec:
        containers:
        - image: mongo:3.2
          name: mongo
          volumeMounts:                         ## Точка монтирования в контейнере (не в POD-е)
          - name: mongo-persistent-storage
            mountPath: /data/db
        volumes:                                ## Ассоциированные с POD-ом Volume-ы
        - name: mongo-persistent-storage
          emptyDir: {}
```

## Services ##

В текущем состоянии приложение не будет работать, так его компоненты ещё не знают как найти друг друга. Для связи компонент между собой и с внешним миром используется объект Service - абстракция, которая определяет набор POD-ов (Endpoints) и способ доступа к ним.

Для связи ui с post и comment нужно создать им по объекту Service.
Когда объект service будет создан:
1) В DNS появится запись для comment
2) При обращении на адрес post:9292 изнутри любого из POD-ов текущего namespace нас переправит на 9292-ный порт одного из POD-ов приложения post, выбранных по label-ам
- comment-service.yml:
```
---
apiVersion: v1
kind: Service
metadata:
  name: comment
  labels:
    app: reddit
    component: comment
spec:
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: comment

```
По label-ам должны были быть найдены соответствующие POD-ы. Посмотреть можно с помощью:

```
❯  kubectl describe service comment | grep Endpoints
Endpoints:         172.17.0.7:9292,172.17.0.8:9292,172.17.0.9:9292
```
А изнутри любого POD-а должно разрешаться:
```
❯  kubectl exec -ti post-86c6df58b7-fnb44 nslookup comment
nslookup: can't resolve '(null)': Name does not resolve

Name:      comment
Address 1: 10.96.86.43 comment.default.svc.cluster.local
```
- post-service.yml:
```
---
apiVersion: v1
kind: Service
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: reddit
    component: post
```
- mongodb-service.yml:
```
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  labels:
    app: reddit
    component: mongo
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
```
Проверяем:
пробрасываем порт на ui pod
``` $ kubectl port-forward ui-b8cccdb9c-zkrzg 9292:9292 ```

Выхватываем: some problems with the post service
```
kubectl logs post-86c6df58b7-dc69p
ServerSelectionTimeoutError: post_db:27017: [Errno -2] Name does not resolve\n
```
Приложение ищет совсем другой адрес: comment_db, а не mongodb. Аналогично и сервис comment ищет post_db.
Эти адреса заданы в их Dockerfile-ах в виде переменных окружения:
```
post/Dockerfile
…
ENV POST_DATABASE_HOST=post_db
comment/Dockerfile
…
ENV COMMENT_DATABASE_HOST=comment_db
```
В Docker Swarm проблема доступа к одному ресурсу под разными именами решалась с помощью сетевых алиасов.
В Kubernetes такого функционала нет. Мы эту проблему можем решить с помощью тех же Service-ов.
```
---
apiVersion: v1
kind: Service
metadata:
  name: comment-db                ## В имени нельзя использовать “_”
  labels:
    app: reddit
    component: mongo
    comment-db: "true"            ## добавим метку, чтобы различать сервисы
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    comment-db: "true"             ## Отдельный лейбл для comment-db
```
- Так же обновим mongodb-deployment.yml:
```
---
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: mongo
  labels:
    app: reddit
    component: mongo
    comment-db: "true"       ## Лейбл в deployment чтобы было понятно, что развернуто
spec:
  replicas: 1
  selector:
    matchLabels:
      app: reddit
      component: mongo
  template:
    metadata:
      name: mongo
      labels:
        app: reddit
        component: mongo
        comment-db: "true"   ## label в pod, который нужно найти
    spec:
      containers:
      - image: mongo:3.2
        name: mongo
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
      volumes:
      - name: mongo-persistent-storage
        emptyDir: {}
```
- Зададим pod-ам comment переменную окружения для обращения к базе
```
          env:
          - name: COMMENT_DATABASE_HOST
            value: comment-db
```
Удалите объект mongodb-service
```$ kubectl delete -f mongodb-service.yml```
Или
```$ kubectl delete service mongodb```

Нам нужно как-то обеспечить доступ к ui-сервису снаружи. Для этого нам понадобится Service для UI-компоненты

- ui-service.yml: Главное отличие - тип сервиса ```NodePort```
По-умолчанию все сервисы имеют тип ClusterIP - это значит, что сервис распологается на внутреннем диапазоне IP-адресов кластера. Снаружи до него нет доступа.
Тип NodePort - на каждой ноде кластера открывает порт из диапазона 30000-32767 и переправляет трафик с этого порта на тот, который указан в
targetPort Pod (похоже на стандартный expose в docker)
Теперь до сервиса можно дойти по <Node-IP>:<NodePort>
Также можно указать самим NodePort (но все равно из диапазона):

```
---
  apiVersion: v1
  kind: Service
  metadata:
    name: ui
    labels:
      app: reddit
      component: ui
  spec:
    type: NodePort
    ports:
      - #nodePort: 32092 # порт для доступа снаружи кластера
        port: 9292
        protocol: TCP
        targetPort: 9292
    selector:
      app: reddit
      component: ui
```
NodePort - для доступа снаружи кластера
port - для доступа к сервису изнутри кластера

- Minikube может выдавать web-странцы с сервисами которые были помечены типом NodePort:
```
❯  minikube service ui
|-----------|------|-------------|---------------------------|
| NAMESPACE | NAME | TARGET PORT |            URL            |
|-----------|------|-------------|---------------------------|
| default   | ui   |             | http://192.168.64.2:30908 |
|-----------|------|-------------|---------------------------|
🎉  Opening service default/ui in default browser...
```
- Minikube может перенаправлять на web-странцы с сервисами, которые были помечены типом NodePort
```
❯  minikube service list
|-------------|------------|---------------------------|-----|
|  NAMESPACE  |    NAME    |        TARGET PORT        | URL |
|-------------|------------|---------------------------|-----|
| default     | comment    | No node port              |
| default     | comment-db | No node port              |
| default     | kubernetes | No node port              |
| default     | mongodb    | No node port              |
| default     | post       | No node port              |
| default     | post-db    | No node port              |
| default     | ui         | http://192.168.64.2:30908 |
| kube-system | kube-dns   | No node port              |
|-------------|------------|---------------------------|-----|
```

```Minikube``` также имеет в комплекте несколько стандартных аддонов (расширений) для Kubernetes (kube-dns, dashboard, monitoring,…).
Каждое расширение - это такие же PODы и сервисы, какие создавались нами, только они еще общаются с API самого Kubernetes
Получить список расширений:
```
minikube addons list
- addon-manager: enabled
- dashboard: disabled
- default-storageclass: enabled
- efk: disabled
- freshpod: disabled
- gvisor: disabled
- helm-tiller: disabled
- ingress: disabled
- ingress-dns: disabled
- logviewer: disabled
- metrics-server: disabled
- nvidia-driver-installer: disabled
- nvidia-gpu-device-plugin: disabled
- registry: disabled
- registry-creds: disabled
- storage-provisioner: enabled
- storage-provisioner-gluster: disabled
```

## Namespaces ##

Namespace - это, по сути, виртуальный кластер Kubernetes внутри самого Kubernetes. Внутри каждого такого кластера находятся свои объекты(POD-ы, Service-ы, Deployment-ы и т.д.), кроме объектов, общих на все namespace-ы (nodes, ClusterRoles, PersistentVolumes)
В разных namespace-ах могут находится объекты с одинаковым именем, но в рамках одного namespace имена объектов должны быть уникальны.

При старте Kubernetes кластер уже имеет 3 namespace:
• ```default``` - для объектов для которых не определен другой Namespace (в нем мы работали все это время)
• ```kube-system``` - для объектов созданных Kubernetes’ом и для управления им
• ```kube-public``` - для объектов к которым нужен доступ из любой точки кластера

Для того, чтобы выбрать конкретное пространство имен, нужно указать флаг ```-n <namespace>``` или ```--namespace <namespace> ```при запуске ```kubectl```

```
❯ kubectl get all -n kubernetes-dashboard --selector k8s-app=kubernetes-dashboard
NAME                                       READY   STATUS    RESTARTS   AGE
pod/kubernetes-dashboard-79d9cd965-xz586   1/1     Running   0          18m

NAME                           TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes-dashboard   ClusterIP   10.96.31.86   <none>        80/TCP    18m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kubernetes-dashboard   1/1     1            1           18m

NAME                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/kubernetes-dashboard-79d9cd965   1         1         1       18m
```

## Dashboard ##

- Поднять дашборд:
```
❯ minikube dashboard
🔌  Enabling dashboard ...
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:59714/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```
В самом Dashboard можно:
• отслеживать состояние кластера и рабочих нагрузок в нем
• создавать новые объекты (загружать YAML-файлы)
• Удалять и изменять объекты (кол-во реплик, yaml-файлы)
• отслеживать логи в Pod-ах
• при включении Heapster-аддона смотреть нагрузку на Podах
• и т.д.

- Отделим среду для разработки приложения от всего остального кластера. Для этого создадим свой Namespace dev
dev-namespace.yml:
```
---
apiVersion: v1
kind: Namespace
metadata:
 name: dev
```
- Переподнимем приложение:
```
❯ kubectl apply -n dev -f./
deployment.apps/comment created
service/comment-db created
service/comment created
namespace/dev unchanged
deployment.apps/mongo created
service/mongodb created
deployment.apps/post created
service/post-db created
service/post created
deployment.apps/ui created
service/ui created
```
- Добавим окружение в ui-deployment.yml:
```
          env:
          - name: ENV
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
```
``` kubectl apply -f ui-deployment.yml -n dev```

- Проварка: ```kubectl apply -f ui-deployment.yml -n dev```




## Homework №19 ##

## Цели ##
- Разобрать на практике все компоненты Kubernetes, развернуть их вручную используя The Hard Way;
- Ознакомиться с описанием основных примитивов нашего приложения и его дальнейшим запуском в Kubernetes.

- Ветка kubernetes-1

## Создание примитивов ##
Опишем приложение в контексте Kubernetes с помощью manifest-ов в YAML-формате. Основным примитивом будет Deployment.
Основные задачи сущности Deployment:
- Создание Replication Controller-а (следит, чтобы число запущенных Pod-ов соответствовало описанному);
- Ведение истории версий запущенных Pod-ов (для различных стратегий деплоя, для возможностей отката);
- Описание процесса деплоя (стратегия, параметры стратегий).
По ходу курса эти манифесты будут обновляться, а также появляться новые. Текущие файлы нужны для создания структуры и проверки работоспособности kubernetes-кластера.

- Добавлены deployment-манифесты приложения reddit

- Использовать решено https://github.com/express42/kubernetes-the-hard-way/

## Диплой RedditApp ##
```
{
kubectl apply -f comment-deployment.yml
kubectl apply -f mongo-deployment.yml
kubectl apply -f post-deployment.yml
kubectl apply -f ui-deployment.yml
}
```
output:
```
deployment.apps/comment-deployment created
deployment.apps/mongo-deployment created
deployment.apps/post-deployment created
deployment.apps/ui-deployment created
```
```kubectl get pods --all-namespaces```
```
NAME                                 READY   STATUS    RESTARTS   AGE
busybox                              1/1     Running   0          13m
comment-deployment-96698b6d4-g922b   1/1     Running   0          47s
mongo-deployment-86d49445c4-qk4s4    1/1     Running   0          47s
nginx-554b9c67f9-qjhvz               1/1     Running   0          10m
post-deployment-698c97f6d4-jg629     1/1     Running   0          47s
ui-deployment-76d4cf986d-vgcdq       1/1     Running   0          46s
```



## Homework №18 ##

- Ветка logging-1

План

- Сбор неструктурированных логов
- Визуализация логов
- Сбор структурированных логов
- Распределенная трасировка

- Код микросервисов обновился для добавления функционала логирования.
- Образы пересобраны:
```
/src/ui $ bash docker_build.sh && docker push $USER_NAME/ui
/src/post-py $ bash docker_build.sh && docker push $USER_NAME/post
/src/comment $ bash docker_build.sh && docker push $USER_NAME/comment
```
- Подготовлено окружение:
```
$ export GOOGLE_PROJECT=docker-260019
$ docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-open-port 5601/tcp \
    --google-open-port 9292/tcp \
    --google-open-port 9411/tcp \
    logging

# configure local env
$ eval $(docker-machine env logging)

# узнаем IP адрес
$ docker-machine ip logging
```
## Логирование Docker контейнеров посредством Elastick Stack ##

Как упоминалось на лекции хранить все логи стоит централизованно: на одном (нескольких) серверах. В этом ДЗ мы рассмотрим пример системы централизованного логирования на примере Elastic стека (ранее известного как ELK): который включает в себя 3 осовных компонента:
- ElasticSearch (TSDB и поисковый движок для хранения данных)
- Logstash (для агрегации и трансформации данных)
- Kibana (для визуализации)
Однако для агрегации логов вместо Logstash мы будем использовать Fluentd, таким образом получая еще одно популярное сочетание этих инструментов, получившее название EFK
- Добавлен docker-compose-logging.yml:
```version: '3'
services:
  fluentd:
    image: ${USERNAME}/fluentd
    ports:
      - "24224:24224"
      - "24224:24224/udp"

  elasticsearch:
    image: elasticsearch:7.4.0
    expose:
      - 9200
    ports:
      - "9200:9200"

  kibana:
    image: kibana:7.4.0
    ports:
      - "5601:5601"
```
- Созданы правило ФВЖ:
```
gcloud compute firewall-rules create fluentd-default --allow tcp:24224
gcloud compute firewall-rules create fluentd-default --allow udp:24224
gcloud compute firewall-rules create elasticsearch-default --allow tcp:9200
gcloud compute firewall-rules create kibana-default --allow tcp:5601
```
 ## Fluentd ##
- Инструмент, который может использоваться для отправки, агрегации и преобразования лог-сообщений. Мы будем использовать Fluentd для агрегации (сбора в одной месте) и парсинга логов сервисов нашего приложения.
- Добавлен logging/fluentd/Dockerfile:
```
FROM fluent/fluentd:v0.12
RUN gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5
RUN gem install fluent-plugin-grok-parser --no-rdoc --no-ri --version 1.0.0
ADD fluent.conf /fluentd/etc
```
- Добавлен logging/fluentd/fluent.conf :
```
<source>
  @type forward         # Используем in_forward плагин для приема логов
                        # https://docs.fluentd.org/v0.12/articles/in_forward
  port 24224
  bind 0.0.0.0
</source>
<match *.**>
  @type copy            # Используем copy плагин, чтобы переправить все входящие логи в ElasticSearch, а также вывести в output
                        # https://docs.fluentd.org/v0.12/articles/out_copy
  <store>
    @type elasticsearch
    host elasticsearch
    port 9200
    logstash_format true
    logstash_prefix fluentd
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    tag_key @log_name
    flush_interval 1s
  </store>
  <store>
    @type stdout
  </store>
</match>
```
- Собран образ: ```docker build -t $USER_NAME/fluentd .```
- Логи должны иметь заданную (единую) структуру и содержать необходимую для нормальной эксплуатации данного сервиса информацию о его работе
- Лог-сообщения также должны иметь понятный для выбранной системы логирования формат, чтобы избежать ненужной траты ресурсов на преобразование данных в нужный вид. Структурированные логи мы рассмотрим на примере сервиса post

- Запущены сервисы приложения: ```docker-compose up -d```
- Просмотр логов: ```docker-compose logs -f post```
- В консоли появились логи:
```
post_1     | {"event": "post_create", "level": "info", "message": "Successfully created a new post", "params": {"link": "http://qwer2", "title": "123"}, "request_id": "7786f4ce-69b6-4dd1-8bcf-33887c4cb23e", "service": "post", "timestamp": "2019-12-30 18:22:07"}
```
Каждое событие, связанное с работой нашего приложения логируется в JSON формате и имеет нужную нам структуру:
 - тип события (event),
 - сообщение (message),
 - переданные функции параметры (params),
 - имя сервиса (service) и др.

Как отмечалось на лекции, по умолчанию Docker контейнерами используется json-file драйвер для логирования информации, которая пишется сервисом внутри контейнера в stdout (и stderr). Для отправки логов во Fluentd используем docker драйвер fluentd

- Определен драйвер логирования  для сервиса post:
```

    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.post
```
## Kibana ##
- Инструмент для визуализации и анализа логов от компании Elastic. Откроем WEB-интерфейс Kibana для просмотра собранных в
ElasticSearch логов Post-сервиса (kibana слушает на порту 5601)
- Кибана поднялась со скрипом:
```
  vm.max_map_count on the linux box kernel setting needs to be set to at least 262144 -
  $ sudo sysctl -w vm.max_map_count=262144
```
```
the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured

environment:
      - discovery.type=single-node
```
- Создан индекс

## Фильтры ##
Добавим фильтр для парсинга json логов, приходящих от post сервиса, в конфиг fluentd
```
<filter service.post>
  @type parser
  format json
  key_name log
</filter>
```
- Взглянем на одно из сообщений и увидим, что вместо одного поля log появилось множество полей с нужной нам информацией

## Неструктурированные логи ##

Неструктурированные логи отличаются отсутствием четкой структуры данных. Также часто бывает, что формат лог-сообщений не подстроен под систему централизованного логирования, что существенно увеличивает затраты вычислительных и временных ресурсов на обработку данных и выделение нужной информации. На примере сервиса ui мы рассмотрим пример логов с неудобным форматом сообщений.
docker-compose.yml:
```
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
```
Когда приложение или сервис не пишет структурированные логи, приходится использовать старые добрые регулярные выражения для их парсинга
в /docker/fluentd/fluent.conf
```
<filter service.ui>
  @type parser
  format /\[(?<time>[^\]]*)\]  (?<level>\S+) (?<user>\S+)[\W]*service=(?<service>\S+)[\W]*event=(?<event>\S+)[\W]*(?:path=(?<path>\S+)[\W]*)?request_id=(?<request_id>\S+)[\W]*(?:remote_addr=(?<remote_addr>\S+)[\W]*)?(?:method= (?<method>\S+)[\W]*)?(?:response_status=(?<response_status>\S+)[\W]*)?(?:message='(?<message>[^\']*)[\W]*)?/
  key_name log
</filter>
```
Созданные регулярки могут иметь ошибки, их сложно менять и невозможно читать. Для облегчения задачи парсинга вместо стандартных регулярок можно использовать grok-шаблоны. По-сути grok’и - это именованные шаблоны регулярных выражений (очень похоже на функции). Можно использовать готовый regexp, просто сославшись на него как на функцию docker/fluentd/fluent.conf
```
<filter service.ui>
  @type parser
  key_name log
  format grok
  grok_pattern %{RUBY_LOGGER}
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>
```

## Распределенный трейсинг. Zipkin ##

Добавьте в compose-файл для сервисов логирования сервис распределенного трейсинга Zipkin в одно сети
docker/docker-compose-logging.yml
```
  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
    networks:
      - back-net
      - front-net
```
- Правило ФВ: ```gcloud compute firewall-rules create zipkin-default --allow tcp:9411```

Правим наш docker/docker-compose-logging.yml Добавьте для каждого сервиса поддержку ENV переменных и задайте параметризованный параметр ZIPKIN_ENABLED
```
environment:
- ZIPKIN_ENABLED=${ZIPKIN_ENABLED}
```
- env. ```ZIPKIN_ENABLED=true```











## Homework #17 ##

План

- Мониторинг docker контейнеров
- Визуализация метрик
- Сбор метрик работы приложения и бизнес метрик
- Настройка и проверка алертинга
Подготовим окружение:
```
$ export GOOGLE_PROJECT=docker-260019

# Создать докер хост
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host

# Настроить докер клиент на удаленный докер демон
eval $(docker-machine env docker-host)

$ docker-machine ip docker-host

```
- Разделим docker-compose.yml на 2 части: для запуска приложения и запуска мониторинга docker-compose-monitoring.yml. Для наблюдения за контейнерами будем использовать CAdvisor https://github.com/google/cadvisor

cAdvisor собирает информацию о ресурсах потребляемых контейнерами и характеристиках их работы.
Примерами метрик являются:
- процент использования контейнером CPU и памяти, выделенные для его запуска,
- объем сетевого трафика и др.

- docker-compose-minitoring.yml:
```
  cadvisor:
    image: google/cadvisor:v0.29.0
    volumes:
      - '/:/rootfs:ro'
      - '/var/run:/var/run:rw'
      - '/sys:/sys:ro'
      - '/var/lib/docker/:/var/lib/docker:ro'
    ports:
      - '8080:8080'
    networks:
      - back-net
      - front-net

```
- prometheus.yml:
```
  - job_name: 'cadvisor'
    static_configs:
      - targets:
        - 'cadvisor:8080'
```
- Добавлено правило файрвола:
```
gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
```
- Пересобран образ prometheus:
```
$ export USER_NAME=username # где username - ваш логин на Docker Hub
$ docker build -t $USER_NAME/prometheus .
```
- Запущены сервисы:
```
$ docker-compose up -d
$ docker-compose -f docker-compose-monitoring.yml up -d
```
- cAdvisor имеет UI, в котором отображается собираемая о контейнерах информация.
Откроем страницу Web UI по адресу http://<docker-machinehost-ip>:8080

- Добавлена и запущена grafana:
```
  grafana:
    image: grafana/grafana:5.0.0
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    networks:
      front-net:
volumes:
  grafana_data:
```
- ```docker-compose -f docker-compose-monitoring.yml up -d grafana``` - Запущена графана
- Добавлено правило файрвола для графаны:
```
gcloud compute firewall-rules create grafana-default --allow tcp:3000
```
- Добавлен Data Source Prometheus
- С сайта графаны загружен дашборд для мониторинга docker контейнеров DockerMonitoring.json
- Для мониторинга работы приложения создан дашборд с 2-мя графиками. Созданные метрики придадут видимости работы нашего приложения и понимания, в каком состоянии оно сейчас находится. Например, время обработки HTTP запроса не должно быть большим, поскольку это означает, что пользователю приходится долго ждать между запросами, и это ухудшает его общее впечатление от работы с приложением. Поэтому большое время обработки запроса будет для нас сигналом проблемы. Отслеживая приходящие HTTP-запросы, мы можем, например, посмотреть, какое количество ответов возвращается с кодом ошибки. Большое количество таких ответов также будет служить для нас сигналом проблемы в работе приложения.
- В promrtheus.yml добавлен:
```
scrape_configs:
...
- job_name: 'post'
static_configs:
- targets:
- 'post:5000'
```
- График изменения счетчика HTTP-запросов по времени ```ui_request_count```
- График запросов, которые возвращают код ошибки на этом же дашборде. В поле запросов запишем выражение для поиска всех http
запросов, у которых код возврата начинается либо с 4 либо с 5(используем регулярное выражения для поиска по лейблу). Будем
использовать функцию rate(), чтобы посмотреть не просто значение счетчика за весь период наблюдения, но и скорость увеличения
данной величины за промежуток времени (возьмем, к примеру 1-минутный интервал, чтобы график был хорошо видим)
```rate(ui_request_count{http_status=~"^[45].*"}[1m])```
- Для первого графика добавлен интересные счетчики:
```rate(ui_request_count{http_status=~"^[200].*"}[1m])```
```rate(ui_request_count{job="ui"}[1m])```
- Для гистограммы использована метрика ```ui_request_latency_seconds_bucket{path="/"}```
- Процентиль - Числовое значение в наборе значений
  - Все числа в наборе меньше процентиля, попадают в границы заданного процента значений от всего числа значений в наборе
  - Часто для анализа данных мониторинга применяются значения 90, 95 или 99-й процентиля.
  - Мы вычислим 95-й процентиль для выборки времени обработки запросов, чтобы посмотреть какое значение является максимальной границей для большинства (95%) запросов. Для этого воспользуемся встроенной функцией ```histogram_quantile()```
  - Выглядит так ```histogram_quantile(0.95, sum(rate(ui_request_response_time_bucket[5m])) by (le))```

## Мониторинг бизнес-логики ##
- Добавлены счетчики количества постов и комментариев ```post_count```и ```comment_count```
Мы построим график скорости роста значения счетчика за последний час, используя функцию rate(). Это позволит нам получать информацию об активности пользователей приложения.
- Новый дашборд Business_Logic_Monitoring - метрики: ```rate(post_count[1h])``` и ```rate(comment_count[1h])```

## Алертинг ##

- Мы определим несколько правил, в которых зададим условия состояний наблюдаемых систем, при которых мы должны получать оповещения, т.к. заданные условия могут привести к недоступности или неправильной работе нашего приложения.

- Alertmanager - дополнительный компонент для системы мониторинга Prometheus, который отвечает за первичную обработку алертов и дальнейшую отправку оповещений по заданному назначению.

- Добавлен Dockerfile:
```
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/
```
- Добавим интеграцию со слаком в config.yml:
```
global:
  slack_api_url: 'https://hooks.slack.com/services/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'

route:
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#evgeniy-sobolev'
```
- Собран образ:```docker build -t $USER_NAME/alertmanager .```
- Обновлен docker-compose-monitoring.yml:
```
alertmanager:
  image: ${USERNAME}/alertmanager
  command:
    - '--config.file=/etc/alertmanager/config.yml'
  ports:
    - '9093:9093'
  networks:
    - front-net
    - back-net
```
- Создано правило ФВ:
```
gcloud compute firewall-rules create alrtmngr-default --allow tcp:9093
```
- Добавлен alerts.yml, в котором определим условия при которых должен срабатывать алерт и посылаться Alertmanager-у. Мы создадим простой алерт, который будет срабатывать в ситуации, когда одна из наблюдаемых систем (endpoint) недоступна для сбора метрик (в этом случае метрика up с лейблом instance равным имени данного эндпоинта будет равна нулю). Выполните запрос по имени метрики up в веб интерфейсе Prometheus, чтобы убедиться, что сейчас все эндпоинты доступны для сбора метрик::
```
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```
- Изменен prometheus/Dockerfile:
``` ADD alerts.yml /etc/prometheus/ ```
- Изменен prometheus/prometheus.yml:
```
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"
```
- ```docker-compose stop post``` Срабатывает алерт, пришло в слак сообщение
- Все запушено:
```
docker push $USER_NAME/ui
docker push $USER_NAME/comment
docker push $USER_NAME/post
docker push $USER_NAME/prometheus
docker push $USER_NAME/alertmanager
docker push $USER_NAME/alertmanager
```




## Выполнено задание №16 ##
##   Prometheus  ##

- Ветка monitoring-1
План:
• Prometheus: запуск, конфигурация, знакомство с
Web UI
• Мониторинг состояния микросервисов
• Сбор метрик хоста с использованием экспортера

- Созданы правила файрвола:
``` $ gcloud compute firewall-rules create prometheus-default --allow tcp:9090``` - прометеус
``` $ gcloud compute firewall-rules create puma-default --allow tcp:9292``` - puma

- Create docker-host:
```
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host
```
- Connect to docker-host:
```
eval $(docker-machine env docker-host)
```
- Run Prometheus docker image:
```
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
```
- Discover ip address: ``` docker-machine ip docker-host```
- UI become available on ``` http://35.189.233.221:9090/graph```
Clean Prometheus is already collecting some metrics of its condition.
For example:
```
## Consists of metric name and labels that represented as key/value sets
✔prometheus_build_info{
  branch="HEAD",
  goversion="go1.9.2",
  instance="localhost:9090",
  job="prometheus",
  revision="85f23d82a045d103ea7f3c89a91fba4a93e6367a",
  version="2.1.0"}
```
- Targets - systems or processes for Prometheus to monitor. That pulls http-requests on endpoints he has.

- Dir structure  had some changes w/ creating docker folder. Files from previous docker-homeworks moved there. Monitoring folder created
- Has been built an image for monitoring redditapp microservices
- Dockerfile added:
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```
- prometheus.yml added
```
---
global:
  scrape_interval: '5s'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets:
        - 'localhost:9090'

  - job_name: 'ui'
    static_configs:
      - targets:
        - 'ui:9292'

  - job_name: 'comment'
    static_configs:
      - targets:
        - 'comment:9292'
```
- Building up an image:
- ``` export USER_NAME=eugenesable ``` from docker-hub
- ``` docker build -t $USER_NAME/prometheus . ```
- Each project built with docker_build.sh from its own folder
```
/src/ui $ bash docker_build.sh
/src/post-py $ bash docker_build.sh
/src/comment $ bash docker_build.sh
```
- Prometheus added as a service in docker-compose:
```
services:
...
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'  ## config file path of container
      - '--storage.tsdb.path=/prometheus' ## storage path in container
      - '--storage.tsdb.retention=1d' ## keep metrics for 1 day

volumes:
  prometheus_data:
```
- Run docker-compose.yml:
```
❯ docker-compose up -d
Creating some_project_post_db_1    ... done
Creating some_project_comment_1    ... done
Creating some_project_post_1       ... done
Creating some_project_prometheus_1 ... done
Creating some_project_ui_1         ... done
```
- Made some manipulations with stopint services  and watching out the behavior through graphs

## Exporters. Node exporter  ##

- NodeExporter added as a service to docker-compose.yml:
```
  node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - back-net
      - front-net
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'

```
- New service added to prometheus.yml:
```
- job_name: 'node'
  static_configs:
    - targets:
      - 'node-exporter:9100'
```
- New images pushed to Docker Hub:
```
docker login
docker push $USER_NAME/ui
docker push $USER_NAME/post
docker push $USER_NAME/comment
docker push $USER_NAME/prometheus
```
## Editional task* ##

- Mongodb exporter docker image - https://github.com/bitnami/bitnami-docker-mongodb-exporter
- prometheus.yml:
```
  - job_name: 'mongodb-exporter'
    static_configs:
      - targets:
        - 'mongodb-exporter:9216'
```
- docker-compose.yml:
```
  mongodb_exporter:
    image: bitnami/mongodb-exporter
    networks:
      - back-net
      - front-net
    environment:
      MONGODB_URI: 'mongodb://post_db:27017'
```







## Выполнено задание №15 ##
##  GITLAB  ##

- Ветка gitlab-ci-1
- Создан packer-образ, удовлетвояющий условиям гитлаба
```
packer build -var 'project_id=docker-260019' \
                -var 'source_image_family=ubuntu-1604-lts' \
                -var 'machine_type=n1-standard-1' \
                -var 'disk_size=100' docker.json
```
- В образе провиженер, который ссылается на ansible-роль, как и в одном прошлых ДЗ.
- Добавлена роль, поднимающая в образе docker-compose:
```
---
- name: Add Docker GPG apt Key
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present
- name: Add Docker Repository
  apt_repository:
    repo: deb https://download.docker.com/linux/ubuntu xenial stable
    state: present
- name: Update apt and install docker-ce
  apt: update_cache=yes name=docker-ce state=latest
- name: Install Docker-ce
  apt:
    name: docker-ce
- name: Install Docker-compose
  apt:
    name: docker-compose
```
- Терраформом поднят stage на основе нового образа
- Добавлена роль gitlab-compose, которая поднимает gitlab-omnibus
```
    - name: Install python for Ansible
      raw: test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)
      changed_when: False

    - name: create gitlab directories
      file:
        path: "{{ item }}"
        state: directory
        owner: root
        group: root
        mode: 0775
      with_items:
        - /srv/gitlab/config
        - /srv/gitlab/data
        - /srv/gitlab/logs

    - name: push template
      template:
        src: templates/docker-compose.yml.j2
        dest: /srv/gitlab

    - name: j2 to yml
      command: mv /srv/gitlab/docker-compose.yml.j2 /srv/gitlab/docker-compose.yml

    - name: Run docker-compose
      docker_compose:
        project_src: /srv/gitlab
```
+ template/docker-compose.yml.j2
```
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://{{ ansible_host }}'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'

```
- Gitlab поднялся, указан пароль для административного аккаунта (root)
- Выключена регистрацию новых пользователей

  ### Первый проект ###
  • Каждый проект в Gitlab CI принадлежит к группе проектов

  • В проекте может быть определен CI/CD пайплайн

  • Задачи (jobs) входящие в пайплайн должны исполняться на runners

- Создана группа и проект
Добавляем remote в eugenesable_microservices
```git checkout -b gitlab-ci-1```
```git remote add gitlab http://34.76.66.215/homework/example.git```
```git push gitlab gitlab-ci-1```

### CI/CD Pipeline ###
 - В репозиторий добавлен файл .gitlab-ci.yml
 ```
 stages:
  - build
  - test
  - deploy

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  script:
    - echo 'Testing 1'

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
 ```

- В разделе CI/CD появился pipeline в статусе pending / stuck так как нет runner'а

- На сервере запущен runner NWJxhnTLsahY18yhuWhT
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```
- Зарегистрирован
``` docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false```
```
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
Runtime platform                                    arch=amd64 os=linux pid=12 revision=577f813d version=12.5.0
Running in system-mode.

Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/):
http://34.76.66.215/
Please enter the gitlab-ci token for this runner:
NWJxhnTLsahY18yhuWhT
Please enter the gitlab-ci description for this runner:
[e41a10d56db3]: my-runner
Please enter the gitlab-ci tags for this runner (comma separated):
linux,xenial,ubuntu,docker
Registering runner... succeeded                     runner=NWJxhnTL
Please enter the executor: virtualbox, kubernetes, custom, docker, parallels, ssh, docker-ssh, shell, docker+machine, docker-ssh+machine:
docker
Please enter the default Docker image (e.g. ruby:2.6):
alpine:latest
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```
- В настройках появился новый runner, pipeline запустился

### reddit в pipeline ###
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m "Add reddit app"
git push gitlab gitlab-ci-1
```
- Изменено описание pipelin'а .gitlab-ci.yml:
```
image: ruby:2.4.2

stages:
  - build
  - test
  - deploy

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_job:
  stage: deploy
  script:
    - echo 'Deploy'
```
- Добавлен simpletest.rb - вызов теста
```
require_relative './app'
require 'test/unit'
require 'rack/test'
set :environment, :test
class MyAppTest < Test::Unit::TestCase
 include Rack::Test::Methods
 def app
 Sinatra::Application
 end
 def test_get_request
 get '/'
 assert last_response.ok?
 end
end
```
- В Gemfile добавлен gem 'rack-test' - библиотека для тестирования

### Окружения ###
### DEV ###

- Изменен .gitlab-ci.yml
  - deploy -> review
  - deploy_job -> deploy_dev_job
  - Добавлено
  ```
  environment:
    name: dev
    url: http://dev.example.com
  ```
```
image: ruby:2.4.2

stages:
  - build
  - test
  - review

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com
```
- http://34.76.66.215/homework/example/environments - появилось окружение dev

### PROD & STAGE ###

- Добавлена директива ```when: manual``` - окружения будут стартовать руками из админки.
```
image: ruby:2.4.2

stages:
  - build
  - test
  - review
  - stage
  - production

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
  - cd reddit
  - bundle install

build_job:
  stage: build
  script:
    - echo 'Building'

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com

staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
```
- http://34.76.66.215/homework/example/environments - Добавились окружения prod и stage

- Добавлена в описание pipeline директиву ``` only ```, которая не позволит нам выкатить на staging и production код,
не помеченный с помощью тэга в git:
```
only:
- /^\d+\.\d+\.\d+/
```
- Добавили tag  tag 2.4.10 ```git tag 2.4.10```
- В результате пуша запустился только DEV

### Динамические окружения ###

- Gitlab CI позволяет определить динамические окружения, это мощная функциональность позволяет вам иметь выделенный стенд для, например, каждой feature-ветки в git. Теперь, на каждую ветку в git отличную от master Gitlab CI будет определять новое окружение.
```
 stage: review
 script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
 environment:
 name: branch/$CI_COMMIT_REF_NAME
 url: http://$CI_ENVIRONMENT_SLUG.example.com
 only:
 - branches
 except:
 - master
```
- Задание со * не пошло. Добиться регистри не вышло. Не получилось настроить встроенный Лецинкрипт ```SSL certificate problem: Invalid certificate chain``` из-за этого перестал работать пуш, не решались раннеры, думал, что можно реализовать способом в пайплане ниже:

```
image: ruby:2.4.2

stages:
  - build
  - test
  - review
  - stage
  - production

variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

before_script:
  - cd reddit
  - bundle install

build_job:

  before_script:
    - echo 'Before script override for build_job'

  stage: build

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_TLS_CERTDIR: ""

  services:
      - docker:18.09-dind
  script:
    - curl -sSL https://get.docker.com/ | sh
    - docker info
    - docker login -u $docker_hub_user -p $docker_hub_password
    - docker run --name reddit -d -p 9292:9292 eugenesable/otus-reddit:1.0

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  script:
    - echo 'Deploy'
  environment:
    name: dev
    url: http://dev.example.com

branch review:
  stage: review
  script:
    - echo $CI_ENVIRONMENT_SLUG
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.34.77.27.230.sslip.io
  only:
    - branches
  except:
    - master

staging:
  stage: stage
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com
 ```


## Выполнено задание №14 ##

- Ветка docker-4

### Работа с сетью ###
• none
• host
• bridge
- В качестве образа используем joffotron/docker-net-tools:
Запущен  none network driver
```docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig```
```
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
- В результате, видим:
• что внутри контейнера из сетевых интерфейсов существует только loopback.
• сетевой стек самого контейнера работает (ping localhost), но без возможности контактировать с внешним миром.
• Значит, можно даже запускать сетевые сервисы внутри такого контейнера, но лишь для локальных экспериментов (тестирование, контейнеры для выполнения разовых задач и т.д.)

- Запустим контейнер в сетевом пространстве docker-хоста
```docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig```
вывод такой же как и у ```docker-machine ssh docker-host ifconfig```
```
br-3fabcbfeff5d Link encap:Ethernet  HWaddr 02:42:67:28:11:9E
          inet addr:172.20.0.1  Bcast:172.20.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:67ff:fe28:119e%32741/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:1076 (1.0 KiB)

br-7a4a39840e4a Link encap:Ethernet  HWaddr 02:42:9C:51:EF:D5
          inet addr:172.19.0.1  Bcast:172.19.255.255  Mask:255.255.0.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

br-a9b719f3a1b0 Link encap:Ethernet  HWaddr 02:42:EB:59:0F:9F
          inet addr:172.18.0.1  Bcast:172.18.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:ebff:fe59:f9f%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:3968231 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3968449 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:302071587 (288.0 MiB)  TX bytes:701874385 (669.3 MiB)

docker0   Link encap:Ethernet  HWaddr 02:42:CA:DF:D6:99
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:caff:fedf:d699%32741/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:38051 errors:0 dropped:0 overruns:0 frame:0
          TX packets:51249 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:3333985 (3.1 MiB)  TX bytes:1322917475 (1.2 GiB)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:08
          inet addr:10.132.0.8  Bcast:10.132.0.8  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:8%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:4284958 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4198887 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3660585041 (3.4 GiB)  TX bytes:382770929 (365.0 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32741/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:500658 errors:0 dropped:0 overruns:0 frame:0
          TX packets:500658 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:67899853 (64.7 MiB)  TX bytes:67899853 (64.7 MiB)

veth6f7e622 Link encap:Ethernet  HWaddr 0A:5B:AE:27:32:78
          inet6 addr: fe80::85b:aeff:fe27:3278%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:214420 errors:0 dropped:0 overruns:0 frame:0
          TX packets:153348 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:24744112 (23.5 MiB)  TX bytes:17795232 (16.9 MiB)

veth8f35cc4 Link encap:Ethernet  HWaddr 1A:BB:10:37:02:FB
          inet6 addr: fe80::18bb:10ff:fe37:2fb%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:321951 errors:0 dropped:0 overruns:0 frame:0
          TX packets:276068 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:34535781 (32.9 MiB)  TX bytes:39449121 (37.6 MiB)

vethade5a64 Link encap:Ethernet  HWaddr DE:95:AF:4F:0D:24
          inet6 addr: fe80::dc95:afff:fe4f:d24%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:688571 errors:0 dropped:0 overruns:0 frame:0
          TX packets:501992 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:75588512 (72.0 MiB)  TX bytes:77316048 (73.7 MiB)

vethb5ba98b Link encap:Ethernet  HWaddr F2:E0:87:20:7F:66
          inet6 addr: fe80::f0e0:87ff:fe20:7f66%32741/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:563640 errors:0 dropped:0 overruns:0 frame:0
          TX packets:857441 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:92064866 (87.7 MiB)  TX bytes:92382542 (88.1 MiB)
```
- При многократном запуске контенера с нгингсом ```docker run --network host -d nginx``` запускается только один, исходя из лога 80 порт уже занят:
```
docker logs a341992d21d7
2019/12/02 18:56:20 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
```
### Docker networks ###

- ```sudo ln -s /var/run/docker/netns /var/run/netns``` - создан симлинк к сетеым namespace
- Запущены контейнеры с none и host:
  - При none появляется неймспейс, но выполнение команды возвращает ошибку, видимо потому что сеть изолирована
```
sudo docker run --network none -d joffotron/docker-net-tools
086a872fb88a13e9a62a4e2a54a9d14cf467ebeb6b223b4dd0450d44fb7b4306
$ sudo ip netns
RTNETLINK answers: Invalid argument
RTNETLINK answers: Invalid argument
RTNETLINK answers: Invalid argument
netns
RTNETLINK answers: Invalid argument
dc2b3cd7a87f
default

sudo ip netns exec dc2b3cd7a87f hostnamectl
RTNETLINK answers: Invalid argument
Cannot open network namespace "dc2b3cd7a87f": No such file or directory
```
  - При host появляется только default namespace, который наследуется от хостовой машины, команда выполняется
```
sudo docker run --network host -d joffotron/docker-net-tools
2bec4d045b8da28da97167e7686a7e020186bdfc2f8596b9d9c4543aec295087
docker-user@docker-host:~$ sudo ip netns
RTNETLINK answers: Invalid argument
RTNETLINK answers: Invalid argument
netns
default

sudo ip netns exec default hostnamectl
RTNETLINK answers: Invalid argument
   Static hostname: docker-host
         Icon name: computer-vm
           Chassis: vm
        Machine ID: d13a1a7fc285079bc2e571b44c1f02da
           Boot ID: 63f617d74b334dd4a7cf2bdad891ca09
    Virtualization: kvm
  Operating System: Ubuntu 16.04.6 LTS
            Kernel: Linux 4.15.0-1049-gcp
      Architecture: x86-64

```

### Bridge network driver ###

- Создана bridge-сеть:``` docker network create reddit-bridge --driver bridge ```
- Поднято прилажение:
```
docker run -d --network=reddit-bridge mongo:latest
docker run -d --network=reddit-bridge eugenesable/post:1.0
docker run -d --network=reddit-bridge eugenesable/comment:1.0
docker run -d --network=reddit-bridge -p 9292:9292 eugenesable/ui:1.0
```
- Без сетевых алиасов не завелось
- Прилажение поднято в 2-х сетях front и back, чтобы сервис ui не имел доступа к базе данных:
```
 docker network create back_net --subnet=10.0.2.0/24
 docker network create front_net --subnet=10.0.1.0/24
```
```
docker run -d --network=front_net -p 9292:9292 --name ui eugenesable/ui:1.0
docker run -d --network=back_net --name comment eugenesable/comment:1.0
docker run -d --network=back_net --name post eugenesable/post:1.0
docker run -d --network=back_net --name mongo_db  --network-alias=post_db --network-alias=comment_db mongo:latest
```
- Контейнеры post и comment нужно поместить в обе сети, так как сети изолированы
Дополнительные сети подключаются командой:

``` docker network connect <network> <container>```
- Посмотрим сетевой стек на docker-host:
- Установлен bridge-utils
``` docker network ls``` - список сетей:
```
sudo  docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
ee07c276cec1        back_net            bridge              local
c3c3f6cef9f2        bridge              bridge              local
7b6e1019f3ce        front_net           bridge              local
df47573911a6        host                host                local
08225cf566c1        none                null                local
a9b719f3a1b0        reddit              bridge              local
7d9f880bf64b        reddit-bridge       bridge              local
3fabcbfeff5d        reddit_new          bridge              local
```
- Нашли все бриджы ```ifconfig | grep br ```:
```
ifconfig | grep br
br-3fabcbfeff5d Link encap:Ethernet  HWaddr 02:42:67:28:11:9e
br-7b6e1019f3ce Link encap:Ethernet  HWaddr 02:42:50:e4:c7:0d
br-7d9f880bf64b Link encap:Ethernet  HWaddr 02:42:1e:a9:9e:8f
br-a9b719f3a1b0 Link encap:Ethernet  HWaddr 02:42:eb:59:0f:9f
br-ee07c276cec1 Link encap:Ethernet  HWaddr 02:42:ff:b0:1e:2e
```
- Отображаемые veth-интерфейсы - это те части виртуальных пар интерфейсов, которые лежат в сетевом пространстве хоста и также отображаются в ifconfig. Вторые их части лежат внутри контейнеров.
```
brctl show br-7b6e1019f3ce
bridge name             bridge id               STP enabled     interfaces
br-7b6e1019f3ce         8000.024250e4c70d       no              veth7a4d521
                                                                vethc1e85eb
                                                                vethe4483f4
```
- iptables:
- POSTROUTING. Отмеченные звездочкой правила отвечают за выпуск во внешнюю сеть контейнеров из bridge-сетей.
```
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0
MASQUERADE  all  --  172.21.0.0/16        0.0.0.0/0
MASQUERADE  all  --  172.20.0.0/16        0.0.0.0/0
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
MASQUERADE  tcp  --  10.0.1.2             10.0.1.2             tcp dpt:9292
```
- DOCKER.Перенаправление трафика на адреса уже конкретных контейнеров.
```
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292
```
- Процесс docker-proxy, который слушает на порту 9292
```
$ ps ax | grep docker-proxy
 6359 pts/0    S+     0:00 grep --color=auto docker-proxy
31989 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
```
### Docker-compose ###

• Декларативное описание docker-инфраструктуры в YAML-формате
• Управление многоконтейнерными приложениями

Добавлен docker-compose.yml  c reddit:
```
version: '3.3'
services:
  post_db:
    image: mongo:3.2
    volumes:
      - post_db:/data/db
    networks:
      - reddit
  ui:
    build: ./ui
    image: ${USERNAME}/ui:1.0
    ports:
      - 9292:9292/tcp
    networks:
      - reddit
  post:
    build: ./post-py
    image: ${USERNAME}/post:1.0
    networks:
      - reddit
  comment:
    build: ./comment
    image: ${USERNAME}/comment:1.0
    networks:
      - reddit

volumes:
  post_db:

networks:
  reddit:
```
- docker-compose умеет интерполяцию - экспортирована переменную USERNAME:``` export USERNAME=eugenesable ```
- Запущен проект ``` docker-compose up -d ```
- Результат:
```
$ docker-compose ps
    Name                  Command             State           Ports
----------------------------------------------------------------------------
src_comment_1   puma                          Up
src_post_1      python3 post_app.py           Up
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```
### Задание ###
- Добавлены сети и параметризирован:
```

version: '3.3'
services:
  post_db:
    image: mongo:${MONGO_V}
    volumes:
      - post_db:/data/db
    networks:
      back-net:
        aliases:
          - post_db
          - comment_db

  ui:
    build: ./ui
    image: ${USERNAME}/ui:${UI_V}
    ports:
      - ${UI_PORT}:${APP_PORT}/tcp
    networks:
      front-net:
        aliases:
          - ui

  post:
    build: ./post-py
    image: ${USERNAME}/post:${POST_V}
    networks:
      back-net:
        aliases:
          - post
      front-net:
        aliases:
          - post

  comment:
    build: ./comment
    image: ${USERNAME}/comment:${COMMENT_V}
    networks:
       back-net:
        aliases:
          - comment
       front-net:
        aliases:
          - comment

volumes:
  post_db:

networks:
  back-net:
  front-net:
```
- .env:
```
COMPOSE_PROJECT_NAME=some_project
MONGO_V=3.2
USERNAME=eugenesable
UI_V=1.0
UI_PORT=9292
APP_PORT=9292
POST_V=1.0
COMMENT_V=1.0
```
- Имя проекта можно задать с помощью переменной COMPOSE_PROJECT_NAME в .env

### Со* ###

- Изменять код каждого из приложений, не выполняя сборку образа можно вытащив код наружу в volum'ы + puma debug:
```
version: '3.3'

services:
  ui:
    volumes:
      - ui:/app
    command: puma --debug -w 2

  comment:
    volumes:
      - comment:/app

  post:
    volumes:
      - post-py:/app

volumes:
  ui:
  comment:
  post-py:

```




## Выполнено задание №13 ##

- Ветка docker-3
- Приложение разделено на 3 компонента. Добавлена папка src/:
  - post-py - посты
  - comment - комментарии
  - ui - веб-интерфейс
- В каждый сервис добавлены Dockerfil'ы:
  - post-py/Dockerfile: (пришлось внести изменеия)
```
FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN pip install -r /app/requirements.txt

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
```
  - comment/Dockerfile:
```
FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
```
  - ui/Dockerfile
```
FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
```
- Создана специальная bridge-сеть для прилажения:
``` docker network create reddit ```
- Запущены контейнеры:
```
docker run -d --network=reddit \
--network-alias=post_db --network-alias=comment_db mongo:latest

docker run -d --network=reddit \
--network-alias=post <your-dockerhub-login>/post:1.0

docker run -d --network=reddit \
--network-alias=comment <your-dockerhub-login>/comment:1.0

docker run -d --network=reddit \
-p 9292:9292 <your-dockerhub-login>/ui:1.0
```
- Оптимизировать образы можно записав устновку в один слой:
```
RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
&& pip install cython thriftpy2 \
&& pip install --upgrade pip \
&& pip install -r /app/requirements.txt
```
- Тк же можно использовать alpine-образы

- Устновка через переменную --env
```
docker run -d --network=reddit_new --network-alias=posts_db_new --network-alias=comment_db_new mongo:latest

docker run -d --network=reddit --network-alias=post_new --env POST_DATABASE_HOST=posts_db_new eugenesable/post:2.0

docker run -d --network=reddit --network-alias=comment_new --env COMMENT_DATABASE_HOST=comment_db_new eugenesable/comment:2.0

docker run -d --network=reddit --env POST_SERVICE_HOST=post_new --env COMMENT_SERVICE_HOST=comment_new -p 9292:9292 eugenesable/ui:2.0
```
- Создание вольюма для хранения данных контенера:
 ```docker volume create reddit_db```



Предварительно склонирован репозиторий ```https://github.com/Otus-DevOps-2019-08/eugenesable_microservices``` для выполнения заданий.
Настроена отправка сообщений в канал slack по аналогии с предыдущим репозиторием.
Настроено взаимодействие с travis-ci.

## Выполнено задание №12 ##

- Ветка docker-2
- Установлен докер для макоси
```docker version``` – версии docker client и server
```docker info``` – информация о текущем состоянии docker daemon
```docker run hello-world ``` - запуск конейнера из image hello-world
Вывод консоли:
```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete
Digest: sha256:4df8ca8a7e309c256d60d7971ea14c27672fc0d10c5f303856d7bc48f8cc17ff
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```
```docker ps``` - список запущенных контейнеров
```docker ps -a``` - cписок всех контейнеров
```docker images``` - список образов
- Docker run каждый раз запускает новый контейнер
``` docker start <u_container_id>``` - запускает остановленный(уже созданный) контейнер
``` docker attach <u_container_id>``` - подсоединяет терминал к созданному контейнеру
- docker run = docker create + docker start +
docker attach*
- docker create используется, когда не нужно
стартовать контейнер сразу
- в большинстве случаев используется docker run
- Через параметры передаются лимиты(cpu/mem/disk), ip,
volumes
- -i – запускает контейнер в foreground режиме (docker attach)
- -d – запускает контейнер в background режиме
- -t создает TTY
```docker exec -it <u_container_id> bash``` - запускает новый процесс внутри контейнера, в данном случае bash
- Выаод docker images сохранен в docker-monolith/doker-1.log:
```
REPOSITORY                    TAG                 IMAGE ID            CREATED              SIZE
eugenesable/ubuntu-tmp-file   latest              e17220417e94        About a minute ago   123MB
ubuntu                        16.04               5f2bf26e3524        3 weeks ago          123MB
```
- Основное различие между образом и контейнером — в доступном для записи верхнем слое. Из вывода docker inspect это можно увидеть так:
В описании контенера присутствует параметр "ReadonlyRootfs": false

- Docker kill & stop:
• kill сразу посылает SIGKILL
• stop посылает SIGTERM, и через 10 секунд(настраивается) посылает SIGKILL
```
docker ps -q
7f8b32a9eac2
```
```
docker kill $(docker ps -q)
7f8b32a9eac2
```

- docker system df
• Отображает сколько дискового пространства занято образами, контейнерами и volume’ами
• Отображает сколько из них не используется и возможно удалить

```
docker system df
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              2                   1                   122.6MB             122.6MB (100%)
Containers          2                   0                   37B                 37B (100%)
Local Volumes       0                   0                   0B                  0B
Build Cache         0                   0                   0B                  0B
```

- Docker rm & rmi
• rm удаляет контейнер, можно добавить флаг -f, чтобы удалялся работающий container(будет послан sigkill)
• rmi удаляет image, если от него не зависят запущенные контейнеры

- docker rm $(docker ps -a -q) - удалит все незапущенные контейнеры
```
docker rm $(docker ps -a -q)
7f8b32a9eac2
48a40ca154e3
```
```
docker rmi $(docker images -q)
Untagged: eugenesable/ubuntu-tmp-file:latest
Deleted: sha256:e17220417e94da9e82493c327e03f2f02468384283662986f9e3faffa018070c
Deleted: sha256:a9cab9fb64b3318755fa90abfeb1f3be27367fb4185750c8b4e9e1848fe5c816
Untagged: ubuntu:16.04
Untagged: ubuntu@sha256:bb5b48c7750a6a8775c74bcb601f7e5399135d0a06de004d000e05fd25c1a71c
Deleted: sha256:5f2bf26e35249d8b47f002045c57b2ea9d8ba68704f45f3c209182a7a2a9ece5
Deleted: sha256:0ede31ddf30de46bceba5710ea3003a7c422fc518aa7e2fbdfda212b68a7e028
Deleted: sha256:1d7d6a85a6e52d5c6970517e1dbb83bf5cd40fa20fff510586110ace29de4de8
Deleted: sha256:c4ab874de3a30c67f9c36b38e78f2a990ec151deb2d2a888700fc13704d1fd9c
Deleted: sha256:788b17b748c23d38ec62e913e87b084b7e3efda49843b3c0809b1857559b553e
```

## DOCKER. GCE ##

- Создан, инициализирован и авторизован новый проект docker в GCP
- В результате получен файл с аутентификационными данными:
```Credentials saved to file: [/Users/eugene.sable/.config/gcloud/application_default_credentials.json]``` Он будет использоваться docker-machine для
работы с облаком.

- Docker machine
```
docker-machine -v
docker-machine version 0.16.2, build bd45ab13
```
• docker-machine - встроенный в докер инструмент для создания хостов и установки на них docker engine. Имеет поддержку облаков и систем виртуализации (Virtualbox, GCP и др.)
• Команда создания - ```docker-machine create <имя>```
``` eval $(docker-machine env <имя>``` - переключение между DM, которых может быть много
``` eval $(docker-machine env --unset``` - перенключение на локальный докер
```  docker-machine rm <имя>``` - удаление
• docker-machine создает хост для докер демона со указываемым образом в -google-machine-image. Образы, которые используются для построения докер контейнеров к этому никак не относятся.
• Все докер команды, которые запускаются в той же консоли после
```eval $(docker-machine env <имя>)``` работают с удаленным докер демоном в GCP.

```export GOOGLE_PROJECT=docker-260019```
```
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host
 ```
• ```docker-machine ls``` - список docker-хостов
```
docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER     ERRORS
docker-host   -        google   Running   tcp://34.77.112.197:2376           v19.03.5
```
• переключиличь из локального докера в созданную:```eval $(docker-machine env docker-host)```
```docker run --rm -ti tehbilly/htop``` - один процесс htop, запущенный в контейнере

```docker run --rm --pid host -ti tehbilly/htop``` - все процессы хоста

## Reddit ##
- В docker-monolth/ добавлены mongod.conf, start.sh, db_config, Dockerfile
Dockerfile:
```
# Берем дистрибутив убунту
FROM ubuntu:16.04

# Обновим кеш репозитория и установим нужные пакеты
RUN apt-get update
RUN apt-get install -y mongodb-server ruby-full ruby-dev build-essential git
RUN gem install bundler
# Скачиваем приложение в контейнер
RUN git clone -b monolith https://github.com/express42/reddit.git

# Копируем конфиги в контейнер
COPY mongod.conf /etc/mongod.conf
COPY db_config /reddit/db_config
COPY start.sh /start.sh

# Устанавливаем зависимости приложения
RUN cd /reddit && bundle install
RUN chmod 0777 /start.sh

# Старт сервиса при старте конта
CMD ["/start.sh"]
```

```docker build -t reddit:latest .``` - собран образ
• Флаг -t задает тег для собранного образа
- Итоговые образы (в том числе промежуточные)
```
$ docker images -a
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
reddit              latest              0ac5a33b00a1        35 seconds ago       692MB
<none>              <none>              273e1a7fafdc        35 seconds ago       692MB
<none>              <none>              782a616decbc        36 seconds ago       692MB
<none>              <none>              356ff82fdbf8        49 seconds ago       647MB
<none>              <none>              55e220966494        49 seconds ago       647MB
<none>              <none>              8c49c3bf177c        49 seconds ago       647MB
<none>              <none>              a2b53720d286        50 seconds ago       647MB
<none>              <none>              65c44de34770        52 seconds ago       647MB
<none>              <none>              8c23410e6050        About a minute ago   644MB
<none>              <none>              4c7de353d94b        2 minutes ago        148MB
ubuntu              16.04               5f2bf26e3524        3 weeks ago          123MB
tehbilly/htop       latest              4acd2b4de755        20 months ago        6.91MB
```
- Собран контейнер:
```
$  docker run --name reddit -d --network=host reddit:latest
daa395b33172df72031cfee8f8809bb02ea9a1c6c29eeaedaedf4990edbf445d
```
- Результат:
```
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER     ERRORS
docker-host   *        google   Running   tcp://34.77.112.197:2376           v19.03.5
```
- Создано FW правило, разрешающее tcp-трафик по потру 9292:
```
$ gcloud compute firewall-rules create reddit-app \
 --allow tcp:9292 \
 --target-tags=docker-machine \
 --description="Allow PUMA connections" \
 --direction=INGRESS
 ```
 - Приложение завелось: http://34.77.112.197:9292/

 ## Docker hub ###

Docker Hub - это облачный registry сервис от компании Docker. В него можно выгружать и
загружать из него докер образы. Docker по умолчанию скачивает образы из докер хаба.

```docker login``` - авторизация в docker hub

- Загрузка eddit на докер хаб:
• ```docker tag reddit:latest eugenesable/otus-reddit:1.0``` - добавлен тэг
• ```docker push eugenesable/otus-reddit:1.0``` - сделан пуш

- Собран люраз из локального докера:
```
$ docker run --name reddit -d -p 9292:9292 eugenesable/otus-reddit:1.0
Unable to find image 'eugenesable/otus-reddit:1.0' locally
1.0: Pulling from eugenesable/otus-reddit
e80174c8b43b: Pull complete
d1072db285cc: Pull complete
858453671e67: Pull complete
3d07b1124f98: Pull complete
92b4d8ecd544: Pull complete
1e752b2e9ffa: Pull complete
455afc3eb6db: Pull complete
6c031030b6ff: Pull complete
fe1e27c5f0d9: Pull complete
c273c6f30d33: Pull complete
f88a90fd918f: Pull complete
47a7574ab7a2: Pull complete
ba535e957533: Pull complete
Digest: sha256:7ab7334e87d65ebec9d449be2aae9db38d73882ae80bde2bd1fb63956b84d377
Status: Downloaded newer image for eugenesable/otus-reddit:1.0
0c5ce4b427f446f04b1b98374b399cadb71ec7876e1a7cc291b03ec4eaf0ab1b
```
```
$ docker ps -a
CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                    NAMES
0c5ce4b427f4        eugenesable/otus-reddit:1.0   "/start.sh"         5 minutes ago       Up 5 minutes        0.0.0.0:9292->9292/tcp   reddit
```
- Приложение отвечает на http://0.0.0.0:9292

• ```docker logs reddit -f``` - чтение логов в файл контейнера redit
• ```docker exec -it reddit bash``` - запуск bash внутри контейнера reddit
  • ```ps aux``` - просмотр процессов
  • ```killall5 1``` - kill контейнера
• ```docker start reddit``` - запуск контенера
• ```docker stop reddit && docker rm reddit``` - остановка и удаление контейнера
• ```docker run --name reddit --rm -it eugenesable/otus-reddit:1.0 bash``` - запустить контейнер без приложения
  • ```ps aux``` - посмтреть процессы
  • ```exit``` - выход
• ```docker inspect eugenesable/otus-reddit:1.0``` - информация об образе
• ```docker inspect eugenesable/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'``` - посмотреть что-то конкретное [/bin/sh -c #(nop)  CMD ["/start.sh"]]

 - запустить контейнер reddit, запустить баш внутри, созать папку, в ней файл, удалить  opt/, выйти:
```
docker run --name reddit -d -p 9292:9292 eugenesable/otus-reddit:1.0
docker exec -it reddit bash
mkdir /test1234
touch /test1234/testfile
rmdir /opt
exit
```
• ```docker diff reddit``` - просмотр изменений
• ```docker stop reddit && docker rm reddit``` - стопнуть и удалить
- перезапустить и проверить, что изменения не сохранились:
• ```docker run --name reddit --rm -it eugenesable/otus-reddit:1.0 bash```
  • ```ls /```

## Задание со * ##

- Добавлеа папка infra/, в которую добавлены packer/, ansible/, terraform/

## Packer ##
- Добавлен провиженер с установкой докера:
```
"provisioners": [
        {
            "type": "ansible",
            "playbook_file": "../ansible/playbook/packer_docker.yml",
            "ansible_env_vars": ["ANSIBLE_ROLES_PATH=../ansible/roles"]
        }
    ]
```
- Создан образ docker-reddit-base-1574717679:
```
packer build -var 'project_id=docker-260019' \
                -var 'source_image_family=ubuntu-1604-lts' \
                -var 'machine_type=f1-micro' \
                -var 'disk_size=10' docker.json
```



 ## Terraform ##
- Добавлен модуль docker: ./terraform/modules/docker:
```
 resource "google_compute_instance" "docker" {
  name         = "reddit-docker"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-docker"]

  boot_disk {
    initialize_params { image = var.docker_disk_image }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "google_compute_address" "docker_ip" {
  name = "reddit-docker-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall_docker" {
  name    = "allow-docker-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["2376"]
  }
  source_ranges = ["0.0.0.0/0"]
}
```
- Модуль докер объявлен в main.tf:
```
module "docker" {
  source           = "./modules/docker"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  zone             = var.zone
  docker_disk_image= var.docker_disk_image
  instances        = 1
}
```
- Переменная с новым образом с докером обавлена variables.tf:
```
  variable docker_disk_image {
  description = "Disk image for reddit db"
  default     = "docker-reddit-base-1574717679"
}
```
- Поднята инфраструктура:
```
terraform init
terraform get
terraform plan
terrafom apply -auto=approve
```

## Ansible ##
- Из прошлой инфры перенесены environments/stage
- Изменен inventory.gcp.yml под новый проект:
```
plugin: gcp_compute
projects:
  - docker-260019
service_account_file: ~/.ssh/docker.json
auth_kind: serviceaccount
groups:
  docker: "'docker' in name"
```
- Инсталлирована роль geerlingguy.docker для установки докера в образ packer'а:
```ansible-galaxy install geerlingguy.docker```
- Добален ПБ docker.yml, в котором доставляются некоторые модули и запускается контейнер с приложением из докер хаба:
```
---
- name: install missed modules & pack reddit-app into docker
  hosts: all
  become: true

  tasks:
    - debug: msg="This is in {{ env }} environment"

    - name: Install pip
      apt:
        name: python-pip
    - name: Install docker pip module
      pip:
        name: docker

    - name: Run docker container reddit
      docker_container:
        name: reddit
        image: eugenesable/otus-reddit:1.0
        ports:
        - "9292:9292"
```
- В ПБ site.yml импортирован ПБ docker.yml:
```
---
- import_playbook: base.yml
- import_playbook: users.yml
- import_playbook: docker.yml
```
- Запущен ПБ: ```ansible-playbook playbook/site.yml```

Приложение завелось: http://35.205.47.166:9292/
