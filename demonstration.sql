USE exam_db;

-- Процедура AddSchool()
-- Перший виклик спрацює коректно
CALL AddSchool('Школа №100', 'Ліцей', 'Харківська', 'Індустріальний',
               'Полтавський шлях', '30a', '+380662034567', 'school100@example.com');
-- Другий виклик поверне помилку унікальності контактного номера
CALL AddSchool('Школа №101', 'Ліцей', 'Київська', 'Дарницький',
               'Шевченка', '89', '+380662034567', 'school101@example.com');

-- Процедура UpdateStudentPhone()
-- Новий номер телефона унікальний
CALL UpdateStudentPhone(1, '+380635663811');
-- Новий номер телефона вже не унікальний
CALL UpdateStudentPhone(1, '+380635663811');

-- Функція GetStudentCount()
-- Поверне кількість учнів у школі які складають зно
SELECT GetStudentCount(1);
-- Поверне нуль якщо немає зареєстрованих студентів з цієї школи
SELECT GetStudentCount(55);

-- Процедура DeleteSubject
-- Додавання предмета
INSERT INTO Subject (name_of_subject, type_of_subject) VALUES
('Правознавство', 'Гуманітарний');
CALL DeleteSubject(10);
CALL DeleteSubject(1);

-- Процедура RegisterStudentForExam()
CALL RegisterStudentForExam(2, 4);

-- Процедура SubmitAppeal
CALL SubmitAppeal(1);

-- Процедура CalculateAverageExamScore
CALL CalculateAverageExamScore(1, @avg_score);
SELECT ROUND(@avg_score, 2) AS AverageScore;

-- Функція IsStudentPassing
SELECT IsStudentPassing(43, 26);

SELECT IsStudentPassing(3, 26);

-- Процедура GetFailedStudents
CALL GetFailedStudents(3);


-- Функція GetAppealStatus
SELECT GetAppealStatus(2);

-- Функція IsTestingCenterAvailable

SELECT GetCertificateCountByYear(2023);

-- Процедура UpdateAllStudentsAverageScores
CALL UpdateAllStudentsAverageScores();

-- -------------------------- TRIGGERS -------------------
INSERT INTO grade(numerical_value, evaluation_date, registration_docs_number) VALUES
                        (190, '2024-08-05 16:26:38', 'RD000000000008');
UPDATE Grade
SET numerical_value = 180
WHERE registration_docs_number = 'RD000000000008';

INSERT INTO registration_docs(number, date_of_registration, status, id_student, id_exam) VALUES
    ('RD000023000008', '2024-08-05 16:26:38', 'Дійсна', 3, 26);

INSERT INTO registration_docs(number, date_of_registration, status, id_student, id_exam) VALUES
    ('RD000027000008', '2023-12-01 16:26:38', 'Дійсна', 3, 38);

INSERT INTO grade(numerical_value, evaluation_date, registration_docs_number) VALUES
                        (190, '2023-12-15 16:26:38', 'RD000027000008');



