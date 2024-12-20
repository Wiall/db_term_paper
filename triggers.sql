USE exam_db;

DELIMITER //
CREATE TRIGGER after_grade_insert
AFTER INSERT ON Grade
FOR EACH ROW
BEGIN
    DECLARE student_id INT;

    SELECT id_student INTO student_id
    FROM Registration_docs
    WHERE number = NEW.registration_docs_number;

    CALL GetAndUpdateStudentAverageScore(student_id);
END;
//
DELIMITER //

DELIMITER //
CREATE TRIGGER after_grade_update
AFTER UPDATE ON Grade
FOR EACH ROW
BEGIN
    DECLARE student_id INT;

    SELECT id_student INTO student_id
    FROM Registration_docs
    WHERE number = NEW.registration_docs_number;

    CALL GetAndUpdateStudentAverageScore(student_id);
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER before_insert_student
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    CALL ValidatePhoneNumber(NEW.phone_number);
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_update_student
BEFORE UPDATE ON Student
FOR EACH ROW
BEGIN
    CALL ValidatePhoneNumber(NEW.phone_number);
END;
//
DELIMITER //


DROP TRIGGER IF EXISTS before_insert_registration_docs;
DELIMITER //
CREATE TRIGGER before_insert_registration_docs
BEFORE INSERT ON Registration_docs
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Registration_docs
        WHERE id_exam = NEW.id_exam AND id_student = NEW.id_student
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Комбінація іспиту та учня вже існує.';
    END IF;
END//
DELIMITER ;


DELIMITER //
CREATE TRIGGER prevent_duplicate_subject_registration
BEFORE INSERT ON Registration_docs
FOR EACH ROW
BEGIN
    DECLARE subject_id INT;

    SELECT id_subject INTO subject_id
    FROM Exam
    WHERE id_exam = NEW.id_exam;

    IF EXISTS (
        SELECT 1
        FROM Registration_docs rd
        JOIN Exam e ON rd.id_exam = e.id_exam
        WHERE rd.id_student = NEW.id_student
          AND e.id_subject = subject_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Учень вже зареєстрований на екзамен із цього предмета.';
    END IF;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER check_registration_date
BEFORE INSERT ON Registration_docs
FOR EACH ROW
BEGIN
    DECLARE exam_date DATE;

    SELECT date_of_holding INTO exam_date
    FROM Exam
    WHERE id_exam = NEW.id_exam;

    IF NEW.date_of_registration < DATE_ADD(exam_date, INTERVAL -6 MONTH) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Дата реєстрації повинна бути не більше, ніж за 6 місяців до дати проведення екзамену.';
    END IF;
END//

DELIMITER ;


DELIMITER //
CREATE TRIGGER check_evaluation_date
BEFORE INSERT ON Grade
FOR EACH ROW
BEGIN
    DECLARE registration_date DATETIME;
    DECLARE exam_date DATETIME;

    SELECT date_of_registration INTO registration_date
    FROM Registration_docs
    WHERE number = NEW.registration_docs_number;

    SELECT date_of_holding INTO exam_date
    FROM Exam
    WHERE id_exam = (SELECT id_exam FROM Registration_docs WHERE number = NEW.registration_docs_number);

    IF NEW.evaluation_date < registration_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Дата отримання оцінки не може бути раніше дати реєстрації.';
    END IF;

    IF NEW.evaluation_date < exam_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Дата отримання оцінки не може бути раніше дати проведення екзамену.';
    END IF;
END//

DELIMITER ;

CREATE EVENT update_exam_status_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DECLARE exam_id INT;
    DECLARE exam_date DATETIME;

    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR SELECT id_exam, date_of_holding FROM Exam;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO exam_id, exam_date;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL UpdateExamStatus(exam_id, exam_date);
    END LOOP;

    CLOSE cur;
END;


CREATE EVENT update_registration_docs_status_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DECLARE doc_number VARCHAR(16);
    DECLARE reg_date DATETIME;

    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR SELECT number, date_of_registration FROM Registration_docs;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO doc_number, reg_date;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL UpdateRegistrationDocsStatus(doc_number, reg_date);
    END LOOP;

    CLOSE cur;
END;


CREATE EVENT validate_appeal_status_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DECLARE appeal_id INT;
    DECLARE old_status VARCHAR(20);
    DECLARE new_status VARCHAR(20);

    DECLARE done INT DEFAULT FALSE;
    DECLARE cur CURSOR FOR SELECT appeal_id, status FROM Appeal;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO appeal_id, old_status;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL ValidateAppealStatus(old_status, new_status);
    END LOOP;

    CLOSE cur;
END;

CREATE EVENT update_certificate_status_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE Certificate
    SET year_of_certificate = YEAR(certificate_issuance_date),
        status = CASE
                    WHEN DATEDIFF(NOW(), certificate_issuance_date) > 365 * 3 THEN 'Неактивний'
                    ELSE status
                 END;
END;
