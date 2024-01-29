-- \cd 'C:\\Users\\USER\\source\\repos\\DB'
-- \i demo_small.sql
-- \c demo

SET search_path = bookings;
\d airports

--12. Посчитайте сколько временных зон содержится в таблице Аэропорты.
SELECT count(*) FROM (SELECT timezone AS "TIMEZONE" FROM airports 
GROUP BY timezone);

--13. Посчитайте сколько аэропортов в КАЖДОЙ временной зоне (см 9).
SELECT DATE(book_date) AS "booking_date", COUNT(*) AS "ticket_count"
FROM bookings
GROUP BY DATE(book_date)
ORDER BY "booking_date";

--14. Посчитайте сколько билетов было забронировано в КАЖДУЮ из дат присутствующих а таблице bookings. Обратите внимание, что дата храниться со временем, примените приведение типа к дате.
SELECT DATE(book_date) AS "booking_date", COUNT(*) AS "ticket_count"
FROM bookings
GROUP BY DATE(book_date)
ORDER BY "booking_date";

--15. Одним запросом выведите самое раннее и позднее бронирование, количество бронирований, столбцы подписать.
SELECT
  MIN(book_date) AS "Earliest booking",
  MAX(book_date) AS "Latest booking",
  COUNT(*) AS "General count bookings"
FROM bookings;

--16. Вывести аэропорты, которые находятся в часовом поясе Москвы (нельзя использовать в запросе данные, не указанные в задание).
SELECT timezone AS "Airports_MSK", COUNT(*)
FROM airports
WHERE timezone = 'Europe/Moscow'
GROUP BY timezone;

--17. Какие билеты купил IVAN IVANOV
select ticket_no as "ticket number", passenger_name from Tickets
where passenger_name like '%IVAN%IVANOV%' ;

--18. Вывести информацию по аэропортам, код которых начинается на "К"
select * from Airports
where Airport_code like 'K%';

--19. Проверить, есть ли такие полеты, у которых статус рейса Вылетел, но фактическое время вылета не задано
select flight_id from Flights
where status like '%Arrived%' and actual_departure is null;

--20. Посчитать количество рейсов с каждым статусом.
select count(*) as "Count", status from Flights
group by status;

--21. Вывести только такие статусы рейсов, у которых количество оказалось больше 10.
select count(*) as "Count", status from Flights
group by status
having count(*) > 10;

--22. Вывести аэропорты, в которых время вылета отличается от фактического времени вылета более, чем на 3 часа.
WITH FlightTimeDifference AS (
    SELECT departure_airport AS "Departure Airport",
           EXTRACT('Hour' FROM actual_departure) - EXTRACT('Hour' FROM scheduled_departure) AS "Difference"
    FROM Flights
)
SELECT "Departure Airport", ROUND(AVG("Difference"), 1) AS "Average Difference"
FROM FlightTimeDifference
WHERE "Difference" > 3
GROUP BY "Departure Airport";

--23. Вывести один из самых коротких полетов.
select * from Flights
group by flight_id
order by actual_arrival - actual_departure
limit 1;

--24. Вывести 5 самых длинных полетов.
select * from Flights
group by flight_id
having actual_arrival - actual_departure is not null
order by actual_arrival - actual_departure desc
limit 5;