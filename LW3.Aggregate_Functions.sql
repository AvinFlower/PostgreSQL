--Задание 1
--1.Создать таблицу
create database lab3;
\c lab3
CREATE schema pupils;
SET SEARCH_PATH = pupils;

create table pupil
(id int not null primary key,
F varchar(20),
I varchar(20),
DoB date,
rating int);

--2.Наполнить данными (исправив ошибки)
insert into pupil values
(1, 'Иванов', 'Иван','20100102', 150),
(2, 'Петров', 'Петр','20100502', 120),
(3, 'Васиков', 'Василий','20090306', 115),
(4, 'Сидоров', 'Сидор','20090906', null),
(5, 'Петров', 'Сидор','20100906', 0);

--3.Вывести данные.
SELECT * FROM pupil;

--Добавить сортировку по году рождения.
SELECT * FROM pupil
ORDER BY extract('year' from DoB);

--4. Вывести средний, максимальный, минимальный рейтинг. Подписать эти столбцы. Был ли учтен ученик с null? Как его учесть в расчетах?
--Учение с null учтен
SELECT
  avg(coalesce(rating, 0)) AS average_rating, -- ученик с null был учтён
  MAX(rating) AS max_rating,
  MIN(rating) AS min_rating
FROM pupil;

--Учение с null не учтен
SELECT
  avg(rating) AS average_rating,
  MAX(rating) AS max_rating,
  MIN(rating) AS min_rating
FROM pupil;

--5. Вывести учеников 2010 года рождения и ОБЪЕДИНИТЬ их с учениками, рейтинг которых не нулевой.
SELECT * FROM pupil
WHERE Extract(year from Dob) = 2010
UNION
SELECT * FROM pupil
WHERE rating IS NOT NULL;

--6. Вывести учеников 2010 года рождения и ПЕРЕСЕЧЬ их с учениками, рейтинг которых не нулевой.
SELECT * FROM pupil
WHERE Extract(year from Dob) = 2010
INTERSECT
SELECT * FROM pupil
WHERE rating IS NOT NULL;

--7. Из учеников, рейтинг которых не нулевой ВЫЧЕСТЬ учеников 2009 года рождения.
SELECT * FROM pupil
WHERE rating IS NOT NULL
EXCEPT
SELECT * FROM pupil
WHERE Extract(year from Dob) = 2009;

--8. Посчитайте количество учеников, которые родились в КАЖДОМ из (2009, 2010) году.
SELECT COUNT(*) AS "Количество учеников"
FROM pupil
WHERE EXTRACT(YEAR FROM DoB) IN (2009, 2010)
GROUP BY EXTRACT(YEAR FROM DoB)

--9. В запрос из 18 в раздел select добавьте еще одно поле для вывода EXTRACT(year from DoB). Что произошло?(добавился еще один столбец с годом рождения)
SELECT EXTRACT(YEAR FROM DoB) AS "Год рождения", COUNT(*) AS "Количество учеников"
FROM pupil
WHERE EXTRACT(YEAR FROM DoB) IN (2009, 2010)
GROUP BY EXTRACT(YEAR FROM DoB)

--10. Добавьте к запросу из 19 в конец HAVING COUNT(*)>2
SELECT EXTRACT(YEAR FROM DoB) AS "Год рождения", COUNT(*) AS "Количество учеников"
FROM pupil
WHERE EXTRACT(YEAR FROM DoB) IN (2009, 2010)
GROUP BY EXTRACT(YEAR FROM DoB)
HAVING COUNT(*)>2; --(вывеодится только тот год рождения кде количество ученинов больше двух)

--11. Создайте таблицу инстинности для тренарной логики (TRUE, FALSE, NULL). И внимательно ее изучить
CREATE TABLE ternar (
    a BOOLEAN,
	b BOOLEAN
);

insert into ternar values
(TRUE,TRUE),
(TRUE,FALSE),
(TRUE,NULL),
(FALSE,TRUE),
(FALSE,FALSE),
(FALSE,NULL),
(NULL,TRUE),
(NULL,FALSE),
(NULL,NULL);

SELECT a,b, not a AS "NOT", a or b AS "OR", a and b AS "AND" FROM ternar;

-----------------------------
--Задания 2
--Подключитесь к demo базе.
\c demo
SET search_path = bookings;
\d airports

--12. Посчитайте сколько временных зон содержится в таблице Аэропорты.
SELECT COUNT(*) FROM (SELECT timezone FROM airports GROUP BY timezone) AS "timezone";

--13. Посчитайте сколько аэропортов в КАЖДОЙ временной зоне (см 9).
SELECT timezone, COUNT(*) as airport_count
FROM airports
GROUP BY timezone;

--14. Посчитайте сколько билетов было забронировано в КАЖДУЮ из дат присутствующих а таблице bookings. Обратите внимание, что дата храниться со временем, примените приведение типа к дате.
\d bookings
SELECT DATE(book_date) as booking_date, COUNT(*) as booking_count
FROM bookings
GROUP BY booking_date
ORDER BY booking_date;

--15. Одним запросом выведите самое раннее и позднее бронирование, количество бронирований, столбцы подписать.
SELECT
  MIN(book_date) as earliest_booking_date,
  MAX(book_date) as latest_booking_date,
  COUNT(*) as total_bookings
FROM bookings;

--16. Вывести аэропорты, которые находятся в часовом поясе Москвы (нельзя использовать в запросе данные, не указанные в задание).
SELECT airport_name, timezone
FROM airports
where timezone like '%Moscow%';

--17. Какие билеты купил IVAN IVANOV
select ticket_no as "Номер билета", passenger_name from Tickets
where passenger_name = 'IVAN IVANOV';

--18. Вывести информацию по аэропортам, код которых начинается на "К"
select * from Airports
where Airport_code like 'K%';

--19. Проверить, есть ли такие полеты, у которых статус рейса Вылетел, но фактическое время вылета не задано
select flight_id from Flights
where status like '%Departed%' and actual_departure is null;

--20. Посчитать количество рейсов с каждым статусом.
select count(*) as "Количество", status from Flights
group by status;

--21. Вывести только такие статусы рейсов, у которых количество оказалось больше 10.
select count(*) as "Количество", status from Flights
group by status
having count(*) > 10;

--22.Вывести аэропорты, в которых время вылета отличается от фактического времени вылета более, чем на 3 часа.
select departure_airport from Flights
where (actual_departure - scheduled_departure) > INTERVAL '3 hours'
group by departure_airport;

--23.Вывести один из самых коротких полетов.
select * from Flights
order by actual_arrival - actual_departure
limit 1;

--24.Вывести 5 самых длинных полетов.
select * from Flights
where actual_arrival - actual_departure is not null
order by actual_arrival - actual_departure desc
limit 5;
------------------------------------------
