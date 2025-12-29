-- ДЗ тема: триггеры, поддержка заполнения витрин

DROP SCHEMA IF EXISTS pract_functions CASCADE;
CREATE SCHEMA pract_functions;

SET search_path = pract_functions, public;

-- товары:
CREATE TABLE goods
(
    goods_id    integer PRIMARY KEY,
    good_name   varchar(63) NOT NULL,
    good_price  numeric(12, 2) NOT NULL CHECK (good_price > 0.0)
);
INSERT INTO goods (goods_id, good_name, good_price)
VALUES 	(1, 'Спички хозайственные', .50),
		(2, 'Автомобиль Ferrari FXX K', 185000000.01);

-- Продажи
CREATE TABLE sales
(
    sales_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    good_id     integer REFERENCES goods (goods_id),
    sales_time  timestamp with time zone DEFAULT now(),
    sales_qty   integer CHECK (sales_qty > 0)
);

INSERT INTO sales (good_id, sales_qty) VALUES (1, 10), (1, 1), (1, 120), (2, 1);

-- отчет:
SELECT G.good_name, sum(G.good_price * S.sales_qty)
FROM goods G
INNER JOIN sales S ON S.good_id = G.goods_id
GROUP BY G.good_name;

-- с увеличением объёма данных отчет стал создаваться медленно
-- Принято решение денормализовать БД, создать таблицу
CREATE TABLE good_sum_mart
(
	good_name   varchar(63) NOT NULL,
	sum_sale	numeric(16, 2)NOT NULL
);

-- Создать триггер (на таблице sales) для поддержки.
-- Подсказка: не забыть, что кроме INSERT есть еще UPDATE и DELETE

-- Заполняем таблицу витрины данными отчёта
INSERT INTO good_sum_mart (good_name, sum_sale)
	SELECT G.good_name, sum(G.good_price * S.sales_qty)
	FROM goods G
	INNER JOIN sales S ON S.good_id = G.goods_id
	GROUP BY G.good_name;

-- Проверяем содержимое таблицы
SELECT * FROM good_sum_mart;

-- Создаём триггерную функцию, которая сможет работать как в построчном режиме, так и с командами целиком.
CREATE OR REPLACE FUNCTION tf_good_sum_mart()
RETURNS trigger
AS
$$
declare
data_str text = '';
BEGIN
    IF TG_LEVEL = 'ROW' THEN
        CASE TG_OP
            WHEN 'DELETE'
                THEN
					WITH s_dif AS (SELECT g.good_name, OLD.sales_qty * g.good_price as diff FROM goods g WHERE g.goods_id = OLD.good_id)
					MERGE INTO good_sum_mart m
					USING s_dif s
					ON s.good_name = m.good_name
					WHEN NOT MATCHED THEN
						INSERT VALUES(s.good_name, s.diff)
					WHEN MATCHED AND s.diff != 0 THEN
						UPDATE SET sum_sale = m.sum_sale - s.diff;
					data_str = OLD::text;
            WHEN 'UPDATE'
                THEN
					WITH o AS (SELECT g.good_name, OLD.sales_qty * g.good_price as old_sum FROM goods g WHERE g.goods_id = OLD.good_id),
						n AS (SELECT g.good_name, NEW.sales_qty * g.good_price as new_sum FROM goods g WHERE g.goods_id = NEW.good_id),
						s_dif AS (
							SELECT COALESCE(o.good_name, n.good_name) as good_name,
								COALESCE(n.new_sum, 0::numeric(12,2)) - COALESCE(o.old_sum, 0::numeric(12,2)) as diff
							FROM o
								FULL OUTER JOIN n
									ON o.good_name = n.good_name)
					MERGE INTO good_sum_mart m
					USING s_dif s
					ON s.good_name = m.good_name
					WHEN NOT MATCHED THEN
						INSERT VALUES(s.good_name, s.diff)
					WHEN MATCHED AND s.diff != 0 THEN
						UPDATE SET sum_sale = m.sum_sale + s.diff;
					data_str = 'UPDATE FROM ' || OLD || ' TO ' || NEW;
            WHEN 'INSERT'
                THEN
					WITH s_dif AS (SELECT g.good_name, NEW.sales_qty * g.good_price as diff FROM goods g WHERE g.goods_id = NEW.good_id)
					MERGE INTO good_sum_mart m
					USING s_dif s
					ON s.good_name = m.good_name
					WHEN NOT MATCHED THEN
						INSERT VALUES(s.good_name, s.diff)
					WHEN MATCHED AND s.diff != 0 THEN
						UPDATE SET sum_sale = m.sum_sale + s.diff;
					data_str = NEW::text;
        END CASE;
    END IF;
	IF TG_LEVEL = 'STATEMENT' THEN
		CASE TG_OP
			WHEN 'DELETE'
				THEN WITH s_dif AS (
						SELECT g.good_name, SUM(o.sales_qty * g.good_price) as diff
						FROM tbl_old o
							INNER JOIN goods g ON o.good_id = g.goods_id
						GROUP BY g.good_name)
					MERGE INTO good_sum_mart m
					USING s_dif s
					ON s.good_name = m.good_name
					WHEN NOT MATCHED THEN
						INSERT VALUES(s.good_name, s.diff)
					WHEN MATCHED AND s.diff != 0 THEN
						UPDATE SET sum_sale = m.sum_sale - s.diff;
			WHEN 'UPDATE'
				THEN WITH --ot (
						-- SELECT g.good_name, sum(o.sales_qty * g.good_price) as old_sum
						-- FROM tbl_old o
						-- 	INNER JOIN goods g
						-- 		ON o.good_id = g.goods_id
						-- GROUP BY g.good_name),
						-- nt (
						-- SELECT g.good_name, sum(n.sales_qty * g.good_price) as new_sum
						-- FROM tbl_new n
						-- 	INNER JOIN goods g
						-- 		ON n.good_id = g.goods_id
						-- GROUP BY g.good_name),	-- друзья гармонии снова в обмороке: вложенные CTE не работают в триггерных функциях
						s_dif AS (
						SELECT COALESCE(ot.good_name, nt.good_name) as good_name,
							COALESCE(nt.new_sum, 0) - COALESCE(ot.old_sum) as diff
						FROM (
						SELECT g.good_name, sum(o.sales_qty * g.good_price) as old_sum
						FROM tbl_old o
							INNER JOIN goods g
								ON o.good_id = g.goods_id
						GROUP BY g.good_name) ot
							FULL OUTER JOIN (
						SELECT g.good_name, sum(n.sales_qty * g.good_price) as new_sum
						FROM tbl_new n
							INNER JOIN goods g
								ON n.good_id = g.goods_id
						GROUP BY g.good_name, g.good_price) nt
								ON ot.good_name = nt.good_name)
					MERGE INTO good_sum_mart m
					USING s_dif s
					ON s.good_name = m.good_name
					WHEN NOT MATCHED THEN
						INSERT VALUES(s.good_name, s.diff)
					WHEN MATCHED AND s.diff != 0 THEN
						UPDATE SET sum_sale = m.sum_sale + s.diff;
			WHEN  'INSERT'
				THEN WITH s_dif AS (
						SELECT g.good_name, SUM(n.sales_qty * g.good_price) as diff
						FROM tbl_new n
							INNER JOIN goods g ON n.good_id = g.goods_id
						GROUP BY g.good_name)
					MERGE INTO good_sum_mart m
					USING s_dif s
					ON s.good_name = m.good_name
					WHEN NOT MATCHED THEN
						INSERT VALUES(s.good_name, s.diff)
					WHEN MATCHED AND s.diff != 0 THEN
						UPDATE SET sum_sale = m.sum_sale + s.diff;
		END CASE;
	END IF;

    RAISE NOTICE E'\nG_TABLE_NAME = %\nTG_WHEN = %\nTG_OP = %\nTG_LEVEL = %\ndata_str: %\n -------------', TG_TABLE_NAME, TG_WHEN, TG_OP, TG_LEVEL, data_str;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql
	SET search_path = pract_functions, public;

-- Создаём триггеры "после" на таблице sales, сначала в построчном режиме
CREATE TRIGGER trg_ins_sales
AFTER INSERT
ON sales
FOR EACH ROW
EXECUTE FUNCTION tf_good_sum_mart();

CREATE TRIGGER trg_upd_sales
AFTER UPDATE
ON sales
FOR EACH ROW
EXECUTE FUNCTION tf_good_sum_mart();

CREATE TRIGGER trg_del_sales
AFTER DELETE
ON sales
FOR EACH ROW
EXECUTE FUNCTION tf_good_sum_mart();

-- Чем такая схема (витрина+триггер) предпочтительнее отчета, создаваемого "по требованию" (кроме производительности)?
-- Подсказка: В реальной жизни возможны изменения цен.
-- Ответ: при работе в режиме накопления фактов продаж в итогах в разрезе товаров сохраняется стоимость, действующая на момент регистрации продажи.
-- Однако, следует быть осторожным с корректировкой (изменением или удалением) после изменения цены в справочнике товаров, поскольку итог изменится на текущую стоимость, а не действовавшую на момент регистрации.


-- Предположим, нам показалось, что продали не авто, а коробок спичек и мы корректируем идентификатор товара в таблице продаж.
update sales set good_id = 1 where sales_id = 4;

-- Видим сработавший триггер на обновление для одной строки и изменившиеся итоги на витрине: по авто сумма = 0
select * from good_sum_mart;

-- Нет, всё-таки мы продавали автомобили!
update sales set good_id = 2 where good_id = 1;

-- Теперь триггер на обновление сработал 4 раза и сумма впечатляет.
select * from good_sum_mart;

-- Регистрируем продажи ещё 2х автомобилей и 500 коробков спичек.
insert into sales(good_id, sales_qty) values(2, 2), (1, 500);

-- Триггер на вставку сработал дважды, итоги по товарам обновлены.
select * from good_sum_mart;

-- Удалим продажи автомобилей.
delete from sales where good_id = 2;

-- Триггер на удаление сработал 5 раз, на витрине осталась сумма продаж 500 коробков спичек.
select * from good_sum_mart;

-- Проверим работу триггерной функции с командами.
-- Удалим триггеры.
DROP TRIGGER IF EXISTS trg_ins_sales ON sales;
DROP TRIGGER IF EXISTS trg_upd_sales ON sales;
DROP TRIGGER IF EXISTS trg_del_sales ON sales;

-- Создаём триггеры для каждого типа команды и объявляем псевдонимы для переходных таблиц
CREATE TRIGGER trg_ins_sales
AFTER INSERT
ON sales
REFERENCING
    NEW TABLE AS tbl_new
FOR EACH STATEMENT
EXECUTE FUNCTION tf_good_sum_mart();

CREATE TRIGGER trg_upd_sales
AFTER UPDATE
ON sales
REFERENCING
    OLD TABLE AS tbl_old
    NEW TABLE AS tbl_new
FOR EACH STATEMENT
EXECUTE FUNCTION tf_good_sum_mart();

CREATE TRIGGER trg_del_sales
AFTER DELETE
ON sales
REFERENCING
    OLD TABLE AS tbl_old
FOR EACH STATEMENT
EXECUTE FUNCTION tf_good_sum_mart();

-- Регистрируем продажи ещё автомобиля и 100 коробков спичек.
insert into sales(good_id, sales_qty) values(2, 1), (1, 100);

-- Видим, что триггер на вставку сработал 1 раз в режиме команды. Итоги в витрине пересчитались по всем товарам.
select * from good_sum_mart;

-- Изменим количество проданных спичек в последней операции 
update sales set sales_qty = 200 where good_id = 1 and sales_qty = 100;

-- Видим, что триггер на изменение сработал 1 раз в режиме команды. Итоги в витрине пересчитались по спичкам.
select * from good_sum_mart;

-- Удалим все операции продажи спичек.
delete from sales where good_id = 1;

-- Видим, что триггер на удаление сработал 1 раз в режиме команды. Итоги в витрине пересчитались по спичкам, сумма = 0.
select * from good_sum_mart;

