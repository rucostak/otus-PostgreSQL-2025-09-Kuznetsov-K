--alter system set max_connections = '200';
alter system set listen_addresses = '*';

alter system set max_worker_processes = '2';
alter system set max_parallel_workers = '2';
alter system set max_parallel_workers_per_gather = '1';
alter system set max_parallel_maintenance_workers = '1';

alter system set shared_buffers = '1638MB';
alter system set effective_cache_size = '2GB';

alter system set work_mem = '32MB';
alter system set maintenance_work_mem = '320MB';
alter system set temp_buffers = '64mB';
alter system set temp_buffers = '64MB';
    
--alter system set random_page_cost = '4';                -- Оставляем значение 4, поскольку в ВМ тип дисков = HDD
--alter system set effective_io_concurrency = '1';        -- Оставляем значение 4, поскольку данные кластера располагается на единственном диске и тип диска = HDD
--alter system set checkpoint_completion_target = '0.9';  -- Оставляем значение 4, поскольку в ВМ тип дисков = HDD
alter system set fsync = 'off';                         -- Отключаем принудительный сброс кэша ОС, чтобы минизировать обращение к диску
alter system set synchronous_commit = 'off';            -- Отключаем подтверждение транзакции после окончания записи изменений на диск

alter system reset random_page_cost;

select name, setting, context, sourcefile, pending_restart from pg_settings where pending_restart = true;
select name, setting, unit, context, sourcefile from pg_settings where sourcefile = '/var/lib/postgresql/18/main/postgresql.auto.conf';

select pg_reload_conf();

select setting from pg_settings where setting like '%postgres%';

select setting || ' x ' || coalesce(unit, 'units')
from pg_settings
where name = 'temp_buffers';


ALTER ROLE postgres SET max_parallel_maintenance_workers TO '1';
ALTER ROLE postgres SET max_parallel_workers TO '2';
ALTER ROLE postgres SET max_parallel_workers_per_gather TO '1';

alter system reset max_parallel_workers;
alter system reset max_parallel_workers_per_gather;
alter system reset max_parallel_maintenance_workers;
alter system reset temp_buffers;

alter system reset all;

ALTER ROLE postgres
    RESET max_parallel_maintenance_workers;
ALTER ROLE postgres
    RESET max_parallel_workers;
ALTER ROLE postgres
    RESET max_parallel_workers_per_gather;


select coalesce(role.rolname, 'database wide') as role,
       coalesce(db.datname, 'cluster wide') as database,
       setconfig as what_changed
from pg_db_role_setting role_setting
left join pg_roles role on role.oid = role_setting.setrole
left join pg_database db on db.oid = role_setting.setdatabase;

ALTER ROLE postgres IN DATABASE testdb SET temp_buffers TO '8192';
ALTER ROLE postgres IN DATABASE testdb SET temp_buffers TO '4096';

select current_setting('temp_buffers');
select current_setting('max_parallel_workers');

create database testdb;

alter database template1 refresh collation version;

ALTER ROLE postgres IN DATABASE testdb2 SET max_parallel_workers TO '1';

drop database testdb2;

alter system set checkpoint_completion_target = '0.5';  -- Оставляем значение 4, поскольку в ВМ тип дисков = HDD
select pg_reload_conf();
select current_setting('checkpoint_completion_target');
select current_setting('synchronous_commit');

/*
listen_addresses = '*'
max_worker_processes = '2'
max_parallel_workers = '2'
max_parallel_workers_per_gather = '1'
max_parallel_maintenance_workers = '1'
shared_buffers = '1638MB'
effective_cache_size = '2GB'
work_mem = '32MB'
maintenance_work_mem = '320MB'
temp_buffers = '64MB'
fsync = 'off'
synchronous_commit = 'off'
checkpoint_completion_target = '0.5'
random_page_cost = '2'
effective_io_concurrency = '1'
*/