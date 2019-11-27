# eugenesable_microservices
eugenesable microservices repository

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
