USE exam_db;

-- Перший запис — успішний
INSERT INTO School (id_school, name_school, type_of_edu_inst, region, district, street, build_num, contact_number) VALUES
(1, 'School #1', 'High School', 'Region 1', 'District 1', 'Main Street', '1', '1234567890');

INSERT INTO Student (id_student, last_name, first_name, middle_name, phone_number, email, region, district, school_id, comp_score) VALUES
(1, 'Ivanov', 'Ivan', 'Ivanovich', '0987654321', 'ivan.ivanov@example.com', 'Region 1', 'District 1', 1, 95.5);

INSERT INTO Subject (id_subject, name_of_subject, type_of_subject) VALUES
(1, 'Mathematics', 'Science');

INSERT INTO Exam (id_exam, date_of_holding, form_of_conduct, difficulty_level, session, max_score, passing_score, duration, time_of_starting, id_subject) VALUES
(1, '2024-12-10 10:00:00', 'Written', 'Intermediate', 'Winter', 200, 125, '04:00:00', '2024-12-10 10:00:00', 1);

INSERT INTO Registration_docs (number, date_of_registration, status, id_student, id_exam) VALUES
('REG001', '2024-12-01 09:00:00', 'Registered', 1, 1);

INSERT INTO Grade (numerical_value, evaluation_date, registration_docs_number) VALUES
(95, '2024-12-10 18:00:00', 'REG001');

INSERT INTO Grade (numerical_value, evaluation_date, registration_docs_number) VALUES
(98, '2024-12-10 18:00:00', 'REG001');

-- Спроба вставити другий запис для того ж студента та іспиту
-- ВИКЛИКАТИМЕ ПОМИЛКУ через порушення унікальності


-- --------Тест цілісності
-- Вставлення школи
INSERT INTO School (id_school, name_school, type_of_edu_inst, region, district, street, build_num, contact_number, email)
VALUES
(1, 'High School #1', 'Secondary', 'Kyiv', 'Solomianskyi', 'Velyka Vasylkivska', '10', '+380441234567', 'school1@example.com'),
(2, 'Gymnasium #2', 'Gymnasium', 'Lviv', 'Halytskyi', 'Shevchenko', '15', '+380322345678', 'school2@example.com');

-- Вставлення студентів
INSERT INTO Student (id_student, last_name, first_name, middle_name, phone_number, email, region, district, school_id, comp_score)
VALUES
(1, 'Ivanov', 'Ivan', 'Petrovych', '+380991112233', 'ivanov@example.com', 'Kyiv', 'Solomianskyi', 1, 175.5),
(2, 'Petrenko', 'Petro', 'Ivanovych', '+380992223344', 'petrenko@example.com', 'Lviv', 'Halytskyi', 2, 189.0);

-- Вставлення документів студента
INSERT INTO Student_docs (number, type_of_document, document_issuance_date, issued_by, student)
VALUES
('DOC001', 'Passport', '2020-01-15', 'Ministry of Internal Affairs', 1),
('DOC002', 'Passport', '2021-05-10', 'Ministry of Internal Affairs', 2);

-- Вставлення предметів
INSERT INTO Subject (id_subject, name_of_subject, type_of_subject)
VALUES
(1, 'Mathematics', 'Mandatory'),
(2, 'Physics', 'Optional');

-- Вставлення екзаменів
INSERT INTO Exam (id_exam, date_of_holding, form_of_conduct, difficulty_level, session, max_score, passing_score, duration, time_of_starting, id_subject)
VALUES
(1, '2024-06-01', 'Written', 'Medium', 'Session 1', 200, 125, '04:00:00', '2024-06-01 09:00:00', 1),
(2, '2024-06-02', 'Written', 'Hard', 'Session 2', 200, 125, '04:00:00', '2024-06-02 10:00:00', 2);

-- Вставлення тестових центрів
INSERT INTO Testing_center (id_testing_center, name_of_test_center, contact_number, region, district, street, build_num, capacity)
VALUES
(1, 'Test Center #1', '+380501112233', 'Kyiv', 'Solomianskyi', 'Akademika Glushkova', '30', 500),
(2, 'Test Center #2', '+380502223344', 'Lviv', 'Halytskyi', 'Doroshenka', '20', 300);

-- Вставлення зв’язків між екзаменами та тестовими центрами
INSERT INTO Exam_Testing_center (audience_number, id_exam, id_testing_center)
VALUES
('101', 1, 1),
('102', 2, 2);

-- Вставлення реєстраційних документів
INSERT INTO Registration_docs (number, date_of_registration, status, id_student, id_exam)
VALUES
('REG001', '2024-05-01', 'Approved', 1, 1),
('REG002', '2024-05-02', 'Approved', 2, 2);

-- Вставлення оцінок
INSERT INTO Grade (numerical_value, evaluation_date, registration_docs_number)
VALUES
(180, '2024-06-01', 'REG001'),
(195, '2024-06-02', 'REG002');

-- Вставлення апеляцій
INSERT INTO Appeal (date_of_filing, status, id_grade)
VALUES
('2024-06-03', 'Pending', 1),
('2024-06-04', 'Resolved', 2);

-- Вставлення сертифікатів
INSERT INTO Certificate (number_of_certificate, certificate_issuance_date, year_of_certificate, status, id_student)
VALUES
('CERT001', '2024-06-15', 2024, 'Valid', 1),
('CERT002', '2024-06-16', 2024, 'Valid', 2);


-- Перевірка цілісності
-- Некоректний запит
INSERT INTO Student (id_student, last_name, first_name, middle_name, phone_number, email, region, district, school_id, comp_score)
VALUES
(3, 'Shevchenko', 'Taras', 'Hryhorovych', '+380993334455', 'shevchenko@example.com', 'Kyiv', 'Pecherskyi', 3, 190.0);
