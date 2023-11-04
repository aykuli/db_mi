# Глава 15

## Common table expression CTE - общее табличное выражение

```sql 
WITH RECURSIVE trans_closure (ancestor, descendant, level) AS (
  SELECT p_c.p, p_c.c, 1 FROM p_c
  UNION ALL
  SELECT p_c.p, ts.descendant, ts.level + 1 FROM p_c
  JOIN trans_closure ts ON p_c.c=ts.ancestor
) SELECT * FROM trans_closure;


with recursive a as (
  select  p, 1 level from p_c
  union
  select p, level +1  from a where p = 4
 ) select * from a limit 10;
```

## Оконные функции

```sql
CREATE VIEW per_hour AS (
  SELECT  date_part('hour', f.scheduled_departure) as hour,
          count(ticket_no) passengers_cnt,
          count(DISTINCT f.flight_id) flights_cnt
  FROM flights f
    JOIN ticket_flights t ON f.flight_id=t.flight_id
  WHERE f.departure_airport = 'SVO'
  AND f.scheduled_departure >= '2017-08-02'::date
  AND f.scheduled_departure < '2017-08-03'::date
  GROUP BY date_part('hour', f.scheduled_departure)
);

SELECT *, AVG(passengers_cnt) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FROM per_hour;

SELECT *, SUM(passengers_cnt) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) FROM per_hour;
```

## Материализованные представления

```sql
CREATE MATERIALIZED VIEW per_hour AS (
  SELECT  date_part('hour', f.scheduled_departure) as hour,
          count(ticket_no) passengers_cnt,
          count(DISTINCT f.flight_id) flights_cnt
  FROM flights f
    JOIN ticket_flights t ON f.flight_id=t.flight_id
  WHERE f.departure_airport = 'SVO'
  AND f.scheduled_departure >= '2017-08-02'::date
  AND f.scheduled_departure < '2017-08-03'::date
  GROUP BY date_part('hour', f.scheduled_departure)
);

select * from ticket_flights where ticket_no = '0005435282208';
   ticket_no   | flight_id | fare_conditions |  amount  
---------------+-----------+-----------------+----------
 0005435282208 |     36094 | Business        | 99800.00
(1 row)

demo=# SELECT * FROM per_hour;
 hour | passengers_cnt | flights_cnt 
------+----------------+-------------
    6 |            484 |           5
    7 |            381 |           4
    8 |            540 |           7
    9 |            534 |           7
   10 |            157 |           4
   11 |            217 |           4
   13 |            273 |           4
   14 |            421 |           3
   15 |            237 |           3
   16 |             30 |           1
(10 rows)

delete from boarding_passes where ticket_no = '0005435282208';
delete from ticket_flights where ticket_no = '0005435282208';
delete from tickets where ticket_no = '0005435282208';

SELECT * FROM per_hour;
 hour | passengers_cnt | flights_cnt 
------+----------------+-------------
    6 |            484 |           5
    7 |            380 |           4
    8 |            540 |           7
    9 |            534 |           7
   10 |            157 |           4
   11 |            217 |           4
   13 |            273 |           4
   14 |            421 |           3
   15 |            237 |           3
   16 |             30 |           1
(10 rows)
```

