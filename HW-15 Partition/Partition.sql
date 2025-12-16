-- Создаём сеционированную таблицу полётов

CREATE TABLE IF NOT EXISTS bookings.segments_range
(
    ticket_no text COLLATE pg_catalog."default" NOT NULL,
    flight_id integer NOT NULL,
    fare_conditions text COLLATE pg_catalog."default" NOT NULL,
    price numeric(10,2) NOT NULL,
    CONSTRAINT segments_range_pkey PRIMARY KEY (ticket_no, flight_id),
    CONSTRAINT segments_range_flight_id_fkey FOREIGN KEY (flight_id)
        REFERENCES bookings.flights (flight_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT segments_range_ticket_no_fkey FOREIGN KEY (ticket_no)
        REFERENCES bookings.tickets (ticket_no) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT segments_range_fare_conditions_check CHECK (fare_conditions = ANY (ARRAY['Economy'::text, 'Comfort'::text, 'Business'::text])),
    CONSTRAINT segments_range_price_check CHECK (price >= 0::numeric)
)partition by range (flight_id);

COMMENT ON TABLE bookings.segments_range
    IS 'Flight segment (leg)';
COMMENT ON COLUMN bookings.segments_range.ticket_no
    IS 'Ticket number';
COMMENT ON COLUMN bookings.segments_range.flight_id
    IS 'Flight ID';
COMMENT ON COLUMN bookings.segments_range.fare_conditions
    IS 'Travel class';
COMMENT ON COLUMN bookings.segments_range.price
    IS 'Travel price';

CREATE INDEX IF NOT EXISTS segments_range_flight_id_idx
    ON bookings.segments_range USING btree
    (flight_id ASC NULLS LAST)
    WITH (fillfactor=100, deduplicate_items=True);

-- Создаём секции и заполняем данными полётов посекционно
DO
$$
DECLARE
    v_from          integer;
    v_to	        integer;
    query           text;
BEGIN
    FOR v_from, v_to
    IN (
        select (flight_id / 1000) * 1000 as range_from, ((flight_id / 1000) + 1) * 1000 as range_to
		from bookings.segments group by (flight_id / 1000) order by range_from
        )
    LOOP    
        query = format  ($frmt$
                        CREATE TABLE bookings.segments_range_%s
                        PARTITION OF bookings.segments_range
                        FOR VALUES FROM (%s) TO (%s);
                        $frmt$,
						to_char(v_to, '000000000'), v_from,v_to);
		query = replace(query, 'range_ 0', 'range_0'); -- друзья гармонии валяются в обмороке :)

        RAISE NOTICE '%', query;
        EXECUTE query;

        query = format  ($frmt$
                        insert into bookings.segments_range
                        	select * from bookings.segments where flight_id >= %s and flight_id < %s;
                        $frmt$,
						v_from, v_to);

        RAISE NOTICE '%', query;
        EXECUTE query;
    END LOOP;
END;
$$;

-- Создаём секционированную таблицу регистрации на рейс
CREATE TABLE IF NOT EXISTS bookings.boarding_passes_range
(
    ticket_no text COLLATE pg_catalog."default" NOT NULL,
    flight_id integer NOT NULL,
    seat_no text COLLATE pg_catalog."default" NOT NULL,
    boarding_no integer,
    boarding_time timestamp with time zone,
    CONSTRAINT boarding_passes_range_pkey PRIMARY KEY (ticket_no, flight_id),
    CONSTRAINT boarding_passes_range_flight_id_boarding_no_key UNIQUE (flight_id, boarding_no),
    CONSTRAINT boarding_passes_range_flight_id_seat_no_key UNIQUE (flight_id, seat_no),
    CONSTRAINT boarding_passes_range_ticket_no_flight_id_fkey FOREIGN KEY (ticket_no, flight_id)
        REFERENCES bookings.segments_range (ticket_no, flight_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
) partition by range (flight_id);

COMMENT ON TABLE bookings.boarding_passes_range
    IS 'Boarding passes';
COMMENT ON COLUMN bookings.boarding_passes_range.ticket_no
    IS 'Ticket number';
COMMENT ON COLUMN bookings.boarding_passes_range.flight_id
    IS 'Flight ID';
COMMENT ON COLUMN bookings.boarding_passes_range.seat_no
    IS 'Seat number';
COMMENT ON COLUMN bookings.boarding_passes_range.boarding_no
    IS 'Boarding pass number';
COMMENT ON COLUMN bookings.boarding_passes_range.boarding_time
    IS 'Boarding time';

-- Создаём секции и заполняем данными регистрации на рейс посекционно
DO
$$
DECLARE
    v_from          integer;
    v_to	        integer;
    query           text;
BEGIN
    FOR v_from, v_to
    IN (
        select (flight_id / 1000) * 1000 as range_from, ((flight_id / 1000) + 1) * 1000 as range_to
		from bookings.boarding_passes group by (flight_id / 1000) order by range_from
        )
    LOOP    
        query = format  ($frmt$
                        CREATE TABLE bookings.boarding_passes_range_%s
                        PARTITION OF bookings.boarding_passes_range
                        FOR VALUES FROM (%s) TO (%s);
                        $frmt$,
						to_char(v_to, '000000000'), v_from,v_to);
		query = replace(query, 'range_ 0', 'range_0'); -- друзья гармонии валяются в обмороке :)

        RAISE NOTICE '%', query;
        EXECUTE query;

        query = format  ($frmt$
                        insert into bookings.boarding_passes_range
                        	select * from bookings.boarding_passes where flight_id >= %s and flight_id < %s;
                        $frmt$,
						v_from, v_to);

        RAISE NOTICE '%', query;
        EXECUTE query;
    END LOOP;
END;
$$;
