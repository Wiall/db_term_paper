USE exam_db;

SELECT s.first_name, s.last_name, g.numerical_value AS math_score
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
WHERE sub.name_of_subject = 'Математика' AND g.numerical_value > 180;


SELECT number_of_certificate, last_name AS student, status, certificate_issuance_date
FROM Certificate
JOIN Student st ON Certificate.id_student = st.id_student
WHERE certificate_issuance_date < '2022-01-01';


SELECT tc.name_of_test_center, sub.name_of_subject, e.date_of_holding
FROM Exam e
JOIN Subject sub ON e.id_subject = sub.id_subject
JOIN Exam_Testing_center etc ON e.id_exam = etc.id_exam
JOIN Testing_center tc ON etc.id_testing_center = tc.id_testing_center
WHERE tc.region = 'Київська';


SELECT s.first_name, s.last_name, g.numerical_value AS ukrainian_score
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
WHERE sub.name_of_subject = 'Українська мова' AND g.numerical_value BETWEEN 150 AND 200;


SELECT s.first_name, s.last_name,
       GROUP_CONCAT(DISTINCT sub.name_of_subject ORDER BY sub.name_of_subject ASC SEPARATOR ', ') AS subjects_taken
FROM Student s
LEFT JOIN Registration_docs rd ON s.id_student = rd.id_student
LEFT JOIN Exam e ON rd.id_exam = e.id_exam
LEFT JOIN Subject sub ON e.id_subject = sub.id_subject
GROUP BY s.id_student, s.first_name, s.last_name
HAVING COUNT(sub.name_of_subject) > 0 AND s.id_student NOT IN (
    SELECT DISTINCT rd.id_student
    FROM Registration_docs rd
    JOIN Exam e ON rd.id_exam = e.id_exam
    JOIN Subject sub ON e.id_subject = sub.id_subject
    WHERE sub.name_of_subject = 'Фізика'
);


SELECT s.first_name, s.last_name, g.numerical_value AS original_score,
       LEAST((g.numerical_value * 1.10), 200) AS adjusted_score
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
WHERE sub.name_of_subject = 'Хімія';


SELECT s.id_student, s.last_name, s.first_name, e.id_exam, e.date_of_holding, g.numerical_value AS grade, e.passing_score
FROM Student s
JOIN Registration_docs rd ON s.id_student = rd.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Grade g ON rd.number = g.registration_docs_number
WHERE g.numerical_value >= e.passing_score;


SELECT tc.name_of_test_center, tc.region, COUNT(e.id_exam) AS exam_count
FROM Testing_center tc
JOIN Exam_Testing_Center etc ON tc.id_testing_center = etc.id_testing_center
JOIN Exam e ON etc.id_exam = e.id_exam
GROUP BY tc.id_testing_center
HAVING COUNT(e.id_exam) = (
    SELECT MAX(center_exam_count)
    FROM (
        SELECT COUNT(e2.id_exam) AS center_exam_count
        FROM Exam e2
        JOIN exam_testing_center etc2 ON e2.id_exam = etc2.id_exam
        GROUP BY etc2.id_testing_center
    ) AS subquery
);


SELECT s.first_name, s.last_name, sub.name_of_subject, g.numerical_value
FROM Student s
JOIN Registration_docs rd ON s.id_student = rd.id_student
JOIN Grade g ON rd.number = g.registration_docs_number
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject;


SELECT tc.name_of_test_center, COUNT(rd.id_student) AS student_count
FROM Testing_center tc
JOIN Exam_Testing_center etc ON tc.id_testing_center = etc.id_testing_center
JOIN Exam e ON etc.id_exam = e.id_exam
JOIN Registration_docs rd ON e.id_exam = rd.id_exam
GROUP BY tc.id_testing_center;


SELECT s.first_name, s.last_name, g.numerical_value,
       ROW_NUMBER() OVER (ORDER BY g.numerical_value DESC) AS 'rank'
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
WHERE sub.name_of_subject = 'Математика';


SELECT tc.name_of_test_center,
       GROUP_CONCAT(DISTINCT sub.name_of_subject ORDER BY sub.name_of_subject ASC SEPARATOR ', ') AS subjects
FROM Testing_center tc
JOIN Exam_Testing_center etc ON tc.id_testing_center = etc.id_testing_center
JOIN Exam e ON etc.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
GROUP BY tc.id_testing_center;


SELECT s.first_name, s.last_name, sub.name_of_subject, g.numerical_value
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
ORDER BY sub.name_of_subject ASC, g.numerical_value DESC;


SELECT s.first_name, s.last_name, sub.name_of_subject
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
WHERE sub.name_of_subject IN ('Фізика', 'Математика');


SELECT s.first_name, s.last_name
FROM Student s
WHERE EXISTS (
    SELECT 1
    FROM Registration_docs rd
    JOIN Grade g ON rd.number = g.registration_docs_number
    WHERE rd.id_student = s.id_student AND g.numerical_value > 190
);


SELECT
    s.first_name,
    s.last_name,
    c.status AS certificate_status,
    c.year_of_certificate
FROM Certificate c
JOIN Student s ON c.id_student = s.id_student
WHERE c.year_of_certificate = (SELECT YEAR(CURRENT_DATE()) - 2);


SELECT
    s.first_name,
    s.last_name,
    a.date_of_filing,
    a.status AS appeal_status
FROM Appeal a
JOIN Grade g ON a.id_grade = g.id_grade
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
WHERE a.date_of_filing >= (SELECT DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY));


SELECT
    c.year_of_certificate,
    c.status,
    COUNT(*) AS certificate_count
FROM Certificate c
GROUP BY c.year_of_certificate, c.status
ORDER BY c.year_of_certificate DESC, certificate_count DESC;


SELECT
    s.first_name,
    s.last_name,
    c.number_of_certificate,
    c.status AS certificate_status
FROM Student s
JOIN Certificate c ON s.id_student = c.id_student
WHERE EXISTS (
    SELECT 1
    FROM Appeal a
    JOIN Grade g ON a.id_grade = g.id_grade
    JOIN Registration_docs rd ON g.registration_docs_number = rd.number
    WHERE rd.id_student = s.id_student
);


SELECT
    s.first_name,
    s.last_name,
    g.numerical_value AS grade_score,
    a.date_of_filing AS appeal_date,
    a.status AS appeal_status
FROM Appeal a
JOIN Grade g ON a.id_grade = g.id_grade
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
ORDER BY g.numerical_value DESC
LIMIT 10;


SELECT sc.name_school, sc.region,
    ROUND(AVG(g.numerical_value), 2) AS average_score,
    COUNT(s.id_student) AS total_students
FROM School sc
JOIN Student s ON sc.id_school = s.school_id
JOIN Registration_docs rd ON s.id_student = rd.id_student
JOIN Grade g ON rd.number = g.registration_docs_number
GROUP BY sc.id_school
ORDER BY average_score DESC;


SELECT
    subj.name_of_subject AS subject_name,
    COUNT(DISTINCT rd.id_student) AS student_count
FROM Subject subj
JOIN Exam ex ON subj.id_subject = ex.id_subject
JOIN Registration_docs rd ON ex.id_exam = rd.id_exam
GROUP BY subj.id_subject
ORDER BY student_count DESC;

