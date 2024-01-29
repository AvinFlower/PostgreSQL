--2. Написать комментарии к каждой строчке кода из демонстрации для
CREATE VIEW flights_v  -- Создание представления flights_v
AS -- Начало тела представления
SELECT id, -- Выбираем атрибут id и открываем подзапрос
       (SELECT name
        FROM airports
        WHERE code = airport_from) AS airport_from,-- Подзапрос выбирает все name из сущности airports, где code равен airport_from
       (SELECT name
        FROM airports
        WHERE code = airport_to) AS airport_to-- Подзапрос выбирает все name из сущности airports, где code равен airport_to
FROM flights; -- Из таблицы flights

CREATE OR REPLACE FUNCTION flights_v_update() -- Создание функции flights_v_update()
RETURNS trigger -- с возвращаемым значением trigger
AS $BODY$ -- Начало тела функции
DECLARE -- Обьявление переменных
code_to char(3); -- Переменная code_to в типе данных char с ограничением в 3 символа
BEGIN -- Начало блока выполнения ф-ии
    BEGIN -- Начало блока выполнения запроса
        SELECT code INTO STRICT code_to
        FROM airports
        WHERE name = NEW.airport_to; -- Выбор значения code из таблицы airports, где значение столбца name равно NEW.airport_to
    EXCEPTION -- Если в SELECT возвращено больше 1 строки или не возвращена ни одна строка, тогда обрабатывается исключение
        WHEN no_data_found THEN --Если не найден аэропорт
            RAISE EXCEPTION 'Аэропорт % отсутствует', -- Выкидываем исключени
                                                      NEW.airport_to; -- Указываем на отсутствующий аэропорт
    END;-- Конец блока выполнения запроса
    UPDATE flights -- Обновляем таблицу flights
    SET airport_to = code_to -- Устанавливаем airport_to = code_to
    WHERE id = OLD.id; -- Обновление только строки с соответствующим старым id
    RETURN NEW; -- Возвращаем измененную новую строку
END; -- Конец блока выполнения ф-ии
$BODY$ LANGUAGE plpgsql; -- Закрытие тела функции и установка языка на plpgsql

CREATE TRIGGER flights_v_upd_trigger -- Создаем триггер с названием flights_v_upd_trigger
INSTEAD OF UPDATE ON flights_v -- Вместо стандартных обновлений триггер flights_v_upd_trigger будет выполнять функцию flights_v_update(). То есть обычные UPDATE вне функции не будут работать
FOR EACH ROW -- Для каждой строки
EXECUTE FUNCTION flights_v_update(); -- Вызов функции flights_v_update()


--3 Создать триггеры
--3.1 При попытке удаления самолета из таблицы bookings.aircrafts удаление блокируется, пользователю выводится сообщение и транзакция откатывается.
-- Проверять работу триггера следует на A-320
\c demo
SET SEARCH_PATH = bookings;

CREATE OR REPLACE FUNCTION F_MyFunction()
RETURNS trigger
AS $BODY$
BEGIN
  -- Проверяем, выполняется ли условие для блокировки удаления
  IF OLD.model LIKE '%A320%' THEN
    -- Выводим сообщение пользователю
    RAISE EXCEPTION 'Deleting A320 aircraft is not allowed.';
  END IF;

  -- Если условие не выполняется, возвращаем NULL (триггер не блокирует удаление)
  RETURN OLD;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_aircraft_deletion_trigger
BEFORE DELETE ON bookings.aircrafts
FOR EACH ROW
EXECUTE FUNCTION F_MyFunction();

SELECT * FROM aircrafts;
-- Попытка удаления A-320
DELETE FROM bookings.aircrafts WHERE model LIKE '%A320%';


--3.2 Создать таблицу
-- bookings.flights_history (flight_id, flight_no, operation, date_operation, time_operation),
-- в которую с помощью триггеров сохранять данные о проводимых изменениях  в таблице bookings.flights  с указанием даты и времени
CREATE TABLE bookings.flights_history
(
    flight_id int primary key,
    flight_no varchar(6) NOT NULL,
    operation text NOT NULL,
    date_operation date NOT NULL,
    time_operation time NOT NULL
);
DROP TABLE bookings.flights_history;

-- Создаем функцию, которая будет использоваться в триггере
CREATE OR REPLACE FUNCTION log_flight_changes()
RETURNS TRIGGER
AS $$
BEGIN
    -- Вставляем запись в таблицу flights_history при выполнении операции INSERT
    IF TG_OP = 'INSERT' THEN
        INSERT INTO bookings.flights_history VALUES
            (NEW.flight_id, NEW.flight_no, TG_OP , CURRENT_DATE, CURRENT_TIME);
    -- Вставляем запись в таблицу flights_history при выполнении операции UPDATE
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO bookings.flights_history VALUES
            (NEW.flight_id, NEW.flight_no, TG_OP , CURRENT_DATE, CURRENT_TIME);
    -- Вставляем запись в таблицу flights_history при выполнении операции DELETE
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO bookings.flights_history VALUES
            (OLD.flight_id, OLD.flight_no, TG_OP , CURRENT_DATE, CURRENT_TIME);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер для выполнения функции log_flight_changes перед операциями INSERT, UPDATE или DELETE в таблице flights
CREATE TRIGGER log_flight_changes_trigger
BEFORE INSERT OR UPDATE OR DELETE ON bookings.flights
FOR EACH ROW
EXECUTE FUNCTION log_flight_changes();

--Смотрим что у нас есть в bookings.flights
SELECT * FROM bookings.flights;

--Проверяем
UPDATE bookings.flights
SET flight_id = 1
WHERE flight_id = 1;

--Смотрим
SELECT * FROM bookings.flights_history;


--3.3 При попытке удаления места из таблицы bookings.seats заблокировать удаление, если на это место были выданы посадочные талоны.

-- Создаем функцию, которая будет использоваться в триггере
CREATE OR REPLACE FUNCTION prevent_delete_seats()
RETURNS TRIGGER
AS $$
BEGIN
    -- Проверяем, есть ли посадочные талоны для удаляемого места
    IF EXISTS (
        SELECT 1
        FROM bookings.boarding_passes
        WHERE seat_no = OLD.seat_no
    ) THEN
        RAISE EXCEPTION 'Нельзя удалить место, для которого уже выдан посадочный талон.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер для выполнения функции prevent_delete_seats перед операцией DELETE в таблице seats
CREATE TRIGGER before_delete_seats
BEFORE DELETE ON bookings.seats
FOR EACH ROW
EXECUTE FUNCTION prevent_delete_seats();

--Выберем места, посадочные талоны на которые выданы
SELECT * FROM bookings.seats
    WHERE seat_no LIKE '2A';
SELECT * FROM bookings.boarding_passes
    WHERE seat_no LIKE '2A';

--Проверка
DELETE FROM bookings.seats
WHERE seat_no = '2A';


-- 3.4 При изменении стоимости перелета с помощью триггера проверить, что стоимость не изменилась более чем на 10%.

CREATE OR REPLACE FUNCTION cost_change() RETURNS TRIGGER AS $$
DECLARE
    old_cost real;
    new_cost real;
BEGIN
    -- Проверяем, поменялась ли цена
    -- Получаем старую и новую стоимость
    old_cost := OLD.total_amount;
    new_cost := NEW.total_amount;

    -- Проверяем, изменилась ли стоимость более чем на 10%
    IF ABS(old_cost - new_cost) / old_cost > 0.1 THEN
        RAISE EXCEPTION 'Изменение стоимости более чем на 10%% не разрешено.';
    END IF;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_change_cost
    AFTER UPDATE ON bookings.bookings
    FOR EACH ROW
EXECUTE FUNCTION cost_change();

--Смотрим таблицу с ценами на билеты
SELECT * FROM bookings.bookings;

--Пробуем изменить цену более чем на 10%
UPDATE bookings.bookings
SET total_amount = 50000.00
WHERE book_ref = '00000F';


-- 3.5 При регистрации пассажира проверить, что он регистрируется на тот рейс, на который у него есть билет

CREATE OR REPLACE FUNCTION registration_check() RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT ticket_no, flight_id
        FROM bookings.ticket_flights
        WHERE ticket_no = NEW.ticket_no AND flight_id = NEW.flight_id
    )
    THEN RAISE EXCEPTION 'Ошибка. Сочетание номера билета и номера рейса не найдено в системе.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_passenger
    BEFORE INSERT ON bookings.boarding_passes
    FOR EACH ROW
EXECUTE FUNCTION registration_check();

DROP TRIGGER before_insert_passenger ON bookings.boarding_passes;

--Таблица с парой ticket_no, flight_id, смотрим все билеты
SELECT * FROM bookings.ticket_flights;

--Таблица с регистрацией на рейс, смотрим зарегестрированные билеты
SELECT * FROM bookings.boarding_passes;

--Смотрим какие билеты еще не зарегистрированы в bookings.boarding_passes
SELECT ticket_no, flight_id
FROM bookings.ticket_flights
EXCEPT
SELECT ticket_no, flight_id
FROM bookings.boarding_passes;

--Смотрим вручную
--Есть ли такой билет
SELECT * FROM bookings.tickets
WHERE ticket_no = '0005432001051';
--Проверяем зарегистрирован ли этот билет на рейс
SELECT ticket_no FROM bookings.boarding_passes
WHERE ticket_no = '0005432001051';

--Пробуем зарегистрировать пасссажира не на его рейс
INSERT INTO bookings.boarding_passes VALUES
('0005432001051', 28916, 93, '1A');

--Пробуем зарегистрировать пасссажира на его рейс
INSERT INTO bookings.boarding_passes VALUES
('0005432001051', 28910, 93, '1A');

--Удаляем, чтобы не испортить таблицу
DELETE FROM bookings.boarding_passes
WHERE ticket_no = '0005432001051';


-- 3.6 Придумать и реализовать 3 триггера для БД по индивидуальному заданию.
-- Триггеры и функции находятся в самой БД
-- 1 При добавлении артистов на концерт проверять, что они в это время не участвуют в другом концерте

CREATE OR REPLACE FUNCTION check_artist_add() RETURNS TRIGGER AS $$
DECLARE
    other_concert_date date;
BEGIN
    SELECT concert_date
    INTO other_concert_date
    FROM concert
    WHERE concert_id = NEW.concert_id;

    IF EXISTS (
        SELECT 1
        FROM performer_on_the_concert AS potc
        JOIN concert AS c ON potc.concert_id = c.concert_id
        WHERE potc.artist_id = NEW.artist_id
          AND c.concert_date::DATE = other_concert_date
    )
    THEN
        RAISE EXCEPTION 'Артист уже участвует на другом концерте в это время';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_check
    BEFORE INSERT ON performer_on_the_concert
    FOR EACH ROW
    EXECUTE FUNCTION check_artist_add();
--Проверка
INSERT INTO performer_on_the_concert VALUES(2, 11);

-- DROP FUNCTION check_artist_add() CASCADE;
-- DELETE FROM performer_on_the_concert WHERE artist_id = 2 AND concert_id = 11;


-- 2 При добавлении концерта проверить, что в этом месте в это же время не идет другого концерта
CREATE OR REPLACE FUNCTION add_concert_check() RETURNS TRIGGER AS $$
DECLARE
BEGIN
    IF EXISTS (SELECT 1
               FROM concert
               WHERE venue_id = NEW.venue_id
                 AND concert_date::DATE = NEW.concert_date::DATE)
        THEN RAISE EXCEPTION 'В этом месте, в это время идет другой концерт';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_add_concert
    BEFORE INSERT ON concert
    FOR EACH ROW
EXECUTE FUNCTION add_concert_check();
-- Проверка
-- SELECT *
-- FROM concert;
INSERT INTO concert VALUES (12, 'Bad Time Rush', '2024-01-10 18:00:00-04', 1);

-- DELETE FROM concert WHERE concert_id = 12;


--3 При продаже билета проверить, что не превысилась вместимость людей на концерт

CREATE OR REPLACE FUNCTION check_venue_capacity()
RETURNS TRIGGER AS $$
DECLARE
    tickets_sold INT;
    venue_capacity INT;
BEGIN
    SELECT COUNT(*) INTO tickets_sold FROM ticket
    WHERE concert_id = NEW.concert_id;

    SELECT people_capacity INTO venue_capacity FROM venue
    WHERE venue_id = (SELECT venue_id FROM concert WHERE concert_id = NEW.concert_id);

    IF tickets_sold >= venue_capacity THEN RAISE EXCEPTION 'Продажи билетов превышают вместимость места для концерта %', NEW.concert_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_ticket
BEFORE INSERT ON ticket
FOR EACH ROW
EXECUTE FUNCTION check_venue_capacity();

--Проверка
-- SELECT * FROM ticket;
INSERT INTO ticket VALUES (51, 499, 'Standard', 11);
-- DELETE FROM ticket WHERE ticket_id = 51;