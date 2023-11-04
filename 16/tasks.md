# ch 16

## Упражнение 16.1

Напишите на языке PL/pgSQL функцию, возвращающую все данные, относящиеся к одному бронированию, номер которого задан параметром.


```sql
CREATE TYPE boarding_info AS (ticket_no char(13), departure_airport char(3));

CREATE OR REPLACE FUNCTION get_boarding_data(b_no int) RETURNS SETOF boarding_info
LANGUAGE plpgsql AS $$
DECLARE
  v record;
BEGIN
  FOR v IN SELECT bp.ticket_no ticket_no,
      f.departure_airport departure_airport
    FROM boarding_passes bp
      INNER JOIN flights f ON f.flight_id = bp.flight_id
    WHERE bp.boarding_no=b_no
    LOOP
      RETURN NEXT ROW(v.ticket_no, v.departure_airport)::boarding_info;
    END LOOP;
END;
$$;

SELECT * FROM get_boarding_data(5);
```

## Упражнение 16.2

Напишите на языке SQL (не на PL/pgSQL) функцию, эквивалентную функции из упражнения 16.1.

```sql
CREATE OR REPLACE FUNCTION get_boarding_data(b_no int) RETURNS SETOF boarding_info
LANGUAGE sql AS $$
  SELECT ROW(
      bp.ticket_no,
      f.departure_airport)::boarding_info
    FROM boarding_passes bp
      INNER JOIN flights f ON f.flight_id = bp.flight_id
    WHERE bp.boarding_no=b_no;
$$;

SELECT * FROM get_boarding_data(5);
```

​Привет, смарт!

Прочитала я главу 16, по вершкам так сказать. Итак,

Функциональность PostgreSQL расширить можно с помощью хранимых подпрограмм (routines), определяемых пользователем:

1. функции 

    возвращает результат, 
    вызываются из запроса, например, через SELECT
    в теле функции нельзя использовать операторы управления транзакциями

2.  процедуры

    не возвращает результат, вызываются через CALL,
    можно делать транзакции, то есть изменять что-то в отношениях.

​Дальше в книге было объяснение синтаксиса plpgsql, которое запоминается только практикой. Для этого решила пару примеров, но это не гарантирует, что со мной останется только шлейф ощущения, что я что-то знаю.




## Упражнение 16.3

Напишите процедуру на языке PL/pgSQL, создающую новое бронирование в указанный день из заданного пункта отправления в заданный пункт назначения не более чем с двумя пересадками.

```sql
CREATE OR REPLACE PROCEDURE make_booking(book_ref char(6), amount numeric(10, 2)) LANGUAGE SQL AS $$
  insert into bookings (book_ref, book_date,total_amount) values (book_ref, now(), amount);
$$;
 ```


## Упражнение 16.4. Напишите процедуру, добавляющую нового пассажира к ука-
занному бронированию при условии, что на рейсе есть свободные места.
Упражнение 16.5. Исследуйте, как происходит откат базы данных при возник-
новении исключительной ситуации.
Для этого напишите функцию, которая выполняет некоторые изменения,
затем выполняет другие изменения внутри блока, обрабатывающего ис-
ключительную ситуацию, а затем в некоторых случаях выполняет опера-
тор, вызывающий возникновение исключительной ситуации внутри бло-
ка с обработчиком или вне его.
Проверьте состояние базы данных при нормальном выполнении, при
нормальном выходе из обработки исключительной ситуации, при отсут-
ствии обработки исключительной ситуации.
Упражнение 16.6. Повторите пример, приведенный в разделе 16.1, переписав
функцию never на языке SQL, и объясните полученный результат.