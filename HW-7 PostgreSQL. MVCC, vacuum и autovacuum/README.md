# Настройка autovacuum с учетом особеностей производительности

## Создание ВМ в ЯО (аналогично предыдущему ДЗ)

Сеть:

    yc vpc network create --name otus-net --description "otus-net"


Подсеть:

    yc vpc subnet create --name otus-subnet --range 192.168.0.0/24 --network-name otus-net --description "otus-subnet"


Установка ВМ (тип диска = SSD; размер диска = 10 ГБ):

    yc compute instance create --name otus-db-pg-vm-1 --hostname otus-db-pg-vm-1 --cores 2 --memory 4 --create-boot-disk size=10G,type=network-ssd,image-folder-id=standard-images,image-family=ubuntu-2204-lts --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 --ssh-key ~/.ssh/ya_key.pub


Поиск IP-адреса для подключения:

    yc compute instances list

    +----------------------+-----------------+---------------+---------+---------------+--------------+
    |          ID          |      NAME       |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP  |
    +----------------------+-----------------+---------------+---------+---------------+--------------+
    | fhmsedv4u1lkdksi73do | otus-db-pg-vm-1 | ru-central1-a | RUNNING | 46.21.246.225 | 192.168.0.22 |
    +----------------------+-----------------+---------------+---------+---------------+--------------+


Подключение к ВМ:

    ssh -i ~/.ssh/ya_key -l yc-user 46.21.246.225


Установка PostgreSQL (версия 15)):
```
sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-15
```

## Настройка доступа из кластеру из сети

Проверка статуса кластера:

    pg_lsclusters

    Ver Cluster Port Status Owner    Data directory              Log file
    18  main    5432 online postgres /var/lib/postgresql/15/main /var/log/postgresql/postgresql-15-main.log

Подключение к СУБД:

    sudo -u postgres psql


Получение расположения основного файла конфигурации:

    show config_file;

                config_file
    -----------------------------------------
    /etc/postgresql/15/main/postgresql.conf
    (1 row)


Настройка внешних сетевых подключений (postgresql.conf) установкой значения параметра 'listen_addresses':

Параметр 'listen_addresses' можно изменить средствами СУБД, например, **psql**:

    sudo -u postgres psql
    alter system set listen_addresses = '*';
    ALTER SYSTEM


Настройка способа доступа к кластеру (pg_hba.conf), путь к действующему файлу конфигурации в **psql** командой `show hba_file;` (первоначально указан в параметре 'hba_file' файла postgresql.conf):

    sudo nano /etc/postgresql/15/main/pg_hba.conf

>\# IPv4 local connections:
><span style="background-color: yellow;">host    all             all             ~~127.0.0.1/32~~ 0.0.0.0/0            scram-sha-256</span>


Установка пароля (усиление безопасности при открытых сетевых подключениях):

    sudo -u postgres psql
    \password
    Enter new password for user "postgres":
    Enter it again:

Применение настроек конфигурации:

    sudo pg_ctlcluster 15 main restart


## Инициализация базы для тестов
```
sudo -u postgres pgbench -i postgres
```


## Тестирование производительности с параметрами по умолчанию
```
sudo -u postgres pgbench -c8 -P 6 -T 60 -U postgres postgres

pgbench (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 440.2 tps, lat 18.061 ms stddev 18.245, 0 failed
progress: 12.0 s, 479.2 tps, lat 16.661 ms stddev 19.030, 0 failed
progress: 18.0 s, 474.7 tps, lat 16.830 ms stddev 17.848, 0 failed
progress: 24.0 s, 542.5 tps, lat 14.714 ms stddev 15.629, 0 failed
progress: 30.0 s, 416.0 tps, lat 19.202 ms stddev 23.145, 0 failed
progress: 36.0 s, 329.7 tps, lat 24.183 ms stddev 25.075, 0 failed
progress: 42.0 s, 498.0 tps, lat 16.035 ms stddev 17.692, 0 failed
progress: 48.0 s, 482.3 tps, lat 16.600 ms stddev 17.788, 0 failed
progress: 54.0 s, 511.5 tps, lat 15.609 ms stddev 17.614, 0 failed
progress: 60.0 s, 329.0 tps, lat 24.247 ms stddev 26.338, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 27026
number of failed transactions: 0 (0.000%)
latency average = 17.732 ms
latency stddev = 19.817 ms
initial connection time = 23.090 ms
tps = 450.318059 (without initial connection time)
```

Результат: 450 tps


## Тестирование с настройками, рекомендованными на лекции (_в приложенном файле_)

### Изменение настроек конфигурации

Изменение настроек:
    sudo -u postgres psql

    alter system set log_autovacuum_min_duration = '0';	-- Порог времени выполнения для логирования (включаем все, по умолчанию 10 минут (600000 мс))
    alter system set autovacuum_max_workers = '10';	-- Кол-во параллельных процессов autovacuum (по умолчанию 3)
    alter system set autovacuum_naptime = '15s';	-- Интервал между проверками таблиц (по умолчанию 1 минута)
    alter system set autovacuum_vacuum_threshold = '25';	-- Мин. изменённых строк для запуска (по умолчанию 50)
    alter system set autovacuum_vacuum_scale_factor = '0.05';	-- Порог в % измененных страниц (по умолчанию 20% = 0.2)
    alter system set autovacuum_vacuum_cost_delay = '10';	-- Пауза между очистками мс (по умолчанию 2)
    alter system set autovacuum_vacuum_cost_limit = '1000';	-- Лимит стоимости операции до паузы (по умолчанию -1 = брать значение из "vacuum_cost_limit", который по умолчанию 200)
    select pg_reload_conf();

    select name, setting, context, sourcefile, pending_restart from pg_settings where pending_restart = true;
    |         name          | setting |  context   | sourcefile | pending_restart 
    ------------------------+---------+------------+------------+-----------------
    |autovacuum_max_workers | 3       | postmaster |            | t
    (1 row)


Применение настроек конфигурации:

    sudo pg_ctlcluster 15 main restart


### Тестирование производительности с параметрами, рекомендованными на лекции
```
sudo -u postgres pgbench -c8 -P 6 -T 60 -U postgres postgres

pgbench (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 557.5 tps, lat 14.250 ms stddev 14.726, 0 failed
progress: 12.0 s, 395.5 tps, lat 20.202 ms stddev 21.834, 0 failed
progress: 18.0 s, 433.3 tps, lat 18.435 ms stddev 20.055, 0 failed
progress: 24.0 s, 501.2 tps, lat 15.931 ms stddev 18.785, 0 failed
progress: 30.0 s, 440.3 tps, lat 18.129 ms stddev 19.180, 0 failed
progress: 36.0 s, 481.0 tps, lat 16.620 ms stddev 18.139, 0 failed
progress: 42.0 s, 481.8 tps, lat 16.552 ms stddev 19.757, 0 failed
progress: 48.0 s, 435.7 tps, lat 18.366 ms stddev 20.845, 0 failed
progress: 54.0 s, 414.7 tps, lat 19.264 ms stddev 18.935, 0 failed
progress: 60.0 s, 369.0 tps, lat 21.583 ms stddev 22.657, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 27068
number of failed transactions: 0 (0.000%)
latency average = 17.703 ms
latency stddev = 19.505 ms
initial connection time = 22.603 ms
tps = 451.068680 (without initial connection time)
```

Результат: без изменений (451 tps vs. 450 tps запуска с параметрами по умолчанию)


## Применение настроек, описанных в статье [Давайте отключим vacuum?! Алексей Лесовский](https://habr.com/ru/articles/501516/)

### Изменение настроек конфигурации

Изменение настроек конфигурации:

    sudo -u postgres psql

    alter system reset all;
    alter system set listen_addresses = '*';
    alter system set vacuum_cost_delay = '0';
    alter system set vacuum_cost_page_hit = '0';
    alter system set vacuum_cost_page_miss = '5';
    alter system set vacuum_cost_page_dirty = '5';
    alter system set vacuum_cost_limit = '200';
    alter system set autovacuum_max_workers = '10';	-- Этот параметр требует перезапуска кластера
    alter system set autovacuum_naptime = '1s';
    alter system set autovacuum_vacuum_threshold = '50';
    alter system set autovacuum_analyze_threshold = '50';
    alter system set autovacuum_vacuum_scale_factor = '0.05';
    alter system set autovacuum_analyze_scale_factor = '0.05';
    alter system set autovacuum_vacuum_cost_delay = '5ms';
    alter system set autovacuum_vacuum_cost_limit = '-1';
    select pg_reload_conf();

    select name, setting, context, sourcefile, pending_restart from pg_settings where pending_restart = true;
    |         name          | setting |  context   | sourcefile | pending_restart 
    ------------------------+---------+------------+------------+-----------------
    |autovacuum_max_workers | 3       | postmaster |            | t
    (1 row)


Применение настроек конфигурации:

    sudo pg_ctlcluster 15 main restart


### Тестирование производительности с параметрами из статьи
```
sudo -u postgres pgbench -c8 -P 6 -T 60 -U postgres postgres

pgbench (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 454.0 tps, lat 17.439 ms stddev 16.380, 0 failed
progress: 12.0 s, 431.2 tps, lat 18.591 ms stddev 20.185, 0 failed
progress: 18.0 s, 453.7 tps, lat 17.596 ms stddev 19.265, 0 failed
progress: 24.0 s, 410.0 tps, lat 19.472 ms stddev 22.199, 0 failed
progress: 30.0 s, 392.8 tps, lat 20.267 ms stddev 21.170, 0 failed
progress: 36.0 s, 537.2 tps, lat 14.904 ms stddev 15.878, 0 failed
progress: 42.0 s, 378.2 tps, lat 21.082 ms stddev 23.261, 0 failed
progress: 48.0 s, 266.3 tps, lat 30.117 ms stddev 24.800, 0 failed
progress: 54.0 s, 486.5 tps, lat 16.404 ms stddev 20.609, 0 failed
progress: 60.0 s, 390.3 tps, lat 20.421 ms stddev 21.553, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 25209
number of failed transactions: 0 (0.000%)
latency average = 19.016 ms
latency stddev = 20.638 ms
initial connection time = 26.394 ms
tps = 419.859003 (without initial connection time)
```

Результат: 420 tps (стало немного хуже по сравнению с предыдущими запусками ~450 tps).

_P.S. Справедливости ради нужно отметить, что результаты нестабильны. Видимо, сильно зависят от нагрузки на ЯО (четыре дня в разное время). Пытаясь обнаружить зависимости в результатах от настроек, описанных в статье, дважды получал обратную картину – первый запуск производительнее последующего (535 tsp vs. 267 tps)._

Больших ожиданий не было, поскольку:

- параметр 'autovacuum_max_workers' физически ограничен количеством ядер ЦП (по условиям ДЗ из всего 2) и рекомендуется устанавливать не более 1/2 от общего количества ядер;
- быстродействие дисковой подсистемы тоже неплохо "придушено" в ЯО

![SSD](01_VM_SSD.png)

- По записям о статусе pgbench видно, как в какой-то момент количество транзакций в секунду резко снижается и это коррелирует с запуском процесса autovacuum

```
SELECT datname, usename, pid, current_timestamp - xact_start AS xact_runtime, state, query
FROM pg_stat_activity 
WHERE query LIKE '%autovacuum%' AND query NOT LIKE '%pg_stat_activity%'
ORDER BY xact_start;

 datname  | usename |  pid  |  xact_runtime   | state  |                   query                    
----------+---------+-------+-----------------+--------+--------------------------------------------
 postgres |         | 30185 | 00:00:04.656036 | active | autovacuum: VACUUM public.pgbench_branches
(1 row)
```

- принимаем во внимание обязательность подтверждения записи на диск результата завершённых транзакций.

Получается, что возможно использование всего 2 ядер, и весь прирост быстродействия можно обеспечить за счёт минимизации времени использования ЦП и диском другими процессами.


## Поиск причины провалов быстродействия (гипотеза о влиянии процесса ___autovacuum___)

### Анализ журнала кластера

Включим регистрацию журнала в кластере и сбор результатов запуска процесса autovacuum.

Изменение настроек:
    sudo -u postgres psql

    alter system set logging_collector = 'on';
    alter system set log_autovacuum_min_duration = '0';
    select pg_reload_conf();

    select name, setting, context, sourcefile, pending_restart from pg_settings where pending_restart = true;                                                                 
           name        | setting |  context   | sourcefile | pending_restart 
    -------------------+---------+------------+------------+-----------------
     logging_collector | off     | postmaster |            | t
    (1 row)

Применение настроек конфигурации:

    sudo pg_ctlcluster 15 main restart


### Тестирование производительности с параметрами из статьи и включённым журналом
```
sudo -u postgres pgbench -c8 -P 6 -T 60 -U postgres postgres

pgbench (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 434.0 tps, lat 18.264 ms stddev 20.718, 0 failed
progress: 12.0 s, 472.8 tps, lat 16.918 ms stddev 18.172, 0 failed
progress: 18.0 s, 504.2 tps, lat 15.856 ms stddev 19.011, 0 failed
progress: 24.0 s, 473.7 tps, lat 16.846 ms stddev 19.961, 0 failed
progress: 30.0 s, 521.0 tps, lat 15.269 ms stddev 17.898, 0 failed
progress: 36.0 s, 192.0 tps, lat 41.779 ms stddev 32.215, 0 failed
progress: 42.0 s, 481.2 tps, lat 16.598 ms stddev 19.531, 0 failed
progress: 48.0 s, 585.8 tps, lat 13.643 ms stddev 16.100, 0 failed
progress: 54.0 s, 542.2 tps, lat 14.685 ms stddev 17.851, 0 failed
progress: 60.0 s, 309.5 tps, lat 25.895 ms stddev 26.371, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 27106
number of failed transactions: 0 (0.000%)
latency average = 17.676 ms
latency stddev = 20.807 ms
initial connection time = 24.282 ms
tps = 451.773157 (without initial connection time)
```


Содержимое журнала:

    2025-11-08 15:42:25.923 UTC [37681] LOG:  automatic vacuum of table "postgres.public.pgbench_branches": index scans: 1
        pages: 0 removed, 5 remain, 5 scanned (100.00% of total)
        tuples: 13 removed, 152 remain, 9 are dead but not yet removable
        tuples missed: 142 dead from 1 pages not removed due to cleanup lock contention
        removable cutoff: 770209, which was 1469 XIDs old when operation ended
        new relfrozenxid: 769607, which is 3547 XIDs ahead of previous value
        index scan needed: 5 pages from table (100.00% of total) had 13 dead item identifiers removed
        index "pgbench_branches_pkey": pages: 2 in total, 0 newly deleted, 0 currently deleted, 0 reusable
        avg read rate: 0.000 MB/s, avg write rate: 0.000 MB/s
        buffer usage: 59 hits, 0 misses, 0 dirtied
        WAL usage: 16 records, 0 full page images, 1245 bytes
        system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 4.96 s
    ...

    ...
    2025-11-08 15:42:28.466 UTC [37691] LOG:  automatic vacuum of table "postgres.public.pgbench_branches": index scans: 1
        pages: 0 removed, 5 remain, 5 scanned (100.00% of total)
        tuples: 22 removed, 179 remain, 14 are dead but not yet removable
        tuples missed: 164 dead from 1 pages not removed due to cleanup lock contention
        removable cutoff: 771801, which was 949 XIDs old when operation ended
        new relfrozenxid: 771180, which is 1573 XIDs ahead of previous value
        index scan needed: 4 pages from table (80.00% of total) had 7 dead item identifiers removed
        index "pgbench_branches_pkey": pages: 2 in total, 0 newly deleted, 0 currently deleted, 0 reusable
        avg read rate: 0.000 MB/s, avg write rate: 0.000 MB/s
        buffer usage: 59 hits, 0 misses, 0 dirtied
        WAL usage: 12 records, 0 full page images, 874 bytes
        system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 2.20 s


Результат: видим снижение быстродействия в те периоды, когда процесс autovacuum обрабатывает таблицу 'pgbench_branches', производительность не меняется - 452 tps.


### Снижение частоты срабатывания autovacuum

Изменение частоты запуска процесса autovacuum.

Изменение настроек:
    sudo -u postgres psql

    alter system set autovacuum_naptime = '600s';
    select pg_reload_conf();    -- Применение настроек конфигурации


### Тестирование производительности в период простоя процессса autovacuum
```
sudo -u postgres pgbench -c8 -P 6 -T 60 -U postgres postgres

pgbench (15.14 (Ubuntu 15.14-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 561.2 tps, lat 14.155 ms stddev 15.914, 0 failed
progress: 12.0 s, 485.2 tps, lat 16.426 ms stddev 19.296, 0 failed
progress: 18.0 s, 267.8 tps, lat 29.868 ms stddev 29.046, 0 failed
progress: 24.0 s, 434.5 tps, lat 18.390 ms stddev 19.300, 0 failed
progress: 30.0 s, 562.3 tps, lat 14.189 ms stddev 16.130, 0 failed
progress: 36.0 s, 338.2 tps, lat 23.609 ms stddev 24.947, 0 failed
progress: 42.0 s, 551.7 tps, lat 14.468 ms stddev 16.347, 0 failed
progress: 48.0 s, 349.2 tps, lat 22.902 ms stddev 23.750, 0 failed
progress: 54.0 s, 462.5 tps, lat 17.301 ms stddev 19.297, 0 failed
progress: 60.0 s, 494.0 tps, lat 16.148 ms stddev 17.688, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 27046
number of failed transactions: 0 (0.000%)
latency average = 17.715 ms
latency stddev = 20.103 ms
initial connection time = 25.014 ms
tps = 450.795157 (without initial connection time)
```


Содержимое журнала:

    2025-11-08 16:09:19.735 UTC [32125] LOG:  received SIGHUP, reloading configuration files
    2025-11-08 16:09:19.736 UTC [32125] LOG:  parameter "autovacuum_naptime" changed to "600s"
    2025-11-08 16:10:40.529 UTC [32127] LOG:  checkpoint complete: wrote 1786 buffers (10.9%); 0 WAL file(s) added, 0 removed, 0 recycled; write=181.147 s, sync=0.011 s, total=181.182 s; sync files=20, longest=0.008 s, average=0.001 s; distance=12643 kB, estimate=26244 kB



Результат: быстродействие не изменилось - 451 tps, предыдущее предположение о снижении быстродействия из-за срабатывания процесса autovacuum не подтверждается. Снижение быстродействия наблюдается при отсутствии запуска autovacuum.


## Выводы

На текущей конфигурации ожидать значительного изменения быстродействия не приходится.


## Исследование работы AUTOVACUUM

### Создать таблицу с текстовым полем и заполнить случайными или сгенерированными данным в размере 1млн строк
```
create table testtable (somevalue text not null);
CREATE TABLE

insert into testtable (somevalue)
	select 'Test value at ' || CURRENT_TIMESTAMP from generate_series(1, 1000000);

INSERT 0 1000000
```


### Посмотреть размер файла с таблицей
```
SELECT pg_size_pretty(pg_total_relation_size('testtable'));

 pg_size_pretty 
----------------
 73 MB
(1 row)

```
### 5 раз обновить все строчки и добавить к каждой строчке любой символ
```
DO $$  

declare 
	i0 integer := 1;
	i1 integer := 5;
begin  
	while i0 <= i1 loop
		update testtable set somevalue = somevalue || i0::text;
		i0 := i0 + 1;
	end loop;
end;  
$$ language plpgsql;

DO
```


### Посмотреть количество мертвых строчек в таблице и когда последний раз приходил автовакуум
```
SELECT relname, n_live_tup, n_dead_tup,
	trunc(100*n_dead_tup/(n_live_tup+1))::float AS "ratio%", last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'testtable';

  relname  | n_live_tup | n_dead_tup | ratio% | last_autovacuum 
-----------+------------+------------+--------+-----------------
 testtable |    1000000 |    5000000 |    499 | 
(1 row)
```

_Примечание. Autovacuum был настроен на запуск каждые 10 минут в первой части ДЗ._


### Подождать некоторое время, проверяя, пришел ли автовакуум
```
SELECT relname, n_live_tup, n_dead_tup,
	trunc(100*n_dead_tup/(n_live_tup+1))::float AS "ratio%", last_autovacuum
FROM pg_stat_user_tables
WHERE relname = 'testtable';

  relname  | n_live_tup | n_dead_tup | ratio% |        last_autovacuum        
-----------+------------+------------+--------+-------------------------------
 testtable |     992817 |          0 |      0 | 2025-11-08 18:44:46.957631+00
(1 row)
```

_Примечание. Удивительно, что количество кортежей 992817, а не 1000000, как было в начале_


### 5 раз обновить все строчки и добавить к каждой строчке любой символ
```
DO $$  

declare 
	i0 integer := 1;
	i1 integer := 5;
begin  
	while i0 <= i1 loop
		update testtable set somevalue = somevalue || i0::text;
		i0 := i0 + 1;
	end loop;
end;  
$$ language plpgsql;

DO
```


### Посмотреть размер файла с таблицей
```
SELECT pg_size_pretty(pg_total_relation_size('testtable'));                                                        

 pg_size_pretty 
----------------
 483 MB
(1 row)
```


### Отключить Автовакуум на конкретной таблице
```
alter table testtable set (autovacuum_enabled = false);

ALTER TABLE
```


### 10 раз обновить все строчки и добавить к каждой строчке любой символ
```
DO $$  

declare 
	i0 integer := 0;
	i1 integer := 9;
begin  
	while i0 <= i1 loop
		i0 := i0 + 1;
		update testtable set somevalue = somevalue || i0::text;
		raise notice 'Step #% at %', i0, CLOCK_TIMESTAMP();
	end loop;
end;
$$ language plpgsql;

NOTICE:  Step #1 at 2025-11-08 19:56:21.021139+00
NOTICE:  Step #2 at 2025-11-08 19:56:53.135325+00
NOTICE:  Step #3 at 2025-11-08 19:57:22.171826+00
NOTICE:  Step #4 at 2025-11-08 19:57:49.527482+00
NOTICE:  Step #5 at 2025-11-08 19:58:22.459985+00
NOTICE:  Step #6 at 2025-11-08 19:58:50.169461+00
NOTICE:  Step #7 at 2025-11-08 19:59:25.414465+00
NOTICE:  Step #8 at 2025-11-08 19:59:50.8348+00
NOTICE:  Step #9 at 2025-11-08 20:00:23.980134+00
NOTICE:  Step #10 at 2025-11-08 20:01:03.524081+00
DO
```


_Примечание. Ничего полезнее для вывода номера шага из анонимного блока, кроме `RAISE NOTICE` не обнаружил, функция `CLOCK_TIMESTAMP` своим поведением лучше подошла для вывода времени окончания шага цикла, чем `CURRENT_TIMESTAMP`._

### Посмотреть размер файла с таблицей
```
SELECT pg_size_pretty(pg_total_relation_size('testtable'));                                                        

 pg_size_pretty 
----------------
 952 MB
(1 row)
```


### Объясните полученный результат

Процесс autovacuum:
- удаляет "мёртвые" записи, которые не используются ни одной транзакцией (из общего буфера и диска);
- обновляет статистику таблиц и индексов;

Поскольку для таблицы autovacuum был отключен, следовательно неиспользуемые данные перестали удаляться из страниц в таблице, для записи новых версий нельзя использовать освободившееся пространство, а необходимо запрашивать в файловой системе.

### Не забудьте включить автовакуум)

Изменение частоты запуска процесса autovacuum.

Изменение настроек:
    sudo -u postgres psql

    alter system set autovacuum_naptime = '15s';
    select pg_reload_conf();    -- Применение настроек конфигурации


Разрешение обработки таблицы процессом autovacuum:

```
alter table testtable set (autovacuum_enabled = true);

ALTER TABLE
```
