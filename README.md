# eugenesable_microservices
eugenesable microservices repository

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
