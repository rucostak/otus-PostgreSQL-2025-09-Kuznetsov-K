# Работа с уровнями изоляции транзакции в PostgreSQL

**Окружение**

- OS: MacOS
- Docker: Docker desktop
- PostgreSQL: контейнер из ДЗ 3 (*postgresql3*)
- клиент: контейнер из ДЗ 3 (*pg-client*)

1. Запуск СУБД

Запустил контейнер с СУБД

`docker run -itd -e POSTGRES_USER=xxxxx -e POSTGRES_PASSWORD=xxxxx --network pg-net -p 5433:5432 -v /Users/costak/OTUS/wh3:/var/lib/postgresql/data --name postgresql3 postgres:17.6`


2. Настройка сессий

- запустил в терминале 1

`docker run -it --rm --network pg-net --name pg-client1 postgres:17 psql -h postgresql3 -U xxxxx`

- повторил в терминале 2

`docker run -it --rm --network pg-net --name pg-client2 postgres:17 psql -h postgresql3 -U xxxxx`

*Примечание. Для подключения использую переопределённого пользователя \*\*\*\**


3. Отключение автофиксации транзакций в обоих сессиях

`\set AUTOCOMMIT Off`


**Результат**: Запрос `\set` вернул `AUTOCOMMIT = 'off'`.

4. Создание таблицы *persons* в сессии 1
	```
	create table persons(id serial, first_name text, second_name text);
	insert into persons(first_name, second_name) values('ivan', 'ivanov');
	insert into persons(first_name, second_name) values('petr', 'petrov');
	commit;
	```

5. Проверка уровня транзакции в сессии 1
	
	`show transaction isolation level;`


**Результат**: `read committed`.

6. Начало транзакции в обоих сессиях
	
	`begin transaction;`

*Примечание. В сессии 1 появилось предупреждение о запущенной транзакции (остатки от предыдущей команды `show transaction isolation level;`)*
	
	WARNING:  there is already a transaction in progress
	BEGIN


7. Вставка записи в таблицу в сессии 1
	
	`insert into persons(first_name, second_name) values('sergey', 'sergeev');`


8. Проверка наличия новой записи в сессии 2
	
	`select * from persons;`


**Результат**: новая запись не видна, поскольку уровень изоляции не позволяет обращаться к неподтверждённым изменениям в БД.
	
	 id | first_name | second_name 
	----+------------+-------------
	  1 | ivan       | ivanov
	  2 | petr       | petrov
	(2 rows)


9. Завершение транзакции в сессии 1
	
	`commit;`


10. Проверка наличия новой записи в сессии 2
	
	`select * from persons;`


**Результат**: видна новая запись, поскольку транзакция вставки в сессии 1 была подтверждена.
	
	 id | first_name | second_name 
	----+------------+-------------
	  1 | ivan       | ivanov
	  2 | petr       | petrov
	  3 | sergey     | sergeev
	(3 rows)


11. Завершение транзакции в сессии 2
	
	`commit;`


12. Настройка уровня транзакции в обоих сессиях
	```
	begin transaction;
	set transaction isolation level repeatable read;
	```

13. Вставка записи в таблицу в сессии 1
	
	`insert into persons(first_name, second_name) values('sveta', 'svetova');`


14. Проверка наличия новой записи в сессии 2
	
	`select * from persons;`


**Результат**: новая запись не видна, поскольку уровень изоляции не позволяет обращаться к неподтверждённым изменениям в БД.
	
	 id | first_name | second_name 
	----+------------+-------------
	  1 | ivan       | ivanov
	  2 | petr       | petrov
	  3 | sergey     | sergeev
	(3 rows)


15. Завершение транзакции в сессии 1
	
	`commit;`


16. Проверка наличия новой записи в сессии 2
	
	`select * from persons;`


**Результат**: новая запись не видна, поскольку уровень изоляции REPEATABLE READ не позволяет обращаться к любым изменениям в БД, случившимся во время выполнения такой транзакции.
	
	 id | first_name | second_name 
	----+------------+-------------
	  1 | ivan       | ivanov
	  2 | petr       | petrov
	  3 | sergey     | sergeev
	(3 rows)
	

17. Завершение транзакции в сессии 2
	
	`commit;`


16. Проверка наличия новой записи в сессии 2
	
	`select * from persons;`


**Результат**: видна новая запись, поскольку транзакции в обоих сессиях завершены.
	
	 id | first_name | second_name 
	----+------------+-------------
	  1 | ivan       | ivanov
	  2 | petr       | petrov
	  3 | sergey     | sergeev
	  4 | sveta      | svetova
	(4 rows)

