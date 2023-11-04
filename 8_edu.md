 # Triggers

## Упражнение 8.6

Создайте триггер, реализующий правило целостности в демонстрационной базе: рейсы могут совершать только те типы самолетов, максимальная дальность полета которых превышает расстояние между аэропортами. Для расчета расстояния воспользуйтесь расширением earthdistance.

```sql
-- FUNCTION --
CREATE OR REPLACE FUNCTION check_flight() RETURNS trigger AS $$
BEGIN
  IF (SELECT a.coordinates <@> a2.coordinates > crafts.range FROM aircrafts crafts
  INNER JOIN airports a ON a.airport_code = NEW.departure_airport
  INNER JOIN airports a2 ON a2.airport_code = NEW.arrival_airport
  WHERE NEW.aircraft_code=crafts.aircraft_code) THEN
    RAISE EXCEPTION 'This aircraft cannot fly this distance';
    RETURN NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER
CREATE TRIGGER check_flight BEFORE INSERT OR UPDATE ON flights FOR EACH ROW EXECUTE FUNCTION check_flight();
```

```sql
INSERT INTO flights (                                                                                                         flight_no, 
  scheduled_departure, 
  scheduled_arrival,                                           
  departure_airport, 
  arrival_airport,
  status,
  aircraft_code
  ) VALUES (
    'PG0999',
    '2017-08-25 00:20:00+00',
    '2017-08-25 06:45:00+00',
    'YKS',
    'LED',
    'Scheduled',
    'CN1');
```

```shell
ERROR:  This aircraft cannot fly this distance
CONTEXT:  PL/pgSQL function check_flight() line 7 at RAISE
```

## Упражнение 8.7

Создайте в базе данных триггер, который не позволит выполнять операторы CREATE в ночное время.

```sql
CREATE OR REPLACE FUNCTION cannot_create_table_night() RETURNS event_trigger AS $$
BEGIN
  IF (select date_part('hour', LOCALTIMESTAMP) <= 6 AND date_part('hour', localtimestamp) >= 22) THEN
    RAISE EXCEPTION 'CANNOT CREATE TABLE AT NIGHT';
  END IF;
END
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER cannot_create_table_night ON ddl_command_start EXECUTE FUNCTION cannot_create_table_night();
```


## Упражнение 8.8

Создайте в демонстрационной базе вспомогательную таблицу и триггеры для аудита изменений рейсов. Изменения можно записывать в таблицу с тем же набором полей, а можно — в один JSON-столбец (что позволит избежать проблем при изменении структуры таблицы).


## Упражнение 8.9

Создайте в демонстрационной базе событийный триггер, автоматически создающий для новых таблиц обычные триггеры для аудита
изменений в этих таблицах.
