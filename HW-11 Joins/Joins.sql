--create database hw11;
--drop schema if exists warehouse cascade;

create schema warehouse;

set search_path = warehouse,"$user",public;

/*
 * Абстрактный пример регистрации складских операций
 */

-- Производители
create table manufacturers (manufacturer_id integer not null, manufacturer_name varchar(128) not null);
alter table manufacturers add constraint manufacturers_pk primary key (manufacturer_id);
alter table manufacturers add constraint manufacturers_unique unique (manufacturer_name);

-- Единицы измерения
create table units (unit_id integer not null, unit_name varchar(64) not null);
alter table units add constraint units_pk primary key (unit_id);
alter table units add constraint units_unique unique (unit_name);

-- Товары
create table goods (goods_id integer not null, manufacturer_id integer, goods_name varchar(256) not null, unit_id integer, weight numeric);
alter table goods add constraint goods_pk primary key (goods_id);
create index goods_manufacturer_id_idx on goods (manufacturer_id);
create index goods_unit_id_idx on goods (unit_id);
alter table goods add constraint goods_manufacturers_fk foreign key (manufacturer_id) references manufacturers(manufacturer_id);
alter table goods add constraint goods_units_fk foreign key (unit_id) references units(unit_id);

-- Места хранения
create table storages (storage_id integer not null, storage_name varchar(64) null, capacity integer);
alter table storages add constraint storages_pk primary key (storage_id);
alter table storages add constraint storages_unique unique (storage_name);

-- Складские операции
create table operations (operation_id integer generated always as identity not null, goods_id integer not null, storage_id integer not null, quantity numeric not null);
alter table operations add constraint operations_pk primary key (operation_id);
create index operations_goods_id_idx on operations (goods_id);
create index operations_storage_id_idx on operations (storage_id);
alter table operations add constraint operations_goods_fk foreign key (goods_id) references goods(goods_id);
alter table operations add constraint operations_storages_fk foreign key (storage_id) references storages(storage_id);

-- Заполнение справочника производителей
insert into manufacturers (manufacturer_id, manufacturer_name)
	select generate_series, 'MF ' || generate_series::varchar(128) from (select generate_series(1, 100));

-- Заполнение справочика мест хранения
insert into storages (storage_id, storage_name, capacity)
	values(1, 'Storage 1', 100000), (2, 'Storage 2', NULL), (3, 'Storage 3', 450.75);

-- Заполнение справочника единиц хранения
insert into units (unit_id, unit_name)
	values(1, 'kg'), (2, 'oz.'), (3, 'pcs.'), (4, 'tn');

-- Заполнение справочника товаров (часть производителей и единиц измерения оставим неиспользуемыми)
insert into goods (goods_id, manufacturer_id, goods_name, unit_id, weight)
	select generate_series, floor(random() * (100 - 1 + 1) + 1)::integer, 'Item ' || generate_series::varchar(128),
		case mod(generate_series, 3) when 0 then null else floor(random() * (3 - 1 + 1) + 1)::integer end case,
		(random() * (1000 - 50 + 1) + 50)::numeric(7,3)
	from (select generate_series(1, 300));

-- Заполнение регистра операций на складе поступлениями (по одному товару каждого производителя, весовые товары )
insert into operations (goods_id, storage_id, quantity)
	select t.goods_id, floor(random() * (3 - 1 + 1) + 1)::integer, 
		case when unit_id < 3 then weight * (floor(random() * (1000 - 1 + 1) + 1)) else floor(random() * (1000 - 1 + 1) + 1) end case
	from (
		select *, row_number() over(partition by manufacturer_id order by goods_id desc) as rownumber from goods
		) t
	where t.rownumber = 1;
/*
 * -- Такая печальная печаль из-за очередной "детской болезни" - нельзя переименовать атрибут в отношении, если атрибут содержит CASE
 insert into operations (goods_id, storage_id, quantity)
	select goods_id, floor(random() * (3 - 1 + 1) + 1)::integer,
		weight * (floor(random() * (1000 - 1 + 1) + 1))
	from (
		select goods_id, case when unit_id < 3 then weight else 1::numeric end case as weight, row_number() over(partition by manufacturer_id order by goods_id desc) as rownumber from goods;
		) t
	where t.rownumber = 1;
*/

-- Заполнение регистра операций на складе списаниями (количеством не более количества поступления)
do $$
declare cnt integer = 20;	-- остановим списание как только количество добавляемых операций списания станет меньше 20 
begin
while cnt >= 20 loop
	begin
	insert into operations (goods_id, storage_id, quantity)
		select t.goods_id, storage_id, case when g.unit_id < 3 then quantity else floor(quantity) end case
		from (
				select goods_id, storage_id, ((random(0, sum(quantity)) * 0.03) * -1)::numeric(10,3) as quantity	-- чтобы сгенирить больше операций сделаем небольшое количество списания (3%)
				from operations
				group by goods_id, storage_id
				having sum(quantity) > 0
			) t
				inner join goods g
					on t.goods_id = g.goods_id
		where quantity <= -1;
	get diagnostics cnt = row_count;
	raise notice 'rows %', cnt;
	end;
end loop;
end;
$$

-- 1. Реализовать прямое соединение двух или более таблиц
select *
from manufacturers m
	inner join goods g
		on m.manufacturer_id = g.manufacturer_id
	inner join units u
		on g.unit_id = u.unit_id;

-- 2. Реализовать левостороннее (или правостороннее) соединение двух или более таблиц
select *
from manufacturers m
	left outer join goods g
		on m.manufacturer_id = g.manufacturer_id
	left outer join units u
		on g.unit_id = u.unit_id
where g.goods_id is null
	or u.unit_id is null;

-- 3. Реализовать кросс соединение двух или более таблиц
select *
from manufacturers m
	cross join goods g
	cross join units u;

-- 4. Реализовать полное соединение двух или более таблиц
select *
from manufacturers m
	full outer join goods g
		on m.manufacturer_id = g.manufacturer_id
	full outer join units u
		on g.unit_id = u.unit_id;

-- 5. Реализовать запрос, в котором будут использованы разные типы соединений
select *
from operations o
	natural right outer join storages s
	natural right outer join goods g
	natural left outer join units u
	natural join manufacturers m;

explain (costs, verbose, format json, analyze)
with outboundrest as (
	select o1.operation_id, sum(o0.quantity) as rest
	from operations o0	-- предыдущие и текущая операции
		inner join operations o1 -- текущая операция
			on o0.goods_id = o1.goods_id
				and o0.storage_id = o1.storage_id
	where o0.operation_id <= o1.operation_id
	group by o1.operation_id, o1.goods_id, o1.storage_id
)
select *
from operations o
	natural right outer join storages s
	natural right outer join goods g
	natural left outer join units u
	natural join manufacturers m
	left outer join outboundrest obr using(operation_id)
where g.goods_id = 285
order by obr.operation_id;

explain (costs, verbose, format json, analyze)
select *
from operations o
	natural right outer join storages s
	natural right outer join goods g
	natural left outer join units u
	natural join manufacturers m
	left outer join lateral (
		select o.operation_id, sum(o0.quantity) as rest
		from operations o0	-- предыдущие и текущая операции
		where o0.operation_id <= o.operation_id
			and o0.goods_id = o.goods_id
			and o0.storage_id = o.storage_id
		group by o.operation_id, o.goods_id, o.storage_id
	) obr using(operation_id)
where g.goods_id = 285
order by obr.operation_id;


select storage_id, sum(quantity) as rest from operations group by storage_id order by rest;
select goods_id, storage_id, sum(quantity) as rest from operations group by storage_id, goods_id order by rest;

select *
from operations o
	right outer join goods g using(goods_id)
	inner join manufacturers m on g.manufacturer_id = m.manufacturer_id
	;
