-- drop database my_base;
-- create tablespace my_main_base location 'D:\\tablespaces\\my_main_base';
-- create database my_base tablespace my_main_base;
-- create schema concert_agency;
-- SET search_path = concert_agency;
-- drop schema concert_agency CASCADE;
--\с my_base
--drop tablespace my_main_base;

CREATE DOMAIN price AS money
CHECK ( VALUE::numeric > 0 );

CREATE TABLE countries
(
    country_id serial primary key,
    country_name varchar(30) NOT NULL
);
INSERT INTO countries (country_name)
VALUES
  ('USA'),
  ('UK'),
  ('France'),
  ('Germany'),
  ('Japan'),
  ('Australia'),
  ('Canada'),
  ('Mexico'),
  ('Brazil'),
  ('Colombia');


CREATE TABLE cities
(
    city_id serial primary key,
    city_name varchar(30) NOT NULL,
    country_id int NOT NULL
        REFERENCES countries(country_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO cities (city_name, country_id)
VALUES
  ('Los Angeles', 1),
  ('New York', 1),
  ('London', 2),
  ('Paris', 3),
  ('Berlin', 4),
  ('Tokyo', 5),
  ('Sydney', 6),
  ('Toronto', 7),
  ('Mexico City', 8),
  ('Sao Paulo', 9),
  ('Vancouver', 7),
  ('Bogota', 10);


create table venue
(
	venue_id serial primary key,
	place_name varchar(30) NOT NULL,
    people_capacity int NOT NULL,
    city_id int NOT NULL
        REFERENCES cities(city_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO venue
VALUES
  (1, 'Dodger Stadium', 50000, 1),
  (2, 'Madison Square Garden', 20000, 2),
  (3, 'Royal Albert Hall', 5000, 3),
  (4, 'Stade de France', 80000, 4),
  (5, 'Mercedes-Benz Arena', 18000, 5),
  (6, 'Tokyo Dome', 55000, 6),
  (7, 'Sydney Opera House', 5500, 7),
  (8, 'Rogers Centre', 53000, 8),
  (9, 'Auditorio Nacional', 10000, 9),
  (10, 'Estádio do Morumbi', 67000, 10),
  (11, 'Im Room', 5, 1);


create table concert
(	
	concert_id serial primary key,
	concert_name varchar(30) NOT NULL,
    concert_date timestamp with time zone NOT NULL,
    venue_id int NOT NULL
        REFERENCES Venue(venue_id) ON DELETE NO ACTION ON UPDATE CASCADE
);
INSERT INTO concert
VALUES
  (1, 'Concert A', '2023-02-01 18:00:00+01', 1),
  (2, 'Live Performance B', '2023-11-15 19:30:00-02', 2),
  (3, 'Music Fest C', '2023-11-25 20:15:00-03', 3),
  (4, 'Rock Show D', '2023-12-05 17:45:00-03', 4),
  (5, 'Pop Concert E', '2023-12-20 21:00:00+05', 5),
  (6, 'Jazz Night F', '2024-01-10 19:00:00-04', 6),
  (7, 'Country Music G', '2024-01-20 20:30:00-06', 7),
  (8, 'Hip-Hop Jam H', '2024-02-05 18:30:00+07', 8),
  (9, 'Classical Performance I', '2024-02-15 19:45:00-07', 9),
  (10, 'Electronic Dance Party J', '2024-03-01 21:15:00-01', 10),
  (11, 'Chaga Chaga Dance', '2023-02-01 20:00:00+01', 11);


create table manager
(	
	manager_id serial primary key,
	manager_name varchar(40) NOT NULL,
	manager_phone_num varchar(18) NOT NULL,
    manager_email varchar(320) NOT NULL,
    UNIQUE (manager_phone_num, manager_email)
);
INSERT INTO manager
VALUES
  (1, 'John Doe', '1-880-123-4567', 'john.doe@example.com'),
  (2, 'Jane Smith', '1-812-987-6543', 'jane.smith@example.com'),
  (3, 'Michael Johnson', '1-834-555-1212', 'michael.johnson@example.com'),
  (4, 'Emily Davis', '1-856-777-8888', 'emily.davis@example.com'),
  (5, 'David Wilson', '1-879-444-3333', 'david.wilson@example.com'),
  (6, 'Sarah Harris', '1-881-999-1111', 'sarah.harris@example.com'),
  (7, 'Robert Martin', '7-912-736-6610', 'robert.martin@example.com'),
  (8, 'Susan Hall', '1-845-888-7777', 'susan.hall@example.com'),
  (9, 'Richard White', '1-867-123-9876', 'richard.white@example.com'),
  (10, 'Linda Turner', '234-803-1234-5678', 'linda.turner@example.com');


create table manager_on_the_concert
(	
	manager_id int NOT NULL
	    REFERENCES manager(manager_id) ON DELETE CASCADE ON UPDATE CASCADE,
	concert_id int NOT NULL
	    REFERENCES concert(concert_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(manager_id, concert_id)
);
INSERT INTO manager_on_the_concert
VALUES
    (1, 2),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10);


create table artist
(	
	artist_id serial primary key,
	artist_nickname varchar(30) NOT NULL,
	artist_birthday date NOT NULL,
    city_id int NOT NULL
        REFERENCES cities(city_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO artist
VALUES
  (1, 'Beyoncé', '1981-09-04', 1),
  (2, 'Elton John', '1947-03-25', 3),
  (3, 'Adele', '1988-05-05', 3),
  (4, 'Justin Bieber', '1994-03-01', 8),
  (5, 'Shakira', '1977-02-02', 12),
  (6, 'Coldplay', '1996-01-16', 3),
  (7, 'Taylor Swift', '1989-12-13', 1),
  (8, 'Ed Sheeran', '1991-02-17', 3),
  (9, 'Ariana Grande', '1993-06-26', 1),
  (10, 'Drake', '1986-10-24', 8);


create table performer_on_the_concert
(	
	artist_id int
	    REFERENCES artist(artist_id) ON DELETE CASCADE ON UPDATE CASCADE,
	concert_id int
	    REFERENCES concert(concert_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY(artist_id, concert_id)
);
INSERT INTO performer_on_the_concert
VALUES
  (1, 10),
  (2, 1),
  (3, 2),
  (4, 3),
  (5, 4),
  (6, 5),
  (7, 6),
  (8, 7),
  (9, 8),
  (10, 9);


create table artists_rider
(	
	rider_id serial primary key,
	technical_part text NOT NULL,
    economic_part text NOT NULL,
    rider_date date NOT NULL,
    artist_id int NOT NULL
        REFERENCES artist(artist_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO artists_rider
VALUES
  (1, 'Needs a specific stage layout for the artists performance.', 'A chauffeur-driven luxury vehicle for transportation.', '2024-03-01', 1),
  (2, 'Requires a grand piano and a drum kit on stage.', 'Payment of $50,000 for the performance.', '2023-11-01', 2),
  (3, 'Needs a soundproof recording studio backstage.', 'Special dietary requirements for the artist.', '2023-11-15', 3),
  (4, 'Requests a dedicated dressing room with specific amenities.', 'Transportation and accommodation costs covered.', '2023-11-25', 4),
  (5, 'Requires high-quality lighting and sound equipment.', 'A minimum of 100 backstage passes for the artists entourage.', '2023-12-05', 5),
  (6, 'Demands a special stage setup for unique visual effects.' , 'A fixed fee and a percentage of ticket sales.', '2023-12-20', 6),
  (7, 'Needs custom-designed costumes for the artist and the band.', 'A private chef to prepare meals.', '2024-01-10', 7),
  (8, 'Requests special pyrotechnics and fireworks for the performance.', 'First-class flights for the artist and the crew.', '2024-01-20', 8),
  (9, 'Requires a specific playlist for background music before the show.', 'Accommodation in luxury hotels.', '2024-02-05', 9),
  (10, 'Demands a particular selection of alcoholic and non-alcoholic beverages.', 'A private security detail for the artist.', '2024-02-15', 10);


CREATE TABLE ticket_buyer
(
    ticket_buyer_id serial primary key,
    firstname varchar(200) NOT NULL,
    lastname varchar(200) NOT NULL,
    phone_num varchar(18) NOT NULL
);
INSERT INTO ticket_buyer
VALUES
  (1, 'Иван', 'Иванов', '+7 (123) 456-7890'),
  (2, 'Мария', 'Петрова', '+7 (987) 654-3210'),
  (3, 'Александр', 'Сидоров', '+7 (111) 222-3333'),
  (4, 'Екатерина', 'Козлова', '+7 (444) 555-6666'),
  (5, 'Дмитрий', 'Федоров', '+7 (777) 888-9999'),
  (6, 'Ольга', 'Игнатова', '+7 (555) 444-3333'),
  (7, 'Сергей', 'Смирнов', '+7 (999) 888-7777'),
  (8, 'Анна', 'Кузнецова', '+7 (123) 456-7890'),
  (9, 'Павел', 'Лебедев', '+7 (987) 654-3210'),
  (10, 'Елена', 'Медведева', '+7 (111) 222-3333'),
  (11, 'Игорь', 'Соколов', '+7 (444) 555-6666'),
  (12, 'Наталья', 'Попова', '+7 (777) 888-9999'),
  (13, 'Алексей', 'Новиков', '+7 (555) 444-3333'),
  (14, 'Татьяна', 'Морозова', '+7 (999) 888-7777'),
  (15, 'Григорий', 'Петухов', '+7 (123) 456-7890'),
  (16, 'Светлана', 'Васнецова', '+7 (987) 654-3210'),
  (17, 'Максим', 'Жуков', '+7 (111) 222-3333'),
  (18, 'Евгения', 'Кравцова', '+7 (444) 555-6666'),
  (19, 'Владимир', 'Мельников', '+7 (777) 888-9999'),
  (20, 'Анастасия', 'Ковалева', '+7 (555) 444-3333'),
  (21, 'Илья', 'Беляков', '+7 (999) 888-7777'),
  (22, 'Оксана', 'Андреева', '+7 (123) 456-7890'),
  (23, 'Роман', 'Громов', '+7 (987) 654-3210'),
  (24, 'Маргарита', 'Орлова', '+7 (111) 222-3333'),
  (25, 'Артем', 'Комаров', '+7 (444) 555-6666'),
  (26, 'Валентина', 'Титова', '+7 (777) 888-9999'),
  (27, 'Денис', 'Сорокин', '+7 (555) 444-3333'),
  (28, 'Елена', 'Киселева', '+7 (999) 888-7777'),
  (29, 'Владислав', 'Макаров', '+7 (123) 456-7890'),
  (30, 'Юлия', 'Рыбакова', '+7 (987) 654-3210'),
  (31, 'Николай', 'Беляев', '+7 (111) 222-3333'),
  (32, 'Кристина', 'Семенова', '+7 (444) 555-6666'),
  (33, 'Сергей', 'Фролов', '+7 (777) 888-9999'),
  (34, 'Евгений', 'Исаев', '+7 (555) 444-3333'),
  (35, 'Алина', 'Тимофеева', '+7 (999) 888-7777'),
  (36, 'Артур', 'Гусев', '+7 (123) 456-7890'),
  (37, 'Юлия', 'Миронова', '+7 (987) 654-3210'),
  (38, 'Игорь', 'Куликов', '+7 (111) 222-3333'),
  (39, 'Марина', 'Федотова', '+7 (444) 555-6666'),
  (40, 'Глеб', 'Савельев', '+7 (777) 888-9999');


create table ticket
(	
	ticket_id serial primary key,
	ticket_cost price NOT NULL,
    ticket_type varchar(8) NOT NULL CHECK (ticket_type IN ('Platinum', 'VIP', 'Standard', 'Comfort')),
    concert_id int NOT NULL
        REFERENCES concert(concert_id) ON DELETE SET NULL ON UPDATE CASCADE,
    ticket_buyer_id int NOT NULL
        REFERENCES ticket_buyer(ticket_buyer_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO ticket
VALUES
    (1, 1025, 'Platinum', 7, 1),
    (2, 725, 'VIP', 6, 2),
    (3, 499, 'Standard', 2, 2),
    (4, 249, 'Comfort', 2, 3),
    (5, 249, 'Comfort', 3, 4),
    (6, 599, 'VIP', 3, 5),
    (7, 499, 'Standard', 4, 6),
    (8, 249, 'Comfort', 4, 7),
    (9, 499, 'Standard', 5, 8),
    (10, 499, 'Standard', 5, 9),
    (11, 1025, 'Platinum', 6, 10),
    (12, 1025, 'Platinum', 7, 11),
    (13, 725, 'VIP', 6, 12),
    (14, 499, 'Standard', 2, 12),
    (15, 249, 'Comfort', 2, 12),
    (16, 249, 'Comfort', 3, 13),
    (17, 599, 'VIP', 3, 14),
    (18, 499, 'Standard', 4, 15),
    (19, 249, 'Comfort', 4, 16),
    (20, 499, 'Standard', 5, 17),
    (21, 499, 'Standard', 5, 18),
    (22, 1025, 'Platinum', 6, 19),
    (23, 725, 'VIP', 6, 20),
    (24, 499, 'Standard', 2, 21),
    (25, 249, 'Comfort', 2, 22),
    (26, 249, 'Comfort', 3, 22),
    (27, 599, 'VIP', 3, 22),
    (28, 499, 'Standard', 4, 22),
    (29, 249, 'Comfort', 4, 22),
    (30, 499, 'Standard', 5, 23),
    (31, 499, 'Standard', 5, 1),
    (32, 1025, 'Platinum', 6, 24),
    (33, 725, 'VIP', 6, 25),
    (34, 499, 'Standard', 2, 26),
    (35, 249, 'Comfort', 2, 27),
    (36, 249, 'Comfort', 3, 28),
    (37, 599, 'VIP', 3, 29),
    (38, 499, 'Standard', 4, 30),
    (39, 249, 'Comfort', 4, 31),
    (40, 499, 'Standard', 5, 32),
    (41, 499, 'Standard', 5, 33),
    (42, 1025, 'Platinum', 6, 34),
    (43, 725, 'VIP', 6, 35),
    (44, 499, 'Standard', 2, 36),
    (45, 249, 'Comfort', 7, 37),
    (46, 499, 'Standard', 11, 38),
    (47, 599, 'VIP', 11, 39),
    (48, 499, 'Standard', 11, 40),
    (49, 499, 'Standard', 11, 40),
    (50, 499, 'Standard', 11, 40);


create table client
(	
	client_id serial primary key,
	cient_name varchar(50) NOT NULL,
    cient_surname varchar(50) NOT NULL,
    email varchar(320) NULL,
    client_phone_num varchar(18) NOT NULL,
    UNIQUE (email, client_phone_num)
);
INSERT INTO client
VALUES
  (1, 'Pharell', 'Williams', NULL, '1-829-123-4567'),
  (2, 'Sarah', 'Smith', 'sarah.smith@example.com', '1-809-123-4567'),
  (3, 'Michael', 'Johnson', 'michael.johnson@example.com', '506-6146-0805'),
  (4, 'Emily', 'Davis', 'emily.davis@example.com', '1-878-777-8888'),
  (5, 'David', 'Wilson', NULL, '1-684-770-0424'),
  (6, 'Susan', 'Harris', 'susan.harris@example.com', '1-801-999-1111'),
  (7, 'Robert', 'Martin', 'robert.martin@example.com', '234-823-222-3333'),
  (8, 'Sophia', 'Hall', 'sophia.hall@example.com', '1-885-888-7777'),
  (9, 'James', 'White', 'james.white@example.com', '973-6441-2304'),
  (10, 'Anastasia', 'Ozhegova', NULL, '7-912-666-9999');


create table "order"
(	
	order_id serial primary key,
	order_date date NOT NULL,
    total_cost price NOT NULL,
    order_status varchar(20) NOT NULL,
    client_id int NOT NULL
        REFERENCES client(client_id) ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "order"
VALUES
  (1, '2023-10-06', 35000, 'Completed', 1),
  (2, '2023-10-05', 75000, 'Completed', 2),
  (3, '2023-10-12', 120000, 'Completed', 3),
  (4, '2023-11-02', 55000, 'In Process', 4),
  (5, '2023-11-10', 95000, 'In Process', 5),
  (6, '2023-11-20', 35000, 'In Process', 6),
  (7, '2023-12-05', 135000, 'In Process', 7),
  (8, '2023-12-10', 25000, 'In Process', 8),
  (9, '2024-01-02', 30000, 'In Process', 9),
  (10, '2024-01-20', 105000, 'In Process', 10);

-------------------------------
--Р2.1

-- --В одной из таблиц изменить данные, согласно одному условию. Например, студентке Ивановой поменять фамилию на Петрова.
-- UPDATE manager
-- SET manager_phone_num = '1-800-111-2222'
-- WHERE manager_name = 'John Doe';
--
-- --В одной из таблиц изменить данные, согласно нескольким условиям(2 запроса). Например, студенту Сидорову с IDgr = 5 изменить IDgr на значение 9.
-- UPDATE "order"
-- SET order_status = 'In Process'
-- WHERE order_date < '2023-10-12' or order_id < 4;
--
-- UPDATE Concert
-- SET concert_date = '2024-01-10 18:00:00-04'
-- WHERE concert_date < '2023-10-29 18:30:00-04' or concert_name like 'J%';
--
-- --В одной из таблиц удалить данные, согласно одному условию. Например, отчислить всех студентов с фамилией  Иванов.
-- DELETE FROM Ticket
-- WHERE ticket_cost < 250;
--
-- --В одной из таблиц удалить данные, согласно нескольким условиям(2 запроса). Например, отчислить студента Сидорова с датой рождение '2001-01-01'.
-- DELETE FROM "order"
-- WHERE order_status = 'Completed' and order_id < 4;
--
-- DELETE FROM Manager
-- WHERE manager_phone_num LIKE '1-88%' and manager_email LIKE 'j%';

-----------------------------------------------------------------
--П3.3
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
--INSERT INTO performer_on_the_concert VALUES(2, 11);

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
--INSERT INTO concert VALUES (12, 'Bad Time Rush', '2024-01-10 18:00:00-04', 1);

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


--4 Удалить концерт можно только если он прошел
CREATE OR REPLACE FUNCTION delete_concert_func() RETURNS TRIGGER AS $$
    BEGIN
        IF OLD.concert_date < NOW() THEN
            DELETE FROM concert
                where concert_date = OLD.concert_date;
        ELSE RAISE EXCEPTION 'Нельзя удалять концерт, который еще не прошел';
        END IF;
        RETURN OLD;
    end;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER before_delete_cascade
    BEFORE DELETE ON concert
    FOR EACH ROW
    EXECUTE FUNCTION delete_concert_func();

--Проверка
-- SELECT * FROM ticket;
--INSERT INTO ticket VALUES (51, 499, 'Standard', 11);
-- DELETE FROM ticket WHERE ticket_id = 51;

--------------------------------------------------------------
-- Транзакции, Лабораторная работа

-- Транзакция для изменений в таблице "order"
-- BEGIN;
--
-- UPDATE "order"
-- SET order_status = 'In Process'
-- WHERE order_date < '2023-10-12' OR order_id < 4;
--
-- DELETE FROM "order"
-- WHERE order_status = 'Completed' AND order_id < 4;
--
-- COMMIT;
--
-- -- Транзакция для изменений в таблице "ticket"
-- BEGIN;
--
-- DELETE FROM ticket
-- WHERE concert_id = 2;
--
-- COMMIT;