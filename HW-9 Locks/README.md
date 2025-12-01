# Блокировки

## 1. Настройте сервер так, чтобы в журнал сообщений сбрасывалась информация о блокировках, удерживаемых более 200 миллисекунд. Воспроизведите ситуацию, при которой в журнале появятся такие сообщения.

```bash
sudo -u postgres psql
```

Включаем логирование информации о блокировках (*_log_lock_waits_*) более 200 миллисекунд (управляется *_deadlock_timeout_*).

```postgresql
alter system set log_lock_waits = on;
select pg_reload_conf();
show deadlock_timeout;
 deadlock_timeout 
------------------
 1s
(1 row)

alter system set deadlock_timeout = 200;
select pg_reload_conf();
show deadlock_timeout;
 deadlock_timeout 
------------------
 200ms
(1 row)
```


Содаём базу hw9 с таблицей для теста.

```postgresql
create database hw9;

\c hw9

create table orders (order_id integer not null, consignee varchar(128) not null, total money not null constraint df_orders_total default 0, primary key (order_id));

create index ix_orders_consignee on orders using btree (consignee asc);

insert into orders values(1, 'Consignee 1', 1000), (2, 'Consingee 2', 2000);
```

Заблокируем запись 1 в сеансе 1.

```postgresql
begin;
update orders set total = total * 1.05 where order_id = 1;
```

Попытаемся прочитать запись 1 в сеансе 2.

```postgresql
\c hw9
select * from orders where order_id = 1 for update;;
```

Смотрим лог-файл кластера в сессии 3.

```bash
tail -n 5 /var/log/postgresql/postgresql-15-main.log
2025-11-30 18:04:01.571 UTC [1284] LOG:  checkpoint complete: wrote 3 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.305 s, sync=0.004 s, total=0.321 s; sync files=3, longest=0.004 s, average=0.002 s; distance=0 kB, estimate=2532 kB
2025-11-30 18:05:08.402 UTC [122130] postgres@hw9 LOG:  process 122130 still waiting for ShareLock on transaction 10153132 after 200.240 ms
2025-11-30 18:05:08.402 UTC [122130] postgres@hw9 DETAIL:  Process holding the lock: 114808. Wait queue: 122130.
2025-11-30 18:05:08.402 UTC [122130] postgres@hw9 CONTEXT:  while locking tuple (0,1) in relation "orders"
2025-11-30 18:05:08.402 UTC [122130] postgres@hw9 STATEMENT:  select * from orders where order_id = 1 for update;
```

## 2. Смоделируйте ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах. Изучите возникшие блокировки в представлении pg_locks и убедитесь, что все они понятны. Пришлите список блокировок и объясните, что значит каждая.

Заблокируем запись 1 в сеансе 1.

```postgresql
begin;
update orders set total = total * 1.05 where order_id = 1;
```

Заблокируем запись 1 в сеансе 2.

```postgresql
begin;
update orders set consignee = 'Consignee 3' where order_id = 1;
```

Заблокируем запись 1 в сеансе 3.

```postgresql
begin;
update orders set total = total * 1.1 where order_id = 1;
```

Получим *_backend_pid_* в сеансе 1 и список блокировок.
```postgresql
select pg_backend_pid();
 pg_backend_pid 
----------------
         114808
(1 row)


select pid, locktype, relation, page, tuple, transactionid, mode, granted, waitstart, relation::regclass as relname from pg_locks;

  pid   |   locktype    | relation | page | tuple | transactionid |       mode       | granted |           waitstart           |       relname       
--------+---------------+----------+------+-------+---------------+------------------+---------+-------------------------------+---------------------
 126669 | relation      |    16501 |      |       |               | RowExclusiveLock | t       |                               | ix_orders_consignee
 126669 | relation      |    16499 |      |       |               | RowExclusiveLock | t       |                               | orders_pkey
 126669 | relation      |    16495 |      |       |               | RowExclusiveLock | t       |                               | orders
 126669 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 122130 | relation      |    16501 |      |       |               | RowExclusiveLock | t       |                               | ix_orders_consignee
 122130 | relation      |    16499 |      |       |               | RowExclusiveLock | t       |                               | orders_pkey
 122130 | relation      |    16495 |      |       |               | RowExclusiveLock | t       |                               | orders
 122130 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 114808 | relation      |    12073 |      |       |               | AccessShareLock  | t       |                               | pg_locks
 114808 | relation      |    16501 |      |       |               | RowExclusiveLock | t       |                               | ix_orders_consignee
 114808 | relation      |    16499 |      |       |               | RowExclusiveLock | t       |                               | orders_pkey
 114808 | relation      |    16495 |      |       |               | RowExclusiveLock | t       |                               | orders
 114808 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 114808 | transactionid |          |      |       |      10153136 | ExclusiveLock    | t       |                               | 
 126669 | tuple         |    16495 |    0 |     5 |               | ExclusiveLock    | f       | 2025-11-30 18:17:17.761411+00 | orders
 122130 | transactionid |          |      |       |      10153136 | ShareLock        | f       | 2025-11-30 18:16:44.505721+00 | 
 122130 | transactionid |          |      |       |      10153137 | ExclusiveLock    | t       |                               | 
 126669 | transactionid |          |      |       |      10153138 | ExclusiveLock    | t       |                               | 
 122130 | tuple         |    16495 |    0 |     5 |               | ExclusiveLock    | t       |                               | orders
(19 rows)
```

У строк с 114808 в колонке *_pid_* видим успешно полученные блокировки (*_granted_*) для всех блокируемых объектов (*_locktype: relation, tuple, virtualxid, transactionid_*).

Видим цепочку транзакций (*_transactionid_*) 10153136 --> 10153137 --> 10153138. 

- Процесс в сеансе 1 начал транзацию 10153136, ждёт подтверждения её (*_<span style="background-color: lightgreen;">pid:114808, locktype:\*, granted:true</span>_*) и не зависит от других процессов. 
	
- Процесс в сеансе 2 начал транзакцию 10153137 (<span style="background-color: lightgreen;">*_pid:122130, transactionid:10153137, mode:ExclusiveLock, granted:true_*</span>) и ожидает завершения транзакции 10153136 (<span style="background-color: pink;">*_pid:122130, transactionid:10153136, mode:ShareLock, granted:false_*</span>). Запрашиваемая блокировка Share несовместима с установленной Exclusive.

- Процесс в сеансе 3 начал транзакцию 10153138 (<span style="background-color: lightgreen;">*_pid:126669, transactionid:10153138, mode:ExclusiveLock, granted:true_*</span>) и ожидает завершения транзакции 10153136, блокирующей кортеж (<span style="background-color: lightgreen;">*_pid:122130, locktype:tuple, relation:16495, page:0, tuple:5 mode:ExclusiveLock, granted:true_*</span>), поскольку ожидает блокировки этого кортежа (<span style="background-color: pink;">*_pid:126669, locktype:tuple, relation:16495, page:0, tuple:5 mode:ExclusiveLock, granted:false_*</span>). Запрашиваемая блокировка Exclusive несовместима с установленной Exclusive.

Откатим транзакции во всех сеансах.

Сеанс 1.

```postgresql
rollback;

select pid, locktype, relation, page, tuple, transactionid, mode, granted, waitstart, relation::regclass as relname from pg_locks;
  pid   |   locktype    | relation | page | tuple | transactionid |       mode       | granted |           waitstart           |       relname       
--------+---------------+----------+------+-------+---------------+------------------+---------+-------------------------------+---------------------
 126669 | relation      |    16501 |      |       |               | RowExclusiveLock | t       |                               | ix_orders_consignee
 126669 | relation      |    16499 |      |       |               | RowExclusiveLock | t       |                               | orders_pkey
 126669 | relation      |    16495 |      |       |               | RowExclusiveLock | t       |                               | orders
 126669 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 122130 | relation      |    16501 |      |       |               | RowExclusiveLock | t       |                               | ix_orders_consignee
 122130 | relation      |    16499 |      |       |               | RowExclusiveLock | t       |                               | orders_pkey
 122130 | relation      |    16495 |      |       |               | RowExclusiveLock | t       |                               | orders
 122130 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 114808 | relation      |    12073 |      |       |               | AccessShareLock  | t       |                               | pg_locks
 114808 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 222599 | virtualxid    |          |      |       |               | ExclusiveLock    | t       |                               | 
 222599 | object        |          |      |       |               | RowExclusiveLock | t       |                               | 
 126669 | transactionid |          |      |       |      10153137 | ShareLock        | f       | 2025-12-01 11:44:36.811768+00 | 
 126669 | tuple         |    16495 |    0 |     5 |               | ExclusiveLock    | t       |                               | orders
 122130 | transactionid |          |      |       |      10153137 | ExclusiveLock    | t       |                               | 
 126669 | transactionid |          |      |       |      10153138 | ExclusiveLock    | t       |                               | 
 222599 | relation      |     2964 |      |       |               | AccessShareLock  | t       |                               | pg_db_role_setting
(17 rows)
```

Видим, что теперь процесс 126669 в сеансе 3 (*_transactionid:10153138_*) теперь ожидает разрешения кофликта блокировки уже не для кортежа, а завершения транзакции 10153137, в которой заблокирована строка, аналогично сеансам 1 и 2 ранее.


Сеанс 2.

```postgresql
rollback;
```

Сеанс 3.

```postgresql
rollback;
```

## 3. Воспроизведите взаимоблокировку трех транзакций. Можно ли разобраться в ситуации постфактум, изучая журнал сообщений?

Начнём изменять строки в 3 транзакциях.

Операция 1. Сеанс 1. Увеличим сумму заказа 1.

```postgresql
begin;
update orders set total = total + 100::money where order_id = 1;
```

Операция 2. Сеанс 2. Уменьшим сумму заказа 2.

```postgresql
begin;
update orders set total = total - 100::money where order_id = 2;
```

Операция 3. Сеанс 3. Заменим заказчика в заказе 2.

```postgresql
begin;
update orders set consignee = 'Consignee 1' where order_id = 2;
```

_Возникло ожидание блокировки из-за транзакции в сеансе 2._


Операция 4. Сеанс 1. Заменим заказчика в заказе 2.

```postgresql
update orders set consignee = 'Consignee 1' where order_id = 2;
```

_Возникло ожидание блокировки из-за транзакции в сеансе 2._

Операция 5. Сеанс 2. Заменим заказчика в заказе 1.

```postgresql
update orders set consignee = 'Consignee 3' where order_id = 1;
```

Проверим содержимое лог-файла кластера.

```bash
tail -n 40 /var/log/postgresql/postgresql-15-main.log

2025-12-01 12:13:30.443 UTC [1284] LOG:  checkpoint starting: time
2025-12-01 12:13:30.659 UTC [1284] LOG:  checkpoint complete: wrote 2 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.205 s, sync=0.003 s, total=0.216 s; sync files=2, longest=0.003 s, average=0.002 s; distance=0 kB, estimate=981 kB
2025-12-01 12:13:51.910 UTC [126669] postgres@hw9 LOG:  process 126669 still waiting for ShareLock on transaction 10153140 after 201.249 ms
2025-12-01 12:13:51.910 UTC [126669] postgres@hw9 DETAIL:  Process holding the lock: 122130. Wait queue: 126669.
2025-12-01 12:13:51.910 UTC [126669] postgres@hw9 CONTEXT:  while updating tuple (0,2) in relation "orders"
2025-12-01 12:13:51.910 UTC [126669] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 1' where order_id = 2;
2025-12-01 12:14:00.690 UTC [1284] LOG:  checkpoint starting: time
2025-12-01 12:14:00.802 UTC [1284] LOG:  checkpoint complete: wrote 1 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.101 s, sync=0.002 s, total=0.112 s; sync files=1, longest=0.002 s, average=0.002 s; distance=0 kB, estimate=883 kB
2025-12-01 12:15:27.736 UTC [114808] postgres@hw9 LOG:  process 114808 still waiting for ExclusiveLock on tuple (0,2) of relation 16495 of database 16487 after 200.803 ms
2025-12-01 12:15:27.736 UTC [114808] postgres@hw9 DETAIL:  Process holding the lock: 126669. Wait queue: 114808.
2025-12-01 12:15:27.736 UTC [114808] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 1' where order_id = 2;
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 LOG:  process 122130 detected deadlock while waiting for ShareLock on transaction 10153139 after 200.516 ms
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 DETAIL:  Process holding the lock: 114808. Wait queue: .
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 CONTEXT:  while updating tuple (0,5) in relation "orders"
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 3' where order_id = 1;
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 ERROR:  deadlock detected
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 DETAIL:  Process 122130 waits for ShareLock on transaction 10153139; blocked by process 114808.
        Process 114808 waits for ExclusiveLock on tuple (0,2) of relation 16495 of database 16487; blocked by process 126669.
        Process 126669 waits for ShareLock on transaction 10153140; blocked by process 122130.
        Process 122130: update orders set consignee = 'Consignee 3' where order_id = 1;
        Process 114808: update orders set consignee = 'Consignee 1' where order_id = 2;
        Process 126669: update orders set consignee = 'Consignee 1' where order_id = 2;
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 HINT:  See server log for query details.
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 CONTEXT:  while updating tuple (0,5) in relation "orders"
2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 3' where order_id = 1;
2025-12-01 12:20:08.867 UTC [126669] postgres@hw9 LOG:  process 126669 acquired ShareLock on transaction 10153140 after 377157.399 ms
2025-12-01 12:20:08.867 UTC [126669] postgres@hw9 CONTEXT:  while updating tuple (0,2) in relation "orders"
2025-12-01 12:20:08.867 UTC [126669] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 1' where order_id = 2;
2025-12-01 12:20:08.867 UTC [114808] postgres@hw9 LOG:  process 114808 acquired ExclusiveLock on tuple (0,2) of relation 16495 of database 16487 after 281331.856 ms
2025-12-01 12:20:08.867 UTC [114808] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 1' where order_id = 2;
2025-12-01 12:20:09.068 UTC [114808] postgres@hw9 LOG:  process 114808 still waiting for ShareLock on transaction 10153141 after 200.531 ms
2025-12-01 12:20:09.068 UTC [114808] postgres@hw9 DETAIL:  Process holding the lock: 126669. Wait queue: 114808.
2025-12-01 12:20:09.068 UTC [114808] postgres@hw9 CONTEXT:  while updating tuple (0,2) in relation "orders"
2025-12-01 12:20:09.068 UTC [114808] postgres@hw9 STATEMENT:  update orders set consignee = 'Consignee 1' where order_id = 2;
2025-12-01 12:20:31.029 UTC [1284] LOG:  checkpoint starting: time
2025-12-01 12:20:31.360 UTC [1284] LOG:  checkpoint complete: wrote 4 buffers (0.0%); 0 WAL file(s) added, 0 removed, 0 recycled; write=0.316 s, sync=0.001 s, total=0.331 s; sync files=4, longest=0.001 s, average=0.001 s; distance=1 kB, estimate=795 kB
```

Причины взаимных блокировок вполне можем распутать по сообщениям в лог-файле кластера.

1. Поднимаясь снизу вверх находим у процесса 122130 сообщение `"LOG:  process 122130 detected deadlock"` в 2025-12-01 12:20:08.866;
2. Строки для этого же процесса ниже описывают причины возникновения: 
- ожидание процесса 114808 `"DETAIL:  Process holding the lock: 114808. Wait queue"`
- список команд, ожидающих друг друга:

```bash
	2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 DETAIL:  Process 122130 waits for ShareLock on transaction 10153139; blocked by process 114808.  
			Process 114808 waits for ExclusiveLock on tuple (0,2) of relation 16495 of database 16487; blocked by process 126669.  
			Process 126669 waits for ShareLock on transaction 10153140; blocked by process 122130.  
			Process 122130: update orders set consignee = 'Consignee 3' where order_id = 1;  
			Process 114808: update orders set consignee = 'Consignee 1' where order_id = 2;  
			Process 126669: update orders set consignee = 'Consignee 1' where order_id = 2;  
```

- сообщение `"ERROR:  deadlock detected"` для процесса 122130 сообщает о том, что команда завершилась с ошибкой (была выбрана "жертвой" при разрешения конфликта циклической зависимости).
- сообщение `2025-12-01 12:20:08.866 UTC [122130] postgres@hw9 CONTEXT:  while updating tuple (0,5) in relation "orders"` указывает на ресурс, который ожидала отменённая команда `Process 122130: update orders set consignee = 'Consignee 3' where order_id = 1;`.


## 4. Могут ли две транзакции, выполняющие единственную команду UPDATE одной и той же таблицы (без where), заблокировать друг друга?

Две транзакции могут заблокировать друг друга, если используют разный порядок обработки строк. Сначала они наложат на таблицу совместимую блокировку `Access Share`, а затем в процессе изменения строк таблицы вторая транзакция пытается заблокировать строку, изменённую первой транзакцией и будет ждать освобождения ресурса, поскольку блокировки несовместимы. В какой-то момент времени первая транзакция попытается заблокировать строку, измнённую второй транзакцией. Ни первая, ни вторая транзакция не сможет дальше выполняться, будет обнаружена циклическая зависимость и команда UPDATE одной из транзакций будет завершена с ошибкой `deadlock detected`.

При массовом обновлении строк в таблицах рекомендуется в начале накладывать эксклюзивную блокировку на всю таблицу во избежание получения разделяемой блокировки другими процессами.

Именно это и происходит в случае с командой UPDATE без фильтра WHERE и зацикливания блокировок не происходит. Только одна из транзакций сможет установить блокировку Row Exclusive на таблицу, другая транзакция будет ожидать возможности установить аналогичную блокировку. А это произойдёт не ранее окончания работы первой транзакции.

Ответ: две транзакции не смогут заблокировать друг друга циклически при выполнении команды UPDATE без WHERE.