# Шауэрман Айнур

## Упражнение 5.1

Создайте роль для доступа на чтение к демонстрационной базе данных без права создания сеансов работы с сервером БД.

**Ответ:**

```sql
CREATE ROLE demo_reader_role;
```

Посмотрю список доступных схем демонстрацинонной БД.

```sql
\dn
       List of schemas
   Name   |       Owner       
----------+-------------------
 bookings | edu
 public   | pg_database_owner
(2 rows)
```

Для чтения данных из демонстрационной БД необходимо дать права на просмотр схемы.

Создаю для роли `demo_reader_role` привилегию  пользования схемой bookings и чтение из таблиц в этой схеме.

```sql
GRANT USAGE ON SCHEMA bookings TO demo_reader_role;
GRANT SELECT ON ALL TABLES IN SCHEMA bookings TO demo_reader_role;

\dg demo_reader_role
             List of roles
  Role name  |  Attributes  | Member of 
-------------+--------------+-----------
 demo_reader_role | Cannot login | {}
```

## Упражнение 5.2

Создайте пользователя сервера БД и предоставьте ему привилегию использования роли, созданной в предыдущем упражнении.
Проверьте, что этот пользователь может выполнять любые запросы на выборку из таблиц демонстрационной базы данных, но не может их обновлять.

**Ответ**:

```sql
CREATE USER demo_reader_user WITH LOGIN;
GRANT demo_reader_role TO demo_reader_user;

\du demo_reader_user 
                   List of roles
    Role name     | Attributes |     Member of      
------------------+------------+--------------------
 demo_reader_user |            | {demo_reader_role}
```

Проверю от лица `demo_reader_user`: 
* создаю сеанс
* делаю выборку из таблицы, например, `seats` - успех,
* пытаюсь изменить строку в таблице `seats` - получаю ошибку об отсуствии права на изменение данных в таблице.

```sql
psql -U demo_reader_user -d demo

SELECT * FROM bookings.seats;
 aircraft_code | seat_no | fare_conditions 
---------------+---------+-----------------
 319           | 2A      | Business
 319           | 3F      | Business
--More--

UPDATE bookings.seats SET aircraft_code='320' WHERE aircraft_code='319' AND seat_no='2A';
ERROR:  permission denied for table seats
```

## Упражнение 5.3

Заберите у пользователя привилегию, выданную в предыдущем упражнении. Убедитесь, что этот пользователь не сможет выбирать данные из таблиц демобазы.

**Ответ:**

1) Под владельцем БД заберу права на пользование демонстрационнной БД.

```sql
REVOKE demo_reader_role FROM demo_reader_user;
```

2) Тем временем, пользователь demo_reader:

```sql
SELECT * FROM bookings.seats;
ERROR:  permission denied for schema bookings
LINE 1: select * from bookings.seats;
```

## Упражнение 5.4

Постройте пример, показывающий, что для доступа к таблицам схемы необходимо также предоставить право использования (USAGE) этой схемы.

```sh
psql -U edu -- оунер схемы bookings
```

```sql
CREATE ROLE test_reader LOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA bookings TO test_reader;
```

Тем временем test_reader в своем сеансе (после `psql -U test_reader -d edu`):

```sql
\c demo
You are now connected to database "demo" as user "test_reader".
SELECT * FROM bookings.seats;
ERROR:  permission denied for schema bookings
LINE 1: select * from bookings.seats;
```
