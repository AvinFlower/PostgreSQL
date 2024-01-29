--1.1 Создайте роль creator без права входа в систему, но с правом создания баз данных и ролей.
CREATE ROLE creator CREATEROLE CREATEDB;

--1.2 Создайте пользователя weak с правом входа в систему.
--1.3 Убедитесь, что weak не может создать базу данных.
CREATE ROLE weak LOGIN PASSWORD '1';

--1.4 Включите пользователя weak в группу creator.
GRANT creator TO weak;
\c - weak
SET ROLE creator;
--1.5 Создайте новую базу данных под пользователем weak.
CREATE DATABASE weakdb;
--DROP DATABASE weakdb;


--2.1 Создайте новую базу данных и две роли: writer и reader.
CREATE DATABASE wr_rea_db;
--DROP DATABASE wr_rea_db;
\c wr_rea_db
--DROP DATABASE wr_rea_db;
SET SEARCH_PATH = public;

CREATE ROLE writer;
--DROP ROLE writer;
CREATE ROLE reader;
--DROP ROLE reader;

--2.2. Отзыв привилегий у роли public, назначение привилегий writer и reader
\dp+ public.*

REVOKE ALL PRIVILEGES ON SCHEMA public FROM public;
--GRANT ALL PRIVILEGES ON SCHEMA public TO public;

GRANT USAGE, CREATE ON SCHEMA public TO writer;
--REVOKE USAGE, CREATE ON SCHEMA public FROM writer;

GRANT USAGE ON SCHEMA public TO reader;
--REVOKE USAGE ON SCHEMA public FROM reader;

--2.3. Настройте привилегии по умолчанию так, чтобы роль reader получала доступ на чтение к таблицам, принадлежащим writer в схеме public.
ALTER DEFAULT PRIVILEGES FOR ROLE writer GRANT SELECT ON TABLES TO reader;
--ALTER DEFAULT PRIVILEGES FOR ROLE writer REVOKE SELECT ON TABLES FROM reader;


--2.4. Создание пользователей w1 в группе writer и r1 в группе reader
CREATE USER w1 LOGIN PASSWORD '1';
GRANT writer TO w1;
--DROP USER w1;

CREATE USER r1 LOGIN PASSWORD '1';
GRANT reader TO r1;
--DROP USER r1;

--2.5. Создание таблицы под пользователем writer
\c - w1
SET ROLE writer;
CREATE TABLE title (
    id int PRIMARY KEY,
    data text NOT NULL
);
--DROP TABLE tittle;

-- Под пользователем w1 выборка из таблицы (должна выполниться без ошибок)
SELECT * FROM title;
-- Под пользователем w1 удаление из таблицы (должно выполниться без ошибок)
DELETE FROM title;

--2.6. Проверка доступа для пользователей r1 и w1 к таблице

\c - r1
-- Под пользователем r1 выборка из таблицы (должна выполниться без ошибок)
SELECT * FROM title;
-- Под пользователем r1 попытка удаления из таблицы (должна вызвать ошибку)
DELETE FROM title;

--2.7. Возврат привилегий роли public на схему public
GRANT ALL PRIVILEGES ON SCHEMA public TO public;

--Задание 3
CREATE ROLE main_programmist;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA concert_agency TO main_programmist;

CREATE ROLE orders_manager;
GRANT SELECT, DELETE, UPDATE ON TABLE concert_agency."order", concert_agency.client TO orders_manager;

CREATE ROLE controller_manager;
GRANT SELECT, DELETE, UPDATE ON TABLE concert_agency.ticket TO controller_manager;