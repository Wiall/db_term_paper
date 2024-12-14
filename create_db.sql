DROP DATABASE IF EXISTS exam_db;

CREATE DATABASE exam_db;
USE exam_db;

CREATE TABLE School (
    id_school INT NOT NULL CHECK (id_school > 0),
    name_school VARCHAR(50) NOT NULL,
    type_of_edu_inst VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL,
    street VARCHAR(50) NOT NULL,
    build_num VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,

    CONSTRAINT PK_School PRIMARY KEY (id_school)
);

CREATE TABLE Student(
    id_student INT NOT NULL CHECK (id_student > 0),
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(16) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    region VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL,
    school_id INT NOT NULL,
    comp_score DECIMAL,

    CONSTRAINT PK_Student PRIMARY KEY (id_student),
    CONSTRAINT FK_Student_School FOREIGN KEY (school_id) REFERENCES School(id_school)
                    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Student_docs (
    number VARCHAR(16) NOT NULL,
    type_of_document VARCHAR(50) NOT NULL,
    document_issuance_date DATETIME NOT NULL,
    issued_by VARCHAR(50) NOT NULL,
    student INT NOT NULL,

    CONSTRAINT PK_Student_docs PRIMARY KEY (number),
    CONSTRAINT FK_Docs FOREIGN KEY (student) REFERENCES Student(id_student)
                    ON DELETE CASCADE ON UPDATE CASCADE
);



CREATE TABLE Subject (
    id_subject INT NOT NULL CHECK ( id_subject > 0 ),
    name_of_subject VARCHAR(50) UNIQUE NOT NULL,
    type_of_subject VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Subject PRIMARY KEY (id_subject),
    CONSTRAINT UQ_Subject_Name UNIQUE (name_of_subject)
);

CREATE TABLE Exam (
    id_exam INT NOT NULL CHECK ( id_exam > 0 ),
    date_of_holding DATETIME NOT NULL,
    form_of_conduct VARCHAR(50) NOT NULL,
    difficulty_level VARCHAR(50) NOT NULL,
    session VARCHAR(50) NOT NULL,
    max_score INT DEFAULT 200,
    passing_score INT DEFAULT 125,
    duration TIME NOT NULL DEFAULT '04:00:00',
    time_of_starting DATETIME NOT NULL,
    id_subject INT NOT NULL,

    CONSTRAINT PK_Exam PRIMARY KEY (id_exam),
    CONSTRAINT FK_Exam_Subject FOREIGN KEY (id_subject) REFERENCES Subject(id_subject)
                    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Registration_docs(
    number VARCHAR(16) NOT NULL,
    date_of_registration DATETIME NOT NULL,
    status VARCHAR(50) NOT NULL,
    id_student INT NOT NULL,
    id_exam INT NOT NULL,

    CONSTRAINT PK_Registration_docs PRIMARY KEY (number),
    CONSTRAINT UNIQUE_Student_Exam UNIQUE (id_student, id_exam),
    CONSTRAINT FK_Student_Exam_student FOREIGN KEY (id_student) REFERENCES Student(id_student)
                          ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Student_Exam_exam FOREIGN KEY (id_exam) REFERENCES Exam(id_exam)
                          ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Testing_center (
    id_testing_center INT NOT NULL CHECK ( id_testing_center > 0 ),
    name_of_test_center VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    region VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL,
    street VARCHAR(50) NOT NULL,
    build_num VARCHAR(8) NOT NULL,
    capacity INT NOT NULL CHECK ( capacity > 0 AND capacity < 3000),

    CONSTRAINT PK_Testing_center PRIMARY KEY (id_testing_center)
);

CREATE TABLE Exam_Testing_center(
    record_id INT NOT NULL AUTO_INCREMENT,
    audience_number VARCHAR(5),
    id_exam INT NOT NULL,
    id_testing_center INT NOT NULL,

    CONSTRAINT PK_Exam_Testing_center PRIMARY KEY (record_id),
    CONSTRAINT UQ_Exam_Testing_center UNIQUE (id_exam, id_testing_center),
    CONSTRAINT FK_Exam_Testing_center_exam FOREIGN KEY (id_exam) REFERENCES Exam(id_exam)
                                ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Exam_Testing_center_center FOREIGN KEY (id_testing_center) REFERENCES Testing_center(id_testing_center)
                                ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Grade (
    id_grade INT NOT NULL AUTO_INCREMENT,
    numerical_value INT NOT NULL,
    evaluation_date DATETIME NOT NULL,
    registration_docs_number VARCHAR(16) NOT NULL,
    CONSTRAINT PK_Grade PRIMARY KEY (id_grade),
    CONSTRAINT UNIQUE_Registration_docs UNIQUE (registration_docs_number),
    INDEX FK_Grade_Registration_docs_idx (registration_docs_number ASC) VISIBLE,
    CONSTRAINT FK_Grade_Registration_docs FOREIGN KEY (registration_docs_number) REFERENCES Registration_docs(number)
                                ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Appeal(
    appeal_id INT NOT NULL AUTO_INCREMENT,
    date_of_filing DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    status VARCHAR(20) NOT NULL,
    id_grade INT NOT NULL,
    CONSTRAINT PK_Appeal PRIMARY KEY (appeal_id),
    CONSTRAINT FK_Appeal_Grade FOREIGN KEY (id_grade) REFERENCES Grade(id_grade)
                   ON DELETE CASCADE ON UPDATE CASCADE

);

CREATE TABLE Certificate (
    number_of_certificate VARCHAR(16) NOT NULL,
    certificate_issuance_date DATETIME NOT NULL,
    year_of_certificate INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    id_student INT NOT NULL,

    CONSTRAINT PK_Certificate PRIMARY KEY (number_of_certificate),
    CONSTRAINT FK_Certificate_Student FOREIGN KEY (id_student) REFERENCES Student(id_student)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT UC_Student_Year UNIQUE (id_student, year_of_certificate)
);

-- Створюємо тригер для автоматичного заповнення поля year_of_certificate
DELIMITER //
CREATE TRIGGER before_insert_certificate
BEFORE INSERT ON Certificate
FOR EACH ROW
BEGIN
    SET NEW.year_of_certificate = YEAR(NEW.certificate_issuance_date);
END;
//
DELIMITER ;
