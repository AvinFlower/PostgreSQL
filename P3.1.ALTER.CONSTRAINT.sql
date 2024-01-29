CREATE TABLE student(
    student_id numeric ( 4 ),
    name text NOT NULL,
    PRIMARY KEY ( student_id )
);

CREATE TABLE progress(
    subject text NOT NULL,
    acad_year text NOT NULL,
    course numeric ( 1 ),
    mark numeric ( 1 ),
    student text NOT NULL
);

ALTER TABLE progress ADD CONSTRAINT ck_check CHECK(mark >= 2 and mark <=5);
ALTER TABLE progress ALTER COLUMN mark SET DEFAULT 5;
ALTER TABLE progress RENAME COLUMN mark TO "ToyotaMark2";
ALTER TABLE progress RENAME COLUMN student TO student_id;
ALTER TABLE progress ALTER COLUMN student_id TYPE int USING student_id::int;
ALTER TABLE progress ADD FOREIGN KEY(student_id) REFERENCES student(student_id)
ON DELETE CASCADE
ON UPDATE NO ACTION;
ALTER TABLE progress RENAME CONSTRAINT ck_check TO progress_key;
ALTER TABLE progress DROP COLUMN course;
ALTER TABLE student ADD COLUMN Email varchar(25) UNIQUE;
