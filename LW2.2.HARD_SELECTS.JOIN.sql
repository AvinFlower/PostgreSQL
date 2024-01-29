--1. Вывести самый дорогой(возможно, не один) перелет и самый дешевый (возможно, не один).
SELECT *
FROM ticket_flights
WHERE amount IN (SELECT MAX(amount) FROM ticket_flights
                 UNION
                 SELECT MIN(amount) FROM ticket_flights);

--2. Сколько вариантов купить 2 места в одном ряду (отличаются номера мест только буквой) в самолете Cessna 208 Caravan?
SELECT COUNT(*)/2 AS count FROM seats s1
  JOIN seats s2 ON s1.seat_no != s2.seat_no 
  AND SUBSTRING(s1.seat_no from char_length(s1.seat_no)-1 for 1) = SUBSTRING(s2.seat_no from char_length(s2.seat_no)-1 for 1)
  JOIN aircrafts a1 ON s1.aircraft_code = a1.aircraft_code
  JOIN aircrafts a2 ON s2.aircraft_code = a2.aircraft_code
  WHERE a1.model = 'Cessna 208 Caravan'
    AND a2.model = 'Cessna 208 Caravan';

--3. Вывести модель самолета и его комфортность мест.
SELECT fare_conditions, model FROM seats
JOIN aircrafts ON seats.aircraft_code = aircrafts.aircraft_code
GROUP BY fare_conditions, model;

--4. Вывести список аэропорты и самолеты, которые там приземляются, без повторений.
SELECT DISTINCT airport_name, aircraft_code FROM airports
JOIN flights ON airports.airport_code = flights.arrival_airport;

--5. Проверить есть ли такие аэропотры, куда не летал ни один самолет.
SELECT airport_code, airport_name FROM airports
WHERE airport_code NOT IN (SELECT DISTINCT arrival_airport FROM flights);

--6. Кто летел месяц назад рейсом Москва — Новосибирск  на месте 3С? Когда было выполнено бронирование билета? «Месяц назад» отсчитывается от bookings.now()

SELECT t.passenger_name, b.book_date AS booking_date, a1.city AS from_city, a2.city AS to_city, f.actual_departure, bp.seat_no
FROM flights f
JOIN airports a1 ON f.departure_airport = a1.airport_code
JOIN airports a2 ON f.arrival_airport = a2.airport_code
JOIN ticket_flights tf ON f.flight_id = tf.flight_id
JOIN boarding_passes bp ON tf.flight_id = bp.flight_id AND tf.ticket_no = bp.ticket_no
JOIN tickets t ON tf.ticket_no = t.ticket_no
JOIN bookings b ON t.book_ref = b.book_ref
WHERE a1.city = 'Москва'
  AND a2.city = 'Новосибирск'
  AND bp.seat_no = '3C'
  AND (f.actual_departure)::date = (bookings.now() - INTERVAL '1 month')::date;

--7. В какие дни недели состоялись вылеты самолетов за последнюю неделю и в каком количестве. «Неделю» отсчитывать от booking.now()
SELECT EXTRACT(DOW FROM scheduled_departure) AS day_of_week, COUNT(*) AS flight_count
FROM flights
WHERE scheduled_departure >= (bookings.now() - INTERVAL '1 week')
GROUP BY day_of_week
ORDER BY day_of_week;

--8. Вывести билеты, по которым количество рейсов превышает 4.
SELECT tickets.ticket_no, COUNT(*) AS flight_count FROM tickets
INNER JOIN ticket_flights ON tickets.ticket_no = ticket_flights.ticket_no
GROUP BY tickets.ticket_no
HAVING COUNT(*) > 4;

--9. Посчитать среднюю цену билетов по каждому классу обслуживани в различных самолетах. Если для самолета нет проданных билетов, то он должен быть выведент в результате с ценой 0.
SELECT flights.aircraft_code, seats.fare_conditions, COALESCE(AVG(ticket_flights.amount), 0) AS avg_price
FROM flights
CROSS JOIN (SELECT DISTINCT fare_conditions FROM seats) AS seats
LEFT JOIN ticket_flights ON flights.flight_id = ticket_flights.flight_id
GROUP BY flights.aircraft_code, seats.fare_conditions;

--10. Вывести данные о пассажире, который совершил самое большое количество перелетов.
SELECT passenger_id, passenger_name, COUNT(*) AS flight_count FROM tickets
JOIN ticket_flights ON tickets.ticket_no = ticket_flights.ticket_no
JOIN flights ON flights.flight_id = ticket_flights.flight_id
JOIN boarding_passes ON ticket_flights.ticket_no = boarding_passes.ticket_no AND ticket_flights.flight_id = boarding_passes.flight_id
WHERE flights.status = 'Arrived'
GROUP BY passenger_id, passenger_name
ORDER BY flight_count DESC
LIMIT 1;
