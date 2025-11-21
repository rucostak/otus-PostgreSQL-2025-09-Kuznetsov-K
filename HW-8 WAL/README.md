## 1. Настройте выполнение контрольной точки раз в 30 секунд.

`sudo -u postgres psql`

```
    alter system set checkpoint_timeout = '30s';
    select pg_reload_conf();
```

_Перезапуск кластера не требуется._

## 2. 10 минут c помощью утилиты pgbench подавайте нагрузку.

Инициализируем базу для тестирования производительности.

`sudo -u postgres pgbench -i postgres`

Сбрасываем статистику представления **_pg_stat_bgwriter_** (*PSQL*)

```
select pg_stat_reset_shared('bgwriter');
```


Подаём нагрузку на базу (_статистика каждую минуту_).

`sudo -u postgres pgbench -c8 -P 60 -T 600 -U postgres postgres`

    pgbench (15.14 (Ubuntu 15.14-1.pgdg24.04+1))
    starting vacuum...end.
    progress: 60.0 s, 4395.2 tps, lat 1.818 ms stddev 1.227, 0 failed
    progress: 120.0 s, 4404.7 tps, lat 1.814 ms stddev 1.239, 0 failed
    progress: 180.0 s, 4432.9 tps, lat 1.803 ms stddev 1.222, 0 failed
    progress: 240.0 s, 4432.3 tps, lat 1.803 ms stddev 1.226, 0 failed
    progress: 300.0 s, 4442.2 tps, lat 1.799 ms stddev 1.234, 0 failed
    progress: 360.0 s, 4392.5 tps, lat 1.819 ms stddev 1.270, 0 failed
    progress: 420.0 s, 4418.7 tps, lat 1.809 ms stddev 1.231, 0 failed
    progress: 480.0 s, 4434.6 tps, lat 1.802 ms stddev 1.225, 0 failed
    progress: 540.0 s, 4443.7 tps, lat 1.798 ms stddev 1.226, 0 failed
    progress: 600.0 s, 4453.1 tps, lat 1.795 ms stddev 1.222, 0 failed
    transaction type: <builtin: TPC-B (sort of)>
    scaling factor: 1
    query mode: simple
    number of clients: 8
    number of threads: 1
    maximum number of tries: 1
    duration: 600 s
    number of transactions actually processed: 2655006
    number of failed transactions: 0 (0.000%)
    latency average = 1.806 ms
    latency stddev = 1.232 ms
    initial connection time = 9.670 ms
    tps = 4425.019986 (without initial connection time)


## 3. Измерьте, какой объем журнальных файлов был сгенерирован за это время. Оцените, какой объем приходится в среднем на одну контрольную точку.

Посмотрим на размер файлов в папке журналов WAL.

`sudo ls -l /var/lib/postgresql/15/main/pg_wal`

    total 180228
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000DD
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000DE
    -rw------- 1 postgres postgres 16777216 Nov 20 22:49 0000000100000000000000DF
    -rw------- 1 postgres postgres 16777216 Nov 20 22:47 0000000100000000000000E0
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E1
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E2
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E3
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E4
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E5
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E6
    -rw------- 1 postgres postgres 16777216 Nov 20 22:48 0000000100000000000000E7
    drwx------ 2 postgres postgres     4096 Nov  5 12:56 archive_status


Сведения о частоте и продолжительности выполнения контрольных точек получим в журнале кластера (параметр _log_checkpoints = on_).

`sudo tail -n 45 /var/log/postgresql/postgresql-15-main.log`

    2025-11-20 22:35:40.228 UTC [1231] LOG:  parameter "checkpoint_timeout" changed to "30s"
    2025-11-20 22:37:58.223 UTC [11741] postgres@postgres STATEMENT:  pg_stat_reset_shared('bgwriter');
    2025-11-20 22:38:14.481 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:38:41.076 UTC [1257] LOG:  checkpoint complete: wrote 1711 buffers (10.4%); 0 WAL file(s) added, 0 removed, 3 recycled; write=26.585 s, sync=0.004 s, total=26.596 s; sync files=49, longest=0.002 s, average=0.001 s; distance=53716 kB, estimate=78106 kB
    2025-11-20 22:39:14.108 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:39:41.056 UTC [1257] LOG:  checkpoint complete: wrote 2752 buffers (16.8%); 0 WAL file(s) added, 0 removed, 4 recycled; write=26.941 s, sync=0.004 s, total=26.948 s; sync files=24, longest=0.003 s, average=0.001 s; distance=64377 kB, estimate=76733 kB
    2025-11-20 22:39:44.059 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:40:11.011 UTC [1257] LOG:  checkpoint complete: wrote 2876 buffers (17.6%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.947 s, sync=0.003 s, total=26.953 s; sync files=14, longest=0.002 s, average=0.001 s; distance=78121 kB, estimate=78121 kB
    2025-11-20 22:40:14.014 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:40:41.063 UTC [1257] LOG:  checkpoint complete: wrote 2851 buffers (17.4%); 0 WAL file(s) added, 0 removed, 4 recycled; write=27.044 s, sync=0.003 s, total=27.050 s; sync files=20, longest=0.003 s, average=0.001 s; distance=76828 kB, estimate=77992 kB
    2025-11-20 22:40:44.066 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:41:11.016 UTC [1257] LOG:  checkpoint complete: wrote 2765 buffers (16.9%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.944 s, sync=0.002 s, total=26.951 s; sync files=15, longest=0.002 s, average=0.001 s; distance=77405 kB, estimate=77933 kB
    2025-11-20 22:41:14.017 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:41:41.080 UTC [1257] LOG:  checkpoint complete: wrote 2734 buffers (16.7%); 0 WAL file(s) added, 0 removed, 5 recycled; write=27.046 s, sync=0.004 s, total=27.064 s; sync files=18, longest=0.003 s, average=0.001 s; distance=76617 kB, estimate=77801 kB
    2025-11-20 22:41:44.083 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:42:11.042 UTC [1257] LOG:  checkpoint complete: wrote 2750 buffers (16.8%); 0 WAL file(s) added, 0 removed, 4 recycled; write=26.942 s, sync=0.004 s, total=26.959 s; sync files=18, longest=0.004 s, average=0.001 s; distance=76963 kB, estimate=77717 kB
    2025-11-20 22:42:14.045 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:42:41.103 UTC [1257] LOG:  checkpoint complete: wrote 2691 buffers (16.4%); 0 WAL file(s) added, 0 removed, 5 recycled; write=27.053 s, sync=0.002 s, total=27.059 s; sync files=16, longest=0.002 s, average=0.001 s; distance=76865 kB, estimate=77632 kB
    2025-11-20 22:42:44.106 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:43:11.057 UTC [1257] LOG:  checkpoint complete: wrote 2847 buffers (17.4%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.945 s, sync=0.003 s, total=26.952 s; sync files=17, longest=0.002 s, average=0.001 s; distance=76643 kB, estimate=77533 kB
    2025-11-20 22:43:14.060 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:43:41.013 UTC [1257] LOG:  checkpoint complete: wrote 3385 buffers (20.7%); 0 WAL file(s) added, 0 removed, 4 recycled; write=26.949 s, sync=0.002 s, total=26.954 s; sync files=18, longest=0.002 s, average=0.001 s; distance=76831 kB, estimate=77463 kB
    2025-11-20 22:43:44.016 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:44:11.078 UTC [1257] LOG:  checkpoint complete: wrote 2673 buffers (16.3%); 0 WAL file(s) added, 0 removed, 5 recycled; write=27.046 s, sync=0.003 s, total=27.062 s; sync files=15, longest=0.002 s, average=0.001 s; distance=76598 kB, estimate=77377 kB
    2025-11-20 22:44:14.081 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:44:41.028 UTC [1257] LOG:  checkpoint complete: wrote 2655 buffers (16.2%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.943 s, sync=0.001 s, total=26.948 s; sync files=13, longest=0.001 s, average=0.001 s; distance=76728 kB, estimate=77312 kB
    2025-11-20 22:44:44.031 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:45:11.097 UTC [1257] LOG:  checkpoint complete: wrote 3617 buffers (22.1%); 0 WAL file(s) added, 0 removed, 4 recycled; write=27.050 s, sync=0.003 s, total=27.067 s; sync files=16, longest=0.003 s, average=0.001 s; distance=76857 kB, estimate=77266 kB
    2025-11-20 22:45:14.099 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:45:41.058 UTC [1257] LOG:  checkpoint complete: wrote 2634 buffers (16.1%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.944 s, sync=0.003 s, total=26.959 s; sync files=15, longest=0.002 s, average=0.001 s; distance=74918 kB, estimate=77031 kB
    2025-11-20 22:45:44.061 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:46:11.031 UTC [1257] LOG:  checkpoint complete: wrote 3826 buffers (23.4%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.953 s, sync=0.004 s, total=26.971 s; sync files=17, longest=0.002 s, average=0.001 s; distance=76525 kB, estimate=76981 kB
    2025-11-20 22:46:14.034 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:46:41.091 UTC [1257] LOG:  checkpoint complete: wrote 2659 buffers (16.2%); 0 WAL file(s) added, 0 removed, 4 recycled; write=27.042 s, sync=0.003 s, total=27.058 s; sync files=14, longest=0.003 s, average=0.001 s; distance=76332 kB, estimate=76916 kB
    2025-11-20 22:46:44.094 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:47:11.045 UTC [1257] LOG:  checkpoint complete: wrote 2660 buffers (16.2%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.944 s, sync=0.004 s, total=26.951 s; sync files=15, longest=0.002 s, average=0.001 s; distance=76704 kB, estimate=76895 kB
    2025-11-20 22:47:14.048 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:47:41.093 UTC [1257] LOG:  checkpoint complete: wrote 2044 buffers (12.5%); 0 WAL file(s) added, 0 removed, 5 recycled; write=27.039 s, sync=0.003 s, total=27.046 s; sync files=14, longest=0.003 s, average=0.001 s; distance=76446 kB, estimate=76850 kB
    2025-11-20 22:47:44.096 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:48:11.059 UTC [1257] LOG:  checkpoint complete: wrote 4982 buffers (30.4%); 0 WAL file(s) added, 0 removed, 4 recycled; write=26.957 s, sync=0.004 s, total=26.964 s; sync files=17, longest=0.002 s, average=0.001 s; distance=77433 kB, estimate=77433 kB
    2025-11-20 22:48:14.062 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:48:41.020 UTC [1257] LOG:  checkpoint complete: wrote 2939 buffers (17.9%); 0 WAL file(s) added, 0 removed, 5 recycled; write=26.942 s, sync=0.003 s, total=26.959 s; sync files=17, longest=0.002 s, average=0.001 s; distance=78667 kB, estimate=78667 kB
    2025-11-20 22:48:44.023 UTC [1257] LOG:  checkpoint starting: time
    2025-11-20 22:49:11.080 UTC [1257] LOG:  checkpoint complete: wrote 2851 buffers (17.4%); 0 WAL file(s) added, 0 removed, 5 recycled; write=27.033 s, sync=0.004 s, total=27.057 s; sync files=15, longest=0.004 s, average=0.001 s; distance=78565 kB, estimate=78656 kB


Получим статистику контрольных точек в представлении **_pg_stat_bgwriter_** (*PSQL*)

```
select * from pg_stat_bgwriter \gx
```

    -[ RECORD 1 ]---------+------------------------------
    checkpoints_timed     | 22
    checkpoints_req       | 0
    checkpoint_write_time | 566289
    checkpoint_sync_time  | 66
    buffers_checkpoint    | 59931
    buffers_clean         | 760
    maxwritten_clean      | 0
    buffers_backend       | 17226
    buffers_backend_fsync | 0
    buffers_alloc         | 17539
    stats_reset           | 2025-11-20 22:38:23.387711+00

Результат: объём журнальных файлов на диске 176 МБ (16 МБ в 11 файлах), однако, нужно принимать во внимание, что файлы журнала перезаписывались.

Из лога видно:
    - заспусков контрольных точек (checkpoints_timed + checkpoints_req): 22
    - общее количество записанных буферов: 59931
    - средний размер данных контрольной точки: 2724 буферов (22 315 008 байт)


## 4. Проверьте данные статистики: все ли контрольные точки вполнялись точно по расписанию. Почему так произошло?

В представлении pg_stat_bgwriter количество принудительных вызовов контрольной точки 0 (checkpoint_req), а по достижению таймаута 22 (checkpoint_timed). Можем сделать вывод, что все контрольные точки выполнялись по расписанию. В файле лога кластера нет ни одного запуска дольше 27 секунд, что тоже подтверждает вывод о выполнении всех запусков по расписанию.

Быстродействия оборудования хватает для выполнения контрольных точек за период между запусками по расписанию.


## 5. Сравните tps в синхронном/асинхронном режиме утилитой pgbench. Объясните полученный результат.

Настроим режим асинхронной записи (*PSQL*)

```
alter system set synchronous_commit = 'off';
select pg_reload_conf();
```


Подаём нагрузку на базу (_статистика каждую минуту_).

`sudo -u postgres pgbench -c8 -P 60 -T 600 -U postgres postgres`

    pgbench (15.14 (Ubuntu 15.14-1.pgdg24.04+1))
    starting vacuum...end.
    progress: 60.0 s, 6540.0 tps, lat 1.222 ms stddev 0.699, 0 failed
    progress: 120.0 s, 6606.9 tps, lat 1.210 ms stddev 0.686, 0 failed
    progress: 180.0 s, 6636.4 tps, lat 1.204 ms stddev 0.674, 0 failed
    progress: 240.0 s, 6645.9 tps, lat 1.202 ms stddev 0.670, 0 failed
    progress: 300.0 s, 6635.6 tps, lat 1.204 ms stddev 0.673, 0 failed
    progress: 360.0 s, 6646.4 tps, lat 1.202 ms stddev 0.668, 0 failed
    progress: 420.0 s, 6599.4 tps, lat 1.211 ms stddev 0.676, 0 failed
    progress: 480.0 s, 6583.4 tps, lat 1.214 ms stddev 0.680, 0 failed
    progress: 540.0 s, 6531.9 tps, lat 1.223 ms stddev 0.682, 0 failed
    progress: 600.0 s, 6441.1 tps, lat 1.241 ms stddev 0.709, 0 failed
    transaction type: <builtin: TPC-B (sort of)>
    scaling factor: 1
    query mode: simple
    number of clients: 8
    number of threads: 1
    maximum number of tries: 1
    duration: 600 s
    number of transactions actually processed: 3952029
    number of failed transactions: 0 (0.000%)
    latency average = 1.213 ms
    latency stddev = 0.682 ms
    initial connection time = 9.798 ms
    tps = 6586.758330 (without initial connection time)


Быстродействие ожидаемо увеличилось с 4425 tps до 6587 tps вследствие того, что СУБД считает подтверждённой транзакцию, данные которой записаны в WAL без получения подтверждения от операционной системы о записи изменений WAL на диск.

## 6. Создайте новый кластер с включенной контрольной суммой страниц. Создайте таблицу. Вставьте несколько значений. Выключите кластер. Измените пару байт в таблице. Включите кластер и сделайте выборку из таблицы. Что и почему произошло? Как проигнорировать ошибку и продолжить работу?

### 6.1. Устанавливаем новый кластер с именем chksum в папке по умолчанию со следующим номером порта.

`sudo pg_createcluster 15 chksum -- --data-checksums`


    Creating new PostgreSQL cluster 15/chksum ...
    /usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/15/chksum --auth-local peer --auth-host scram-sha-256 --no-instructions --data-checksums
    The files belonging to this database system will be owned by user "postgres".
    This user must also own the server process.

    The database cluster will be initialized with locale "en_US.UTF-8".
    The default database encoding has accordingly been set to "UTF8".
    The default text search configuration will be set to "english".

    Data page checksums are enabled.

    fixing permissions on existing directory /var/lib/postgresql/15/chksum ... ok
    creating subdirectories ... ok
    selecting dynamic shared memory implementation ... posix
    selecting default max_connections ... 100
    selecting default shared_buffers ... 128MB
    selecting default time zone ... Etc/UTC
    creating configuration files ... ok
    running bootstrap script ... ok
    performing post-bootstrap initialization ... ok
    syncing data to disk ... ok
    Ver Cluster Port Status Owner    Data directory                Log file
    15  chksum  5433 down   postgres /var/lib/postgresql/15/chksum /var/log/postgresql/postgresql-15-chksum.log



`sudo pg_ctlcluster 15 chksum start`

Проверим успех запуска.

`sudo pg_lsclusters`

    Ver Cluster Port Status Owner    Data directory                Log file
    15  chksum  5433 online postgres /var/lib/postgresql/15/chksum /var/log/postgresql/postgresql-15-chksum.log
    15  main    5432 online postgres /var/lib/postgresql/15/main   /var/log/postgresql/postgresql-15-main.log

### 6.2. Создаём таблицу и вставляем значения.

Подключаемся к новому кластеру, указав порт.

`sudo -u postgres psql -p 5433`

```
create table chktable (id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name text);

insert into chktable (name) select 'Test value at ' || CURRENT_TIMESTAMP from generate_series(1, 1000);
```

Узнаем путь к файлу, в котором будут лежать данные новой таблицы.
```
SELECT pg_relation_filepath('chktable');
 pg_relation_filepath 
----------------------
 base/5/16389
(1 row)
```

### 6.3. Выключаем кластер и портим файл таблицы.

Выключаем кластер.

`sudo pg_ctlcluster 15 chksum stop`


Внесём произвольные изменения в файл таблицы.

`sudo -u postgres nano /var/lib/postgresql/15/chksum/base/5/16389`

Например, заменим в нескольких записях год с 2025 на 2026.

![Изменения в файле таблицы](1_edit_table_file.png)

### 6.4. Включаем кластер и выбираем данные из таблицы.

Запускаем кластер.

`sudo pg_ctlcluster 15 chksum start`

`sudo -u postgres psql -p 5433`

Выборка данных возвращает ошибку.

```
select * from chktable;
WARNING:  page verification failed, calculated checksum 27917 but expected 38903
ERROR:  invalid page in block 0 of relation base/5/16389
```

### 6.5. Что и почему произошло?

При чтении с диска в буфер контрольная сумма страницы не совпала вычисленной ранее (сохранённой в заголовке страницы).


### 6.6. Как проигнорировать ошибку и продолжить работу?

Включить опцию **_ignore_checksum_failure_** и перечитать параметры. Хотя, лучше это делать только для "спасения" уцелевших данных, если нет резервной копии, реплики и других источников, позволяющих восстановить испорченные данные.

```
alter system set ignore_checksum_failure = 'on';
select pg_reload_conf();
```

Получаем содержимое таблицы (с нашими изменениями).

```
select * from chktable;
```

      id  |                    name                     
    ------+---------------------------------------------
        1 | Test value at 2025-11-21 18:40:58.287567+00
        2 | Test value at 2025-11-21 18:40:58.287567+00
        3 | Test value at 2025-11-21 18:40:58.287567+00
        4 | Test value at 2025-11-21 18:40:58.287567+00
        5 | Test value at 2025-11-21 18:40:58.287567+00
        6 | Test value at 2025-11-21 18:40:58.287567+00
        7 | Test value at 2025-11-21 18:40:58.287567+00
        8 | Test value at 2025-11-21 18:40:58.287567+00
        9 | Test value at 2025-11-21 18:40:58.287567+00
       13 | Test value at 2026-11-21 18:40:58.287567+00
       11 | Test value at 2025-11-21 18:40:58.287567+00
       12 | Test value at 2025-11-21 18:40:58.287567+00
       13 | Test value at 2026-11-21 18:40:58.287567+00
       14 | Test value at 2025-11-21 18:40:58.287567+00
       15 | Test value at 2025-11-21 18:40:58.287567+00
       16 | Test value at 2025-11-21 18:40:58.287567+00
       17 | Test value at 2025-11-21 18:40:58.287567+00
       18 | Test value at 2025-11-21 18:40:58.287567+00
       19 | Test value at 2025-11-21 18:40:58.287567+00
       20 | Test value at 2025-11-21 18:40:58.287567+00
    ...

    ...
    WARNING:  page verification failed, calculated checksum 27917 but expected 38903
    WARNING:  page verification failed, calculated checksum 51428 but expected 36872
    WARNING:  page verification failed, calculated checksum 25856 but expected 26725
    WARNING:  page verification failed, calculated checksum 20425 but expected 51179
    WARNING:  page verification failed, calculated checksum 59145 but expected 16908
    WARNING:  page verification failed, calculated checksum 27450 but expected 53654
    WARNING:  page verification failed, calculated checksum 29955 but expected 3779
    WARNING:  page verification failed, calculated checksum 43032 but expected 34285
    WARNING:  page verification failed, calculated checksum 34320 but expected 64638
    WARNING:  page verification failed, calculated checksum 34940 but expected 46799

На строке с id = 13 видно, что результат неверный, запись попала дважды в выборку, хотя идентификаторы изначально были созданы из последовательности.
