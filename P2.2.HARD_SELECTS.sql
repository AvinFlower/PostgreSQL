--1 Какими самолетами, кроме машин компаний Airbus и Boeing, располагает наша авиакомпания (aircrafts)?
SELECT * FROM aircrafts
WHERE model NOT LIKE 'Airbus%' AND model NOT LIKE 'Boeing%';

--2 В каких различных часовых поясах(timezone) располагаются аэропорты(airports)?
SELECT timezone FROM airports
GROUP BY timezone;

--3 Найти три самых восточных аэропорта(longitude).
select * from airports
order by longitude desc
limit 3;

--4 Выбрать все места (seat_no) и их класс (fare_conditions), 
--предусмотренные компоновкой салона самолета (model) Cessna 208 Caravan (таблицы seats и aircrafts). Результат отсортировать по номеру места.
select seat_no, fare_conditions, model from seats s inner join aircrafts a
on s.aircraft_code = a.aircraft_code
where model = 'Cessna 208 Caravan'
order by seat_no;

--5 Написать запрос тремя способами:  Сколько всего маршрутов нужно было бы сформировать, 
--если бы требовалось соединить каждый город со всеми остальными городами(city из airports).
SELECT * FROM airports A1
CROSS JOIN airports A2
WHERE A1.city != A2.city;

SELECT * FROM airports A1, airports A2
WHERE A1.city != A2.city;

SELECT * FROM airports A1
JOIN airports A2 
ON A1.city != A2.city;

--6 Вывести сколько маршрутов(aircraft_code) обслуживают самолеты каждого типа (model)? Таблицы routes и aircrafts.
SELECT model, count(*) FROM routes
    INNER JOIN aircrafts ON routes.aircraft_code = aircrafts.aircraft_code
GROUP BY model;

--7 Какая модель самолета не участвует в выполнении рейсов?
SELECT aircraft_code, model FROM aircrafts
WHERE aircraft_code NOT IN (SELECT DISTINCT aircraft_code FROM flights);


--8 Определить, сколько существует маршрутов из каждого города(departure_city) в другие города, 
--и вывести названия городов, из которых в другие города существует не менее 15 маршрутов. Таблица routes.
SELECT * FROM routes r1, routes r2
WHERE r1.departure_city != r2.departure_city;

--9 Вывести города, в которых более 1 аэропорта, не используя подзапросы.
SELECT city, count(airports) FROM airports
GROUP BY city
HAVING count(airports) > 1;

--10 Написать запрос с использованием EXISTS и IN. Выведите в какие города нет рейсов из Москвы. (2 отдельных запроса)
SELECT DISTINCT a.city
FROM airports a
WHERE NOT EXISTS (
  SELECT city FROM flights f
  WHERE f.departure_airport = 'Москва' AND f.arrival_airport = a.airport_code
);

SELECT DISTINCT a.city
FROM airports a
WHERE a.airport_code NOT IN (
  SELECT DISTINCT f.arrival_airport FROM flights f
  WHERE f.departure_airport = 'Москва'
);
