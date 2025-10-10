# Установка POSTGRES

## 1. Установка в docker на macOS

**Окружение**

- OS: MacOS
- Docker: Docker desktop

### 1.1. Настройка сети

`docker network create pg-net`


### 1.2. Настройка и запуск контейнера ***postgresql3***

Поскольку 2 недели назад вышла 18 версия, решил воспользоваться последней сборкой 17-й версии (17.6)

`docker pull postgres:17.6`

Запустил контейнер с СУБД

`docker run -itd -e POSTGRES_USER=xxxxx -e POSTGRES_PASSWORD=xxxxx --network pg-net -p 5433:5432 -v /Users/costak/OTUS/wh3:/var/lib/postgresql/data --name postgresql3 postgres:17.6`

+ Имя контейнера: *postgres3*
+ Порт: *5433* (по номеру ДЗ, для подключения из host-OS через *Visual Studio Code*)
+ Папка для хранения файлов БД: */Users/costak/OTUS/wh3*

**Результат**: *В папке появились файлы и папки кластера postgres*


### 1.3. Клиент pg-client

1. Запустил клиента

`docker run -it --rm --network pg-net --name pg-client postgres:17 psql -h postgresql3 -U xxxxx`

2. Получил список БД

`\l`

3. Создал базу *wh3*

`create database wh3 with owner = xxxxx;`

`\c wh3` *переключил контекст на базу wh3*

4. Создал таблицу *software*

`create table software1 (id serial not null, name text);`


### 1.4. Клиент PGAdmin

Прочитал о удобной среде PGAdmin4, решил попробовать.

1. Загрузил образ 

`docker pull dpage/pgadmin4:latest`

2. Настроил и запустил контейнер *pgadmin*

`docker run --env=PGADMIN_DEFAULT_EMAIL=xxxx@xxxxx.ru --env=PGADMIN_DEFAULT_PASSWORD=xxxxx --network pg-net -p 5052:80 -h postgresql3 --name pgadmin -d dpage/pgadmin4`

Работает в браузере. http://localhost:5052/browser/

3. Зарегистрировал сервер в PGAdmin;

4. Добавил записи в таблицу *software*

`insert into software (name) values('PostgreSQL'), ('PGAdmin4');`

5. Проверил наличие записей

`select * from software;`

**Результат**: Запрос вернул обе записи.


### 1.5. Удаление контейнера postgres3

1. Остановил контейнер	

`docker stop postgresql3`

2. Удалил контейнер

`docker rm postgresql3`


### 1.6. Повторное создание контейнера postgres3

`docker run -itd -e POSTGRES_USER=xxxxx -e POSTGRES_PASSWORD=xxxxx --network pg-net -p 5433:5432 -v /Users/costak/OTUS/wh3:/var/lib/postgresql/data --name postgresql3 postgres:17.6`


### 1.7. Проверка наличия данных в БД *wh3*

`select * from software;`

Запрос вернул обе записи.

## 2. Установка в Yandex Cloud *(в планах)*