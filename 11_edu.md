# 11 Упражнения

## Упражнение 11.1

Создайте таблицу, содержащую географические координаты и момент времени (такие атрибуты могут быть, например, у фотографии). Заполните таблицу искусственно сгенерированными значениями.

```sql
CREATE TABLE ph (id int primary key,coord point, created_at timestamp);

CREATE OR REPLACE FUNCTION fill_table_ph() RETURNS SETOF integer AS $$
BEGIN
  FOR i IN 1..1000 LOOP
    INSERT INTO ph (id,coord, created_at) VALUES (i, point(random()* (180 + 1), random()* (180 + 1)), CURRENT_TIMESTAMP + interval '1 hour' * i);
  END LOOP;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT fill_table_ph();
```

## Упражнение 11.2

Для созданной таблицы постройте двумерный индекс по координатам. (Воспользуйтесь типом данных point и индексом GiST.)

```sql
CREATE INDEX ph_coord_gist ON ph USING gist(coord);

EXPLAIN SELECT * FROM ph WHERE coord <@ circle '((10,10), 20)';
```

```shell
                               QUERY PLAN                                
-------------------------------------------------------------------------
 Index Scan using ph_coord_gist on ph  (cost=0.14..8.16 rows=1 width=28)
   Index Cond: (coord <@ '<(10,10),20>'::circle)
(2 rows)

```

## Упражнение 11.3

Постройте еще один индекс по всем колонкам созданной таблицы. (Используйте расширение btree_gist.)

```sql
CREATE EXTENSION btree_gist;

CREATE INDEX ph_coord_btree_gist ON ph USING GIST (coord);

edu=# EXPLAIN SELECT * FROM ph WHERE coord <@ circle '((10,10), 20)';
```

```shell
                                  QUERY PLAN                                   
-------------------------------------------------------------------------------
 Index Scan using ph_coord_btree_gist on ph  (cost=0.14..8.16 rows=1 width=28)
   Index Cond: (coord <@ '<(10,10),20>'::circle)


> \d ph;

                             Table "public.ph"
   Column   |            Type             | Collation | Nullable | Default 
------------+-----------------------------+-----------+----------+---------
 id         | integer                     |           | not null | 
 coord      | point                       |           |          | 
 created_at | timestamp without time zone |           |          | 
Indexes:
    "ph_pkey" PRIMARY KEY, btree (id)
    "ph_coord_btree_gist" gist (coord)
    "ph_coord_gist" gist (coord)

```

## Упражнение 11.4

Напишите запрос, находящий фотографии, сделанные на расстоянии не более двух километров от заданной точки в течение заданного дня. Определите, как зависит скорость выполнения запроса от наличия одного или другого индекса из двух предыдущих упражнений.

```sql
EXPLAIN SELECT * FROM ph WHERE coord <@ circle'((10,10), 100)' AND EXTRACT( DAY FROM created_at) = 20;
```

```shell
                                  QUERY PLAN                                   
-------------------------------------------------------------------------------
 Index Scan using ph_coord_btree_gist on ph  (cost=0.14..8.17 rows=1 width=28)
   Index Cond: (coord <@ '<(10,10),100>'::circle)
   Filter: (EXTRACT(day FROM created_at) = '20'::numeric)
(3 rows)
```

```sql
SELECT * FROM ph WHERE coord <@ circle'((10,10), 100)' AND EXTRACT( DAY FROM created_at) = 20;
```

```shell
 id  |                  coord                  |         created_at         
-----+-----------------------------------------+----------------------------
 895 | (4.857213657430981,8.986375583123426)   | 2023-11-20 18:37:17.424157
 143 | (35.24054606688133,19.341270455623235)  | 2023-10-20 10:37:17.424157
 897 | (15.326277653758009,68.31214436215421)  | 2023-11-20 20:37:17.424157
 888 | (43.405837171461656,56.22866527935758)  | 2023-11-20 11:37:17.424157
 887 | (55.13937662099147,52.500478566197174)  | 2023-11-20 10:37:17.424157
 145 | (89.04885936127977,6.7002316496391074)  | 2023-10-20 12:37:17.424157
 144 | (79.86320547765695,22.915226554966424)  | 2023-10-20 11:37:17.424157
 878 | (77.91525484183714,53.14521527165132)   | 2023-11-20 01:37:17.424157
 149 | (102.0536344345821,48.45830773470531)   | 2023-10-20 16:37:17.424157
 891 | (1.7576213997853267,86.97444718590597)  | 2023-11-20 14:37:17.424157
 148 | (10.46606687069264,91.98013201848902)   | 2023-10-20 15:37:17.424157
 883 | (103.94727038825549,2.6194765738602626) | 2023-11-20 06:37:17.424157
 900 | (105.07794767925724,4.764801036627112)  | 2023-11-20 23:37:17.424157
(13 rows)

```

## Упражнение 11.5

Постройте индекс триграмм, встречающихся в индексируемом тексте. (Воспользуйтесь индексом GIN и расширением pg_trgm.)

```sql
CREATE EXTENSION pg_trgm;

CREATE TABLE txt (title TEXT, title_tsv TSVECTOR);

INSERT INTO txt(title) VALUES          
  ('Can a sheet slitter slit sheets?'), 
  ('How many sheets could a sheet slitter slit?'),
  ('I slit a sheet, a sheet I slit.'),
  ('Upon a slitted sheet I sit.'), 
  ('Whoever slit the sheets is a good sheet slitter.'), 
  ('I am a sheet slitter.'),
  ('I slit sheets.'),
  ('I am the sleekest sheet slitter that ever slit sheets.'),
  ('She slits the sheet she sits on.');

UPDATE txt SET title_tsv=to_tsvector(title);

CREATE INDEX ON txt USING GIN(title_tsv);

EXPLAIN SELECT * FROM txt WHERE title LIKE '%slit%';
```

```shell
                     QUERY PLAN                     
----------------------------------------------------
 Seq Scan on txt  (cost=0.00..1.12 rows=1 width=64)
   Filter: (title ~~ '%slit%'::text)
(2 rows)

```
