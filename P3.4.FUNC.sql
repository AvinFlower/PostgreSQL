--1. Создать функцию, которая возвращает количество отпраляющихся рейсов в день из заданного аэропорта. Вызвать ее.
CREATE FUNCTION cnt(date_in date, airport_in text)
RETURNS bigint 
AS $$ 
SELECT count(*) from bookings.airports a1 
JOIN bookings.flights f1 ON (a1.airport_code = f1.departure_airport)
WHERE airport_name = airport_in AND f1.scheduled_departure::date = date_in
$$ stable LANGUAGE SQL;

--Проверка
SELECT cnt('2016-09-13', 'Мирный');

-- 2. Создать функцию, которая для заданого рейса проверяет все ли пассажиры получили поссадочные талоны. 
--Если какие-то пассажиры не явились на рейс, то их надо вывести. Вызвать ее.
CREATE FUNCTION null_passengers(flight_number int)
RETURNS TABLE (passenger_name text)
AS $$
SELECT passenger_name FROM bookings.flights f 
JOIN bookings.ticket_flights tf ON f.flight_id = tf.flight_id 
JOIN bookings.tickets t ON tf.ticket_no = t.ticket_no 
LEFT JOIN bookings.boarding_passes bp ON tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id
WHERE bp.ticket_no IS NULL AND f.flight_id = flight_number
$$ stable LANGUAGE SQL;

--Смотрим наглядно где ticket_no IS NULL
SELECT passenger_name, t.ticket_no AS T, tf.ticket_no AS TF, bp.ticket_no AS BP, f.flight_id from bookings.flights f 
JOIN bookings.ticket_flights tf ON f.flight_id = tf.flight_id 
JOIN bookings.tickets t ON tf.ticket_no = t.ticket_no 
LEFT JOIN bookings.boarding_passes bp ON tf.ticket_no = bp.ticket_no AND tf.flight_id = bp.flight_id;

--Проверка
SELECT null_passengers('8130');

-- 3. Написать функцию, которая ищет возможность добраться из города А в город В без пересадок / с одной пересадкой. Вызвать ее.
-- SELECT A, B, 0, flight_no, NULL from (SELECT ... from flights) uniON
-- SELECT A, B, 1, flight_no1, flight_no2 from (SELECT ... from flights JOIN flights)

CREATE FUNCTION opportunity(good_city text)
RETURNS TABLE (departure_airport char(3), arrival_airport char(3), num_transfers integer, flight_no1 text, flight_no2 text)
AS $$
    SELECT f1.departure_airport, f1.arrival_airport, 0 as num_transfers, f1.flight_no, NULL as flight_no2
    FROM bookings.flights f1
    JOIN bookings.airports A ON f1.departure_airport = A.airport_code
    JOIN bookings.airports C ON f1.arrival_airport = C.airport_code
    WHERE A.city = good_city
    AND A.city != C.city

    UNION

    SELECT f1.departure_airport, f2.arrival_airport, 1 as num_transfers, f1.flight_no, f2.flight_no
    FROM bookings.flights f1
    JOIN bookings.flights f2 ON f1.arrival_airport = f2.departure_airport
    JOIN bookings.airports A ON f1.departure_airport = A.airport_code
    JOIN bookings.airports C ON f2.arrival_airport = C.airport_code
    WHERE A.city = good_city
    AND A.city != C.city;
$$ stable LANGUAGE sql;


--Проверка
SELECT opportunity('Москва');