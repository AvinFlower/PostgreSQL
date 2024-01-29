CREATE DATABASE SELECT2;
CREATE SCHEMA selecting;

CREATE TABLE "group"
(
    idgr INT PRIMARY KEY NOT NULL,
    name TEXT
);

CREATE TABLE student
(
    idst    INT PRIMARY KEY NOT NULL,
    f       TEXT,
    i       TEXT,
    o       TEXT,
    dateofb DATE,
    idgr    INT REFERENCES "group" (idgr)
);

CREATE TABLE subject
(
    idsub INT PRIMARY KEY NOT NULL,
    names TEXT
);

CREATE TABLE marks
(
    idmark  INT PRIMARY KEY NOT NULL,
    idst    INT REFERENCES student (idst),
    idsub   INT REFERENCES subject (idsub),
    datem   DATE,
    mark    INT,
    semestr INT
);

INSERT INTO "group" (idgr, name)
VALUES (1, 'one');

INSERT INTO student (idst, f, i, o, dateofb, idgr)
VALUES (1, 'a', 'a', 'a', '20101206', 1),
       (2, 'b', 'a', 'a', NULL, 1);

INSERT INTO student (idst, f, i, o, dateofb, idgr)
VALUES (3, 'c', 'a', 'a', NULL, 1);

INSERT INTO subject (idsub, names)
VALUES (1, 'aa'),
       (2, 'bb');

INSERT INTO marks (idmark, idst, idsub, datem, mark, semestr)
VALUES (1, 1, 1, '20101206', 5, 1),
       (2, 1, 2, NULL, 5, 1);

INSERT INTO marks (idmark, idst, idsub, datem, mark, semestr)
VALUES (4, 2, 2, NULL, 2, 1);

INSERT INTO marks (idmark, idst, idsub, datem, mark, semestr)
VALUES (3, 2, 1, NULL, NULL, 2);

DELETE
FROM student
WHERE idst IN (SELECT idst
               FROM (SELECT idst, idsub, count(*) AS cnt
                     FROM student s
                              JOIN marks m ON s.idst = m.idst
                     WHERE m.mark IS NULL OR m.mark = 2
                     GROUP BY idst, idsub)
               WHERE cnt >= 3);

--Какой запрос выведет список студентов c указанием группы и их оценки с указанием предмета. Если студент не сдавал экзамен, он должен быть выведен
SELECT *
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         LEFT JOIN marks ON (marks.idst = student.idst)
         LEFT JOIN subject ON (subject.idsub = marks.idsub);

--Какой запрос выведет список студентов c указанием группы и их оценки с указанием предмета. Если студент не сдавал экзамен, он должен быть выведен Отсортировать по фамилии, имени студента по возрастанию и оценке по убыванию
SELECT *
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         LEFT JOIN marks ON (marks.idst = student.idst)
         JOIN subject ON (subject.idsub = marks.idsub)
ORDER BY f, i, mark DESC;

--Какой запрос выведет список студентов c указанием группы и количество экзаменов, за которые студент получил оценку?
--Если студент не сдавал экзамен, информации о нем таблице Marks нет, и в результате его быть не должно.
--Если не явился на экзамен, то запись в Marks есть, а в поле Mark значение NULL.
--Отсортировать по фамилии, имени студента
SELECT f, i, name, count(mark)
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         JOIN marks ON (marks.idst = student.idst)
         JOIN subject ON (subject.idsub = marks.idsub)
GROUP BY f, i, name
ORDER BY f, i;

--Какой запрос выведет список студентов c указанием группы и средний балл за экзамены,
--за которые студент получил оценку?
--Если студент не сдавал экзамен, информации о нем таблице Marks нет, и в результате его быть не должно.
--Если не явился на экзамен, то запись в Marks есть, а в поле Mark значение NULL.
--Отсортировать по фамилии, имени студента
SELECT f, i, name, avg(mark)
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         JOIN marks ON (marks.idst = student.idst)
         JOIN subject ON (subject.idsub = marks.idsub)
GROUP BY f, i, name
ORDER BY f, i;

--Какой запрос выведет список студентов c указанием сдаваемого предмета, вывести только студентов сдававших Математику.
SELECT f, i, o, names
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         JOIN marks ON (marks.idst = student.idst)
         JOIN subject ON (subject.idsub = marks.idsub)
WHERE names = 'Математика';

--Какой запрос выведет список всех студентов группы ПМИ-31 и значения их оценок за 5 семестр. Если студент не сдавал экзамен в результате он должен быть отображен.
SELECT f, i, o, mark
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         LEFT JOIN marks ON (marks.idst = student.idst)
WHERE name = 'ПМИ-31' AND semestr = '5';

--Какой запрос выведет список групп и количество студентов в них, причем количество студентов в группе должно быть меньше 8.
SELECT name, count(*)
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
--ничего не надо писать
GROUP BY name
HAVING count(*) < 8;

--Какой запрос выведет список предметов, которые сдавала группа ПМИ-31, причем количество полученных студентами оценок было больше 10.
SELECT names
FROM "group"
         JOIN student ON ("group".idgr = student.idgr)
         JOIN marks ON (marks.idst = student.idst)
         JOIN subject ON (subject.idsub = marks.idsub)
WHERE name = 'ПМИ-31'
--больше в условие не надо ничего дописывать
GROUP BY names
HAVING count(mark) > 10;

SELECT f, i, o
FROM student
         JOIN "group" ON (student.idgr = "group".idgr)
WHERE name LIKE 'ИТб%'
UNION
SELECT f, i, o
FROM student
         JOIN "group" ON (student.idgr = "group".idgr)
WHERE name LIKE 'ИВТб%';

SELECT f, i, o, extract(MONTH FROM dateofb), extract(DAY FROM dateofb)
FROM student
INTERSECT
SELECT DISTINCT f, i, o, extract(MONTH FROM datem), extract(DAY FROM datem)
FROM student
         JOIN marks ON (marks.idst = student.idst);

SELECT f, i, o
FROM student
WHERE idst IN (SELECT idst
               FROM student
               EXCEPT
               SELECT idst
               FROM marks
               WHERE semestr = 1 AND mark = 5);

SELECT f, i, o
FROM student
WHERE idst IN (SELECT idst
               FROM marks
               WHERE semestr = 1 AND mark = 5);

SELECT DISTINCT f, i, o, extract(MONTH FROM dateofb), extract(DAY FROM dateofb)
FROM student st
WHERE exists (SELECT
              FROM marks m
              WHERE (m.idst = st.idst)
                AND extract(MONTH FROM dateofb) = extract(MONTH FROM datem)
                AND extract(DAY FROM dateofb) = extract(DAY FROM datem));


CREATE TABLE pupil
(
    id     INT NOT NULL PRIMARY KEY,
    f      VARCHAR(20),
    i      VARCHAR(20),
    dob    DATE,
    rating INT
);

INSERT INTO pupil
VALUES (1, 'Иванов', 'Иван', '2010-01-02', 100),
       (2, 'Петров', 'Петр', '2010-05-02', 120),
       (3, 'Васиков', 'Василий', '2010-03-07', NULL),
       (4, 'Сидоров', 'Сидор', '2009-09-06', 90),
       (5, 'Петров', 'Сидор', '2009-11-03', 80),
       (6, 'Петров', 'Сидор', '2010-12-06', 0);

SELECT count(*),               --6
       -- avg(*),                 --ошибка
       count(id),              --6
       count(rating),          --5
       avg(rating),            --78
       sum(rating) / count(*), --65
       max(dob),               --20101206
       min(rating)             --0
FROM pupil;


CREATE VIEW result_of_last_semester
AS
    SELECT DISTINCT g.name                                    AS "Группа",
                    st.f                                      AS "Фамилия студента",
                    st.i                                      AS "Имя студента",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 2) AS "2",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 3) AS "3",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 4) AS "4",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 5) AS "5"
    FROM "group" g
             JOIN student st ON g.idgr = st.idgr
             JOIN marks m ON st.idst = m.idst
    WHERE m.semestr = (SELECT max(semestr)
                       FROM marks)
    ORDER BY g.name, st.f;

CREATE MATERIALIZED VIEW result_of_last_semester
AS
    SELECT DISTINCT g.name                                    AS "Группа",
                    st.f                                      AS "Фамилия студента",
                    st.i                                      AS "Имя студента",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 2) AS "2",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 3) AS "3",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 4) AS "4",
                    (SELECT count(*)
                     FROM marks m1
                     WHERE st.idst = m1.idst AND m1.mark = 5) AS "5"
    FROM "group" g
             JOIN student st ON g.idgr = st.idgr
             JOIN marks m ON st.idst = m.idst
    WHERE m.semestr = (SELECT max(semestr)
                       FROM marks)
    ORDER BY g.name, st.f;

CREATE TABLE vkladish
(
    id       INT NOT NULL,
    n_ch     INT NOT NULL,
    id_el    INT NOT NULL,
    date_in  DATE,
    date_out DATE
);


INSERT INTO vkladish (id, n_ch, id_el, date_in, date_out)
VALUES (1, 5, 8, '10-11-2023'::DATE, NULL);

INSERT INTO vkladish (id, n_ch, id_el, date_in, date_out)
VALUES (1, 5, 10, '10-11-2023'::DATE, NULL);

CREATE OR REPLACE TRIGGER vkladish_insert_before_row
    BEFORE INSERT
    ON vkladish
    FOR EACH ROW
EXECUTE FUNCTION vkladish_check();

CREATE OR REPLACE FUNCTION vkladish_check() RETURNS TRIGGER
AS
$body$
BEGIN
    IF ((SELECT count(*)
         FROM vkladish
         WHERE date_out IS NULL AND n_ch = new.n_ch) < 2)
    THEN
        RETURN new;
    ELSE
        RAISE EXCEPTION 'уже 5 книг на руках';
    END IF;
END;
$body$
    LANGUAGE plpgsql;

UPDATE vkladish
SET date_out = current_date
WHERE id = 765;

CREATE OR REPLACE TRIGGER vkladish_update_after_row
    AFTER UPDATE
    ON vkladish
    FOR EACH ROW
EXECUTE FUNCTION vkladish_return();

CREATE OR REPLACE FUNCTION vkladish_return() RETURNS TRIGGER
AS
$body$
BEGIN
    UPDATE entity_book
    SET count_entity = count_entity + 1
    WHERE id_entiy = new.id_el;
    RETURN new;
END;
$body$
    LANGUAGE plpgsql;


CREATE TABLE bookings.flights_history
(
    flight_id      INT     NOT NULL,
    flight_no      CHAR(6) NOT NULL,
    operation      TEXT    NOT NULL,
    date_operation DATE    NOT NULL DEFAULT current_date,
    time_operation TIME    NOT NULL DEFAULT current_time
);

CREATE OR REPLACE TRIGGER flights_history_after_statement
    AFTER INSERT OR UPDATE OR DELETE
    ON flights
    FOR EACH ROW
EXECUTE FUNCTION log_flights();

CREATE OR REPLACE FUNCTION log_flights() RETURNS TRIGGER
AS
$$
BEGIN
    INSERT INTO bookings.flights_history (flight_id, flight_no, operation)
    VALUES (old.flight_id, old.flight_no, tg_op);
    RETURN old;
END;
$$
    LANGUAGE plpgsql;