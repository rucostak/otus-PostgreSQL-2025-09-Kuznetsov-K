# Логический уровень PostgreSQL 

## Установка ВМ в ЯО через команды

'yc' в составе Яндекс.Облако CLI для управления облачными ресурсами в Яндекс.Облако
https://cloud.yandex.com/en/docs/cli/quickstart

Подключение к Яндекс.Облако и конфигурация окружения с помощью команды:

    yc init


    Welcome! This command will take you through the configuration process.
    Please go to https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb in order to obtain OAuth token.
     Please enter OAuth token: [y0__xDu6rQBG***************************Ew_pX0ken-7m] 
    Your current folder has been set to 'default' (id = b1gj37sg5ihd8gpbp9he).
    Do you want to configure a default Compute zone? [Y/n] y
    Which zone do you want to use as a profile default?
     [1] ru-central1-a
     [2] ru-central1-b
     [3] ru-central1-d
     [4] Don't set default zone
    Please enter your numeric choice: 1
    Your profile default Compute zone has been set to 'ru-central1-a'.

Выбрана зона 'ru-central1-a'


Создание сетевой инфраструктуры для VM:

Сеть:

    yc vpc network create \
        --name otus-net \
        --description "otus-net" \


    id: enpaogjon5o5920598qh
    folder_id: b1gj37sg5ihd8gpbp9he
    created_at: "2025-10-21T07:23:57Z"
    name: otus-net
    description: otus-net
    default_security_group_id: enpshr45idqv40m9a49q

Подсеть:

    yc vpc subnet create \
        --name otus-subnet \
        --range 192.168.0.0/24 \
        --network-name otus-net \
        --description "otus-subnet" \


    id: e9brf07h0cbu2nqjud7a
    folder_id: b1gj37sg5ihd8gpbp9he
    created_at: "2025-10-21T07:24:58Z"
    name: otus-subnet
    description: otus-subnet
    network_id: enpaogjon5o5920598qh
    zone_id: ru-central1-a
    v4_cidr_blocks:
      - 192.168.0.0/24


Генерация ssh-key:

    ssh-keygen -t rsa -b 2048


    Generating public/private rsa key pair.
    Enter file in which to save the key (/Users/c###k/.ssh/id_rsa): ya_key
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in ya_key.
    Your public key has been saved in ya_key.pub.
    The key fingerprint is:
    SHA256:H2M2AF/Wm6.........................pkfAVY cxxxxk@CxxxxxiMac.local
    The key's randomart image is:
    +---[RSA 2048]----+
    |      ..x x.     |
    |      xx x  .    |
    |     x xxx . x   |
    |      + =.. +    |
    |     x *xx*=     |
    |     xx.++x+=    |
    |    .+*@.x.. .   |
    |     +x.x.       |
    |    .+.x.        |
    +----[SHA256]-----+


name ssh-key: ya_key

    ssh-add ~/ya_key


Enter passphrase for /Users/cxxxxk/ya_key: 
Identity added: /Users/cxxxxk/ya_key (cxxxxk@CxxxxxiMac.local)


Установка ВМ:

    yc compute instance create \
        --name otus-db-pg-vm-1 \
        --hostname otus-db-pg-vm-1 \
        --cores 2 \
        --memory 4 \
        --create-boot-disk size=15G,type=network-hdd,image-folder-id=standard-images,image-family=ubuntu-2204-lts \
        --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 \
        --ssh-key /Users/costak/ya_key.pub \


    done (2m7s)
    id: fhm1515aam62bj5rmf1c
    folder_id: b1gj37sg5ihd8gpbp9he
    created_at: "2025-10-21T07:32:55Z"
    name: otus-db-pg-vm-1
    zone_id: ru-central1-a
    platform_id: standard-v2
    resources:
      memory: "4294967296"
      cores: "2"
      core_fraction: "100"
    status: RUNNING
    metadata_options:
      gce_http_endpoint: ENABLED
      aws_v1_http_endpoint: ENABLED
      gce_http_token: ENABLED
      aws_v1_http_token: DISABLED
    boot_disk:
      mode: READ_WRITE
      device_name: fhm2hk2ks31lte2rveu9
      auto_delete: true
      disk_id: fhm2hk2ks31lte2rveu9
    network_interfaces:
      - index: "0"
        mac_address: d0:0d:12:84:aa:55
        subnet_id: e9brf07h0cbu2nqjud7a
        primary_v4_address:
          address: 192.168.0.20
          one_to_one_nat:
            address: 158.160.112.227
            ip_version: IPV4
    serial_port_settings:
      ssh_authorization: OS_LOGIN
    gpu_settings: {}
    fqdn: otus-db-pg-vm-1.ru-central1.internal
    scheduling_policy: {}
    network_settings:
      type: STANDARD
    placement_policy: {}
    hardware_generation:
      legacy_features:
        pci_topology: PCI_TOPOLOGY_V2
    application: {}


    yc compute instances list


    +----------------------+-----------------+---------------+---------+-----------------+--------------+
    |          ID          |      NAME       |    ZONE ID    | STATUS  |   EXTERNAL IP   | INTERNAL IP  |
    +----------------------+-----------------+---------------+---------+-----------------+--------------+
    | fhm1515aam62bj5rmf1c | otus-db-pg-vm-1 | ru-central1-a | RUNNING | 158.160.112.227 | 192.168.0.20 |
    +----------------------+-----------------+---------------+---------+-----------------+--------------+


Подключение к ВМ:

    ssh -l yc-user 158.160.112.227


    Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-216-generic x86_64)

     * Documentation:  https://help.ubuntu.com
     * Management:     https://landscape.canonical.com
     * Support:        https://ubuntu.com/pro

     System information as of Tue Oct 21 07:41:15 UTC 2025

      System load:  0.08               Processes:             112
      Usage of /:   11.5% of 13.89GB   Users logged in:       0
      Memory usage: 4%                 IPv4 address for eth0: 192.168.0.20
      Swap usage:   0%

1. Установка PostgreSQL 15:
```
    sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-15 
```

## Задание

Подключение к ВМ

    ssh -l yc-user 158.160.112.227


2. Подключение к СУБД
```
    sudo -u postgres psql

    psql (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
    Type "help" for help.
```

3. Создание БД testdb
```
    create database testdb;
```

4. Переключение соединения на базу testdb
```
    \c testdb
```
     You are now connected to database "testdb" as user "postgres".


5. Создание схемы testnm
```
    create schema testnm;
```

6. Создание таблицы t1
```
    create table t1 (c1 integer);
```

7. Вставка строки в таблицу t1
```
    insert into t1 (c1) values(1);
```

8. Создание роли readonly
```
    create role readonly;
```

9. Выдача права подключения к базе testdb роли readonly
```
    grant connect on database testdb to readonly;
``` 

10. Выдача права использования схемы testnm роли readonly
```
    grant usage on schema testnm to readonly;
```

11. Выдача права на select во всех таблицах схемы testnm роли readonly
```
    grant select on all tables in schema testnm to readonly;
```

12. Создание пользователя testread
```
    create role testread with login password 'test123';
```

13. Включение пользователя testread в роль readonly
```
    grant readonly to testread;
```

14. Переключение соединения к базе testdb в контексте пользователя testread
```
    \c testdb testread

    connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  Peer authentication failed for user "testread"
    Previous connection kept
```

Выходим из psql

    \q


Поскольку в Linux'е отсутствует пользователь testread, поэтому придётся запустить psql подключением через сетевой протокол с принудительным запросом пароля (-W)

    yc-user@otus-db-pg-vm-1:~$ psql -h 127.0.0.1 -U testread -d testdb -W
    Password: 
    psql (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
    SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
    Type "help" for help.


15. Запросить данные из таблицы t1
```
    select * from t1;
    ERROR:  permission denied for table t1
```

16. Получить данные из таблицы t1 и не могло получиться, поскольку таблица создана в схеме public (схема с именем пользователя postgres в базе testdb отсутствует, а следующая в шаблоне search_path указана схема public). Однако вновь создаваемые объекты в этой схемы доступны автоматически только своим владельцам, права на создание объектов по умолчанию ограничены.
```
    \dt
            List of relations
     Schema | Name | Type  |  Owner   
    --------+------+-------+----------
     public | t1   | table | postgres
    (1 row)

    testdb=# SELECT nspname FROM pg_catalog.pg_namespace;
          nspname       
    --------------------
     pg_toast
     pg_catalog
     public
     information_schema
    (4 rows)

    testdb=# SHOW search_path;
       search_path   
    -----------------
     "$user", public
    (1 row)
```

Правильным решением видится создание таблицы непосредственно в схеме testnm, на таблицы которой выданы права роли readonly на чтение всех таблиц схемы testnm.


22. Подключение с правами пользователя postgres
```
    \q
    sudo -u postgres psql -d testdb
```

23. Удаление таблицы t1
```
    drop table t1;
```

24. Создание таблицы в схеме testnm
```
    create table testnm.t1 (c1 integer);
```

25. Вставка строки
```
    insert into testnm.t1 (c1) values(1);
```

26. Подключение с правами пользователя testread
```
    psql -h 127.0.0.1 -U testread -d testdb -W
```

27. Запросить данные из таблицы testnm.t1
```
    select * from testnm.t1;
    ERROR:  relation "testnm.t1" does not exist
    LINE 1: select * from testnm.t1;
```

28. Права на вновь созданную таблицу так и нет.


29. Поскольку выдача прав командой `grant select on all tables in schema testnm to readonly;` затрагивает только имеющиеся таблицы.


30. Для применения прав для вновь создаваемых необходимо выполнить команду `ALTER DEFAULT PRIVILEGES IN SCHEMA testnm GRANT SELECT ON TABLES TO readonly;` и пересоздать таблицу testnm.t1.

Подключение в новом окне терминала к базе testdb, чтобы удобнее переключаться с правами пользователя postgres
```    
    ssh -l yc-user 158.160.112.227

    yc-user@otus-db-pg-vm-1:~$ sudo -u postgres psql -d testdb
    could not change directory to "/home/yc-user": Permission denied
    psql (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
    Type "help" for help.


    testdb=# drop table testnm.t1;
    DROP TABLE
    testdb=# alter default privileges in schema testnm grant select on tables to readonly;
    ALTER DEFAULT PRIVILEGES
    testdb=# create table testnm.t1 (c1 integer);
    CREATE TABLE
    testdb=# insert into testnm.t1 (c1) values(1);
    INSERT 0 1
```

34. Запросить данные из таблицы testnm.t1 (в подключении пользователя testread).
```
    select * from testnm.t1;
     c1 
    ----
      1
    (1 row)
```

35. Получилось.


37. Создание таблицы t2 и вставка данных (в подключении пользователя testread).
```
    create table t2 (c1 integer);
    insert into t2 (c1) values(2);
    ERROR:  permission denied for schema public
    LINE 1: create table t2 (c1 integer);
                         ^
    ERROR:  relation "t2" does not exist
    LINE 1: insert into t2 (c1) values(2);
```

38. Начиная с версии 15 в PostgreSQL схема public принадлежит роли pg_database_owner, пользователь testread не входит в роль pg_database_owner, следовательно не может создавать новые объекты схемы public.


39. Права на создание объектов в схеме public участникам роли public можно явно предоставить:


40. Предоставление права на создание объектов в схеме public участникам роли public (в подключении пользователя postgres):
```
    grant create on schema public to public;
```

41. Создание таблицы t3 и вставка данных (в подключении пользователя testread).
```
    create table t3 (c1 integer);
    insert into t3 (c1) values(3);
    CREATE TABLE
    INSERT 0 1
```

42. Изначально при создании ВМ не знал подробностей с изменением прав участникам роли public, поэтому поставил привычный по другим ДЗ PostgreSQL версии 15 (помнится не единожды другие студенты спрашивали о версиях :) и получали ответ: берите любую). В итоге, при возникновении ошибки в п. 37 пошёл на "красные ворота" и почитал чудесную статью об основах ролей в PostgreSQL ["PostgreSQL Basics: Roles and Privileges"](https://www.red-gate.com/simple-talk/databases/postgresql/postgresql-basics-roles-and-privileges/). Решил сделать обратную последовательность: ошибка создания, потом успешное создание.

Хотя, понятно, что в реальной жизнь выдавать права на создание объектов в роли public противопоказано.


## Удаление ВМ в ЯО через команды

Выход из ssh-сессии

    exit


Удаление ВМ и сетевых настроек

    yc compute instance delete otus-db-pg-vm-1 && yc vpc subnet delete otus-subnet && yc vpc network delete otus-net
