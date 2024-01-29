--3.1. Создать представление, выводящее данные о самолетах. В данные об самолете включить модель, ранг, номер места, класс обслуживания.
CREATE VIEW bookings.aircrafts_seats
AS SELECT model, range, seat_no, fare_conditions FROM bookings.aircrafts a
LEFT JOIN bookings.seats s ON a.aircraft_code = s.aircraft_code;

--3.2. Создать запрос, возвращающий данные о самолетах из созданного представления.
SELECT * FROM bookings.aircrafts_seats;

--3.3. Создать представление аналогично заданию 3.1. В представление включить только места из бизнес класса. Могут ли здесь появится мигрирующие строки? Что можно предпринять?
CREATE VIEW bookings.aircrafts_seats1
AS SELECT model, range, seat_no, fare_conditions FROM bookings.aircrafts a
LEFT JOIN bookings.seats s ON a.aircraft_code = s.aircraft_code
WHERE fare_conditions = 'Business';

SELECT * FROM bookings.aircrafts_seats1;
-- Ответы на вопросы: Мигрирующие строки появиться в данном случае не могут, поскольку данное представление не может идти с
-- WITH CHECK OPTION(данная конструкция пишется для того, чтобы строки, неудовлетворяющие условию в WHERE не добавлялись в наше представление),
-- потому что происходит обьединение двух таблиц. Для того чтобы мигрирующие строки появились, стоит работать над одной таблицей или же сделать триггер.


--3.4. Выяснить, является ли представление, созданное в задании 3.1 и 3.3, обновляемым. 
--Если нет, то предложить вариант изменения представления с целью сделать его обновляемым.

--Представления не обновляемые, из соединений двух таблиц нельзя сделать обновляемое представление.
UPDATE bookings.aircrafts_seats
SET fare_conditions = 'Business'
WHERE fare_conditions = 'Business';

UPDATE bookings.aircrafts_seats1
SET fare_conditions = 'Business'
WHERE fare_conditions = 'Business';

--Предлагаемое решение для обновляемости представления - создание представление для одной таблицы без присоединения других таблиц с помощью ключевой конструкции CREATE OR REPLACE.
CREATE OR REPLACE VIEW bookings.aircrafts_seats
AS SELECT * FROM bookings.seats;
SELECT * FROM bookings.aircrafts_seats;

CREATE OR REPLACE VIEW bookings.aircrafts_seats1
AS SELECT * FROM bookings.seats
WHERE fare_conditions = 'Business'
WITH CHECK OPTION;
SELECT * FROM bookings.aircrafts_seats1;

--3.5 Создать представление (просто скрипт написать, таблицы не надо создавать) выводящее список студентов упорядоченный по группам, 
--фамилиям студентов с указанием количества оценок каждого достоинства за последнюю сессию. 
--Как часто надо обновлять такое представление? Что можно сделать, чтобы его постоянно не пересчитывать?
-- Структура таблиц соответствует таблицам в Тренажерах

CREATE MATERIALIZED VIEW university_students1
AS SELECT f, group_name, count(mark)
FROM "group"
    JOIN student ON ("group".idgr = student.idgr)
    JOIN marks m1 ON (m1.idst = student.idst)
    JOIN marks m2 ON (m2.idst = student.idst)
    JOIN marks m3 ON (m3.idst = student.idst)
    JOIN marks m4 ON (m4.idst = student.idst)
    JOIN marks m5 ON (m5.idst = student.idst)
    JOIN subject ON (subject.idsub = marks.idsub)
WHERE sem_no = (SELECT MAX(sem_no) FROM marks)
and m1 = (SELECT mark FROM marks
                      HAVING mark = '1')
and m2 = (SELECT mark FROM marks
                      HAVING mark = '2')
and m3 = (SELECT mark FROM marks
                        HAVING mark = '3')
and m4 = (SELECT mark FROM marks
                        HAVING mark = '4')
and m5 = (SELECT mark FROM marks
                        HAVING mark = '5')
GROUP BY f, group_name
ORDER BY group_name, f;
--Ответы на вопросы: Данное представление является копией таблицы university_students. Обновление происходит вручную
-- или при изменении базовых таблиц(не постоянные обновления)
-- или с использованием триггеров(постоянное обновление).



-- 3.6 Проанализировать свою предметную область. Определить группы пользователей и какую информацию эти пользователи должны видеть. 
--Создать несколько представлений для каждого пользователя предполагаемой ИС. Определить какие из них будут обновляемые (описать это в ответе на задание)? 
--Какие из них могут иметь мигрирующие строки? Для каких представлений необходимо with check option?


--Материализованное представление 1 будет обновляться вручную(REFRESH MATERIALIZED VIEW) или с помощью триггеров. Мигрирующие строки могут здесь использоваться.
--Материализованное представление здесь выглядит хорошо, потому что таблица обновляется не так часто, а скорость обработки увелчивается.

--Менеджер отвечающий за график и место проведения концертов. 
CREATE MATERIALIZED VIEW place_manager
AS SELECT * FROM concert_agency.venue;

--Представление 2 обновляется при изменении базовых таблиц, также присутствуют мигрирующие строки, так менеджер сможет динамически отслеживать, какие заказы находятся в процессе.

--Менеджер, занимающийся обработкой заказов на концерты для артистов или иных лиц.
CREATE OR REPLACE VIEW orders_manager
AS SELECT * FROM concert_agency.order
WHERE order_status = 'In Process'
WITH CHECK OPTION;

--Представление 3 обновляется при изменении базовых таблиц, динамически, соответственно обычное представление подходит для данного случая больше, чем материализованное

--Менеджер, который может осуществлять контроль билетов на самом мероприятии.
CREATE OR REPLACE VIEW controller_manager
AS SELECT * FROM concert_agency.ticket
WITH CHECK OPTION;


--3.7 Нужно ли для вашей задачи материализованное представление? Ответ обосновать.
-- Ответ представлен в 3.6
