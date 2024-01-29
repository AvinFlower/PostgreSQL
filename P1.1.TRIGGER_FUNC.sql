CREATE TABLE vkladish
(
    id serial primary key,
    N_ch int NOT NULL,
    id_el int NOT NULL,
    date_in date NOT NULL,
    date_out date NOT NULL
);

INSERT INTO vkladish (id, N_ch, id_el, date_in, date_out)
VALUES (default, 5, 8, '10-11-2023'::DATE, NULL);

CREATE trigger vkl_ins_before_row
    BEFORE INSERT
    ON vkladish
    FOR EACH ROW
    EXECUTE FUNCTION vkladish_check();

CREATE OR REPLACE FUNCTION vkladish_check() RETURNS trigger
AS $body$
BEGIN
    IF (SELECT COUNT(*) FROM vkladish WHERE date_out IS NULL and N_ch = new.N_ch) < 5
    THEN
    RETURN NEW;
    ELSE RAISE EXCEPTION 'уже 5 книг на руках';
    END IF;
END; $body$ language plpgsql;




UPDATE vkladish  SET date_out = current_date
WHERE id = 765;

CREATE trigger vkl_upd_after_row
    AFTER UPDATE
    ON vkladish
    FOR EACH ROW
    EXECUTE FUNCTION vkladish_return();


CREATE OR REPLACE FUNCTION vkladish_return() RETURNS trigger
AS $body$
BEGIN
    UPDATE entity_book SET count_entity = count_entity + 1
    WHERE id_el = new.id_el;
    RETURN NEW;
END; $body$ language plpgsql;




