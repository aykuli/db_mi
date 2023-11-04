# Шауэрман Айнур

## Упражнение 4.3

Найдите все самолеты c максимальной дальностью полета:

1) либо больше 10 000 км, либо меньше 4 000 км;
2) больше 6 000 км, а название не заканчивается на «100».
Обратите внимание на порядок следования предложений WHERE и FROM.

```sql
  SELECT * FROM aircrafts WHERE range < 4000 OR range > 10000;

 aircraft_code |        model        | range 
---------------+---------------------+-------
 773           | Боинг 777-300       | 11100
 SU9           | Сухой Суперджет-100 |  3000
 CN1           | Сессна 208 Караван  |  1200
 CR2           | Бомбардье CRJ-200   |  2700
(4 rows)


SELECT * FROM aircrafts WHERE range > 6000 AND model NOT LIKE '%100';
 aircraft_code |     model     | range 
---------------+---------------+-------
 773           | Боинг 777-300 | 11100
 763           | Боинг 767-300 |  7900
(2 rows)
```

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

## Упражнение 4.9

Выведите номера мест, оставшихся свободными в рейсах из
Анапы (AAQ) в Шереметьево (SVO), вместе с номером рейса и его датой.

```sql
SELECT * FROM (
  SELECT f1.flight_id, f1.scheduled_departure, s1.seat_no FROM seats s1
    INNER JOIN flights f1 ON f1.aircraft_code = s1.aircraft_code
    WHERE f1.departure_airport='AAQ' 
      AND f1.arrival_airport='SVO'
  
  EXCEPT

  SELECT f2.flight_id, f2.scheduled_departure, s2.seat_no FROM seats s2
    INNER JOIN flights f2 ON f2.aircraft_code = s2.aircraft_code
    WHERE s2.seat_no IN (
      SELECT seat_no FROM boarding_passes bp 
        WHERE bp.flight_id=f2.flight_id
      ) 
      AND f2.departure_airport='AAQ' 
      AND f2.arrival_airport='SVO'
) q order by q.flight_id;
```

```shell
flight_id |  scheduled_departure   | seat_no 
-----------+------------------------+---------    
    ...  -- рейс 136115 не имеет boarding_passes;
    136115 | 2017-08-24 10:05:00+00 | 11C
    136115 | 2017-08-24 10:05:00+00 | 7E
    136115 | 2017-08-24 10:05:00+00 | 7B
    136116 | 2017-08-05 10:05:00+00 | 3D
    136116 | 2017-08-05 10:05:00+00 | 2C
    136116 | 2017-08-05 10:05:00+00 | 4F
    136116 | 2017-08-05 10:05:00+00 | 21C
    136116 | 2017-08-05 10:05:00+00 | 10B
    136116 | 2017-08-05 10:05:00+00 | 8D
    136116 | 2017-08-05 10:05:00+00 | 9A
    136116 | 2017-08-05 10:05:00+00 | 7D
    136116 | 2017-08-05 10:05:00+00 | 14B
    136116 | 2017-08-05 10:05:00+00 | 12D
    136117 | 2016-11-11 10:05:00+00 | 11C
    136117 | 2016-11-11 10:05:00+00 | 5C
    136117 | 2016-11-11 10:05:00+00 | 20B
    136117 | 2016-11-11 10:05:00+00 | 7C
    136117 | 2016-11-11 10:05:00+00 | 5D
    136117 | 2016-11-11 10:05:00+00 | 5A
    136117 | 2016-11-11 10:05:00+00 | 9E
    136118 | 2017-09-06 10:05:00+00 | 7A
    136118 | 2017-09-06 10:05:00+00 | 16A
    136118 | 2017-09-06 10:05:00+00 | 22C
    136118 | 2017-09-06 10:05:00+00 | 4F
    136118 | 2017-09-06 10:05:00+00 | 20A
    136118 | 2017-09-06 10:05:00+00 | 8B
    136118 | 2017-09-06 10:05:00+00 | 23A
    136118 | 2017-09-06 10:05:00+00 | 15B
--More--
```

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

## Упражнение 4.4 Засчитано

Определите номера и время отправления всех рейсов, при-
бывших в аэропорт назначения не вовремя.

```sql
SELECT flight_no, actual_departure FROM flights 
  WHERE scheduled_arrival != actual_arrival;

 flight_no |    actual_departure    
-----------+------------------------
 PG0403    | 2017-06-13 08:29:00+00
 PG0404    | 2017-06-13 16:11:00+00
 PG0405    | 2017-06-13 06:38:00+00
 PG0402    | 2017-02-10 09:30:00+00
--More--


```

## Упражнение 4.7 Засчитано

Напечатанный посадочный талон должен содержать фамилию и имя пассажира, коды аэропортов вылета и прилета, дату и время вылета и прилета по расписанию, номер места в салоне самолета. Напишите запрос, выводящий всю необходимую информацию для полученных посадочных талонов на рейсы, которые еще не вылетели.

```sql
SELECT  t.passenger_name,
        f.departure_airport,
        f.arrival_airport,
        to_char(scheduled_departure, 'DD Mon YYYY HH24:MI') scheduled_departure,
        to_char(scheduled_arrival, 'DD Mon YYYY HH24:MI') scheduled_arrival, 
        seat_no
FROM boarding_passes bp
  INNER JOIN tickets t ON t.ticket_no=bp.ticket_no
  INNER JOIN flights f ON f.flight_id=bp.flight_id
    WHERE scheduled_departure > '2017-08-15 17:55'::timestamp with time zone;
```


## Упражнение 4.11 Засчитано

Напишите запрос, возвращающий среднюю стоимость авиабилета в каждом из классов перевозки. Модифицируйте его таким образом, чтобы было видно, какому классу какое значение соответствует.

```sql
SELECT AVG(amount) avg_ticket_cost, fare_conditions FROM ticket_flights 
  GROUP BY fare_conditions;

  avg_ticket_cost   | fare_conditions 
--------------------+-----------------
 51557.231464323396 | Business
 32724.546136534134 | Comfort
 16031.309072998395 | Economy
(3 rows)

```


<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

## Упражнение 4.15 Засчитано

В результате еще одной модернизации в самолетах «Аэробус
A319» (код 319) ряды кресел с шестого по восьмой были переведены в разряд бизнес-класса. Измените таблицу одним запросом и получите измененные данные с помощью предложения RETURNING.

```sql
UPDATE seats SET fare_conditions='Business'
WHERE aircraft_code = '319' AND (
seat_no LIKE '6%' OR
seat_no LIKE '7%' OR
seat_no LIKE '8%'
) RETURNING *;

aircraft_code | seat_no | fare_conditions
---------------+---------+-----------------
319| 6A| Business
319| 6B| Business
319| 6C| Business
319| 6D| Business
319| 6E| Business
319| 6F| Business
319| 7A| Business
319| 7B| Business
319| 7C| Business
319| 7D| Business
319| 7E| Business
319| 7F| Business
319| 8A| Business
319| 8B| Business
319| 8C| Business
319| 8D| Business
319| 8F| Business
319| 8E| Business
(18 rows)
UPDATE 18
```

<div style="page-break-after: always; visibility: hidden"> 
\pagebreak 
</div>

## Упражнение 4.20 Засчитано

Найдите модели самолетов «дальнего следования», максимальная продолжительность рейсов которых составила более 6 часов.

```sql
SELECT DISTINCT a.model FROM flights f
INNER JOIN aircrafts a ON a.aircraft_code = f.aircraft_code
WHERE EXTRACT(HOUR FROM f.actual_arrival - f.actual_departure) >= 6;

model
------------------
Боинг 767-300
Аэробус A319-100
(2 rows)
```