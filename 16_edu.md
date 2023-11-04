# PL/pgSQL

## Functions

```sql
CREATE OR REPLACE FUNCTION hello(p TEXT) RETURNS TEXT
LANGUAGE PLPGSQL AS $$
DECLARE 
  v TEXT;
BEGIN
  v := 'hello, ';
  RETURN v || p || '! How are you?';
END;
$$;

SELECT hello('ff');
          hello          
-------------------------
 hello, ff! How are you?
(1 row)


CREATE TYPE airport AS (code char(3), name text);

CREATE OR REPLACE FUNCTION airport_set() RETURNS SETOF airport
LANGUAGE plpgsql AS $$
DECLARE
  v record;
BEGIN
  FOR v IN SELECT * FROM airports
  LOOP
    RETURN NEXT ROW(v.airport_code, v.airport_name)::airport;
  END LOOP;
END;
$$;

SELECT * FROM airport_set();
```

## Procedures

```sql
CREATE OR REPLACE PROCEDURE make_booking(book_ref char(6), amount numeric(10, 2)) LANGUAGE SQL AS $$
  insert into bookings (book_ref, book_date,total_amount) values (book_ref, now(), amount);
$$;

CALL make_booking('33333F', 10000.01);
```