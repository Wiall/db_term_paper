USE exam_db;

DROP PROCEDURE IF EXISTS AddSchool;
DELIMITER //
CREATE PROCEDURE AddSchool(
    IN p_name_school VARCHAR(50),
    IN p_type_of_edu_inst VARCHAR(50),
    IN p_region VARCHAR(50),
    IN p_district VARCHAR(50),
    IN p_street VARCHAR(50),
    IN p_build_num VARCHAR(50),
    IN p_contact_number VARCHAR(15),
    IN p_email VARCHAR(50)
)
BEGIN
        IF EXISTS (
        SELECT 1 FROM School
        WHERE contact_number = p_contact_number
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Контактний номер вже зайнятий.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM School
        WHERE email = p_email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email вже зайнятий.';
    END IF;

    INSERT INTO School ( name_school, type_of_edu_inst, region, district, street, build_num, contact_number, email)
    VALUES ( p_name_school, p_type_of_edu_inst, p_region, p_district, p_street, p_build_num, p_contact_number, p_email);
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE UpdateStudentPhone(
    IN p_id_student INT,
    IN p_new_phone_number VARCHAR(16)
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Student
        WHERE phone_number = p_new_phone_number
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Номер телефона вже зайнятий.';
    END IF;
    UPDATE Student
    SET phone_number = p_new_phone_number
    WHERE id_student = p_id_student;
END;
//
DELIMITER ;


DELIMITER //
CREATE FUNCTION GetStudentCount(p_school_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE student_count INT;
    SELECT COUNT(*) INTO student_count
    FROM Student
    WHERE school_id = p_school_id;
    RETURN student_count;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS DeleteSubject;
DELIMITER //
CREATE PROCEDURE DeleteSubject(
    IN p_id_subject INT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM Exam WHERE id_subject = p_id_subject
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Не можна видалити предмет, до якого прив\'язані екзамени.';
    ELSE
        DELETE FROM Subject WHERE id_subject = p_id_subject;
    END IF;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS RegisterStudentForExam;

DELIMITER //
CREATE PROCEDURE RegisterStudentForExam(
    IN p_id_student INT,
    IN p_id_exam INT
)
BEGIN
    DECLARE short_uuid VARCHAR(13);
    SET short_uuid = CONCAT('RD', SUBSTRING(UUID(), 1, 10));

    INSERT INTO Registration_docs (number, date_of_registration, status, id_student, id_exam)
    VALUES (short_uuid, NOW(), 'Дійсний', p_id_student, p_id_exam);
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS SubmitAppeal;
DELIMITER //
CREATE PROCEDURE SubmitAppeal(
    IN p_id_grade INT
)
BEGIN
    INSERT INTO Appeal (date_of_filing, status, id_grade)
    VALUES (NOW(), 'Подана', p_id_grade);
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE CalculateAverageExamScore(
    IN p_id_exam INT,
    OUT p_avg_score DECIMAL(10,2)
)
BEGIN
    SELECT AVG(Grade.numerical_value) INTO p_avg_score
    FROM Grade
    JOIN Registration_docs ON Grade.registration_docs_number = Registration_docs.number
    WHERE Registration_docs.id_exam = p_id_exam;
END;
//
DELIMITER ;


DROP FUNCTION IF EXISTS IsStudentPassing;
DELIMITER //
CREATE FUNCTION IsStudentPassing(p_id_student INT, p_id_exam INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE passing_score DECIMAL(10,2);
    DECLARE student_score DECIMAL(10,2);

    SELECT Exam.passing_score INTO passing_score
    FROM Exam
    WHERE id_exam = p_id_exam
    LIMIT 1;

    SELECT Grade.numerical_value INTO student_score
    FROM Grade
    JOIN Registration_docs ON Grade.registration_docs_number = Registration_docs.number
    WHERE Registration_docs.id_student = p_id_student AND Registration_docs.id_exam = p_id_exam
    LIMIT 1;

    RETURN (student_score >= passing_score);
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS GetFailedStudents;
DELIMITER //
CREATE PROCEDURE GetFailedStudents(
    IN p_id_exam INT
)
BEGIN
    SELECT s.id_student, s.last_name, s.first_name, g.numerical_value, e.passing_score
    FROM Student s
    JOIN Registration_docs R ON s.id_student = R.id_student
    JOIN Grade g ON R.number = g.registration_docs_number
    JOIN Exam e ON R.id_exam = e.id_exam
    WHERE e.id_exam = p_id_exam AND g.numerical_value < e.passing_score;
END;
//
DELIMITER ;


DROP FUNCTION IF EXISTS GetAppealStatus;
DELIMITER //
CREATE FUNCTION GetAppealStatus(p_appeal_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE status VARCHAR(20);
    SELECT Appeal.status INTO status
    FROM Appeal
    WHERE appeal_id = p_appeal_id;
    RETURN status;
END;
//
DELIMITER ;


DELIMITER //
CREATE FUNCTION GetCertificateCountByYear(p_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cert_count INT;
    SELECT COUNT(*) INTO cert_count
    FROM Certificate
    WHERE year_of_certificate = p_year;
    RETURN cert_count;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE UpdateAllStudentsAverageScores()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_id INT;

    DECLARE cur CURSOR FOR SELECT id_student FROM Student;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO student_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL GetAndUpdateStudentAverageScore(student_id);
    END LOOP;

    CLOSE cur;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE GetAndUpdateStudentAverageScore(IN student_id INT)
BEGIN
    DECLARE avg_score DECIMAL(10,2);

    SELECT AVG(numerical_value) INTO avg_score
    FROM Grade g
    INNER JOIN Registration_docs rd ON g.registration_docs_number = rd.number
    WHERE rd.id_student = student_id
      AND YEAR(rd.date_of_registration) = YEAR(CURRENT_DATE());

    UPDATE Student
    SET comp_score = avg_score
    WHERE id_student = student_id;
END;
//
DELIMITER ;


DROP PROCEDURE IF EXISTS ValidatePhoneNumber;
DELIMITER //
CREATE PROCEDURE ValidatePhoneNumber(IN phone_number VARCHAR(15))
BEGIN
    IF phone_number NOT LIKE '+380%' OR LENGTH(phone_number) != 13 THEN
        SIGNAL SQLSTATE '20000'
        SET MESSAGE_TEXT = 'Номер телефону має некоректний формат (має починатися з +380 і містити 13 символів).';
    END IF;
END;
//
DELIMITER //

CREATE PROCEDURE UpdateCertificateStatus(IN cert_number VARCHAR(16), IN issuance_date DATE)
BEGIN
    IF TIMESTAMPDIFF(YEAR, issuance_date, CURRENT_DATE()) > 3 THEN
        UPDATE Certificate
        SET status = 'Недійсний'
        WHERE number_of_certificate = cert_number;
    END IF;
END;
//
DELIMITER //
USE exam_db;

DELIMITER //
CREATE PROCEDURE UpdateExamStatus(IN exam_id INT, IN exam_date DATETIME)
BEGIN
    IF exam_date < NOW() THEN
        UPDATE Exam
        SET status = 'Архівний'
        WHERE id_exam = exam_id;
    ELSE
        UPDATE Exam
        SET status = 'Заплановано'
        WHERE id_exam = exam_id;
    END IF;
END;
//
DELIMITER //

DELIMITER //
CREATE PROCEDURE UpdateRegistrationDocsStatus(IN doc_number VARCHAR(16), IN reg_date DATETIME)
BEGIN
    IF reg_date < DATE_SUB(NOW(), INTERVAL 1 YEAR) THEN
        UPDATE Registration_docs SET status = 'Архівний' WHERE number = doc_number;
    ELSE
        UPDATE Registration_docs SET status = 'Дійсний' WHERE number = doc_number;
    END IF;
END;
//
DELIMITER //


DELIMITER //
CREATE PROCEDURE ValidateAppealStatus(IN old_status VARCHAR(20), IN new_status VARCHAR(20))
BEGIN
    IF old_status = 'Підтверджена' OR 'Відхилена' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Статус апеляції вже не можна змінювати.';
    END IF;

    IF new_status NOT IN ('Подана', 'Розглядається', 'Підтверджена', 'Відхилена') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Некоректний статус апеляції.';
    END IF;
END;
//
DELIMITER //
