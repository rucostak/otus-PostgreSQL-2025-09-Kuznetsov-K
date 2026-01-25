load database
	from mssql://xxxxxxx:xxxxxxx@192.168.10.139:53969/OtusProject
	into pgsql://xxxxxxxx:xxxxxxxxx@192.168.10.158/otusproject

-- исключить таблицы по имени
excluding table names like 'sys%' in schema 'dbo'

-- отобрать таблицы по имени
including only table names like 'cache%' in schema 'dbo'

-- создавать таблицы в схеме с новым именем
alter schema 'dbo' rename to 'dbo2'

set mssql parameters textsize to '104857600'

-- задать опции
with create schemas, include drop, truncate, disable triggers, create tables, create indexes, drop indexes, reset sequences
 
-- настроить параметры работы по нагрузке при переносе данных
set work_mem to '16MB', maintenance_work_mem to '512MB', timezone to 'UTC'

-- задать правила преобразования типов
cast type bigint to bigint, type geometry to bytea, type geography to bytea, type smallmoney to money, type tinyint to smallint, type smallint to smallint, type date to date
 
-- если схема dbo существует, то удалить ее
before load do $$ drop schema if exists dbo2 cascade; $$, $$
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
$$