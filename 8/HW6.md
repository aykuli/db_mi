# Шауэрман Айнур

## Домашнее задание №6

Глава 8 8.1, 8.3

### Упражнение 8.1

Напишите запрос, выдающий список самолетов из демонстрационной базы в формате JSON.

**Ответ:**

```sql
> SELECT json_agg(json_build_object('code', aircraft_code, 'model', model, 'range', range)) FROM aircrafts;
  json_agg 
 [{"code" : "773", "model" : "Боинг 777-300", "range" : 11100}, {"code" : "763", "model" : "Боинг 767-300", "range" : 7900}, {"code
" : "SU9", "model" : "Сухой Суперджет-100", "range" : 3000}, {"code" : "320", "model" : "Аэробус A320-200", "range" : 5700}, {"code
" : "321", "model" : "Аэробус A321-200", "range" : 5600}, {"code" : "319", "model" : "Аэробус A319-100", "range" : 6700}, {"code" :
 "733", "model" : "Боинг 737-300", "range" : 4200}, {"code" : "CN1", "model" : "Сессна 208 Караван", "range" : 1200}, {"code" : "CR
2", "model" : "Бомбардье CRJ-200", "range" : 2700}]
(1 row)
```

### Упражнение 8.3

Напишите запрос, выдающий заданное бронирование в формате JSON, включая все входящие в него билеты и перелеты для каждого из билетов.

**Ответ:**

Скажем, заданное бронирование имеет значение `book_ref='1A40A1'`.

```sql
 book_ref |       book_date        | total_amount |   ticket_no   | book_ref | passenger_id | passenger_name  |       contact_data 
       |   ticket_no   | flight_id | fare_conditions | amount  | flight_id | flight_no |  scheduled_departure   |   scheduled_arriv
al    | departure_airport | arrival_airport | status  | aircraft_code |    actual_departure    |     actual_arrival     
```

```sql
SELECT json_build_object(
  'book_ref',             b.book_ref,
  'book_date',            b.book_date,
  'total_amount',         b.total_amount,
  'ticket_no',            t.ticket_no,
  'passenger_id',         t.passenger_id,
  'passenger_name',       t.passenger_name,
  'contact_data',         t.contact_data,
  'flight class',         t.fare_conditions,
  'ticket amount',        t.amount,
  'flight_id',            t.flight_id,
  'flight_no',            t.flight_no,
  'scheduled_departure',  t.scheduled_departure,
  'scheduled_arrival',    t.scheduled_arrival,
  'departure_airport',    t.departure_airport,
  'arrival_airport',      t.arrival_airport,
  'flight status',        t.status,
  'aircraft_code',        t.aircraft_code,
  'actual_departure',     t.actual_departure,
  'actual_arrival',       t.actual_arrival
) 
FROM bookings b
  INNER JOIN (
    SELECT  t.book_ref,
            t.passenger_id,
            t.passenger_name,
            t.contact_data,
            tf.*
    FROM tickets t
      INNER JOIN (
        SELECT  tf.ticket_no,
                tf.fare_conditions,
                tf.amount, 
                f.*
        FROM ticket_flights tf
        INNER JOIN flights f ON tf.flight_id = f.flight_id
      ) tf ON tf.ticket_no = t.ticket_no
  ) t ON t.book_ref = b.book_ref
  where b.book_ref='1A40A1';
```
