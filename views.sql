USE exam_db;

DROP VIEW IF EXISTS StudentsAverageScores;
CREATE VIEW StudentsAverageScores AS
SELECT
    s.id_student,
    s.first_name,
    s.last_name,
    s.middle_name,
    s.comp_score AS average_score,
    c.year_of_certificate AS year
FROM Student s
JOIN Certificate c ON s.id_student = c.id_student
WHERE c.status = 'Дійсний' AND s.comp_score IS NOT NULL ;

DROP VIEW IF EXISTS TopStudentsBySubject;
CREATE VIEW TopStudentsBySubject AS
SELECT
    g.numerical_value AS highest_score,
    sub.name_of_subject AS subject,
    s.last_name,
    s.first_name,
    YEAR(rd.date_of_registration) AS year
FROM Grade g
JOIN Registration_docs rd ON g.registration_docs_number = rd.number
JOIN Student s ON rd.id_student = s.id_student
JOIN Exam e ON rd.id_exam = e.id_exam
JOIN Subject sub ON e.id_subject = sub.id_subject
WHERE
    g.numerical_value = (
        SELECT MAX(g2.numerical_value)
        FROM Grade g2
        JOIN Registration_docs rd2 ON g2.registration_docs_number = rd2.number
        JOIN Exam e2 ON rd2.id_exam = e2.id_exam
        JOIN Subject sub2 ON e2.id_subject = sub2.id_subject
        WHERE sub2.id_subject = sub.id_subject
          AND YEAR(rd2.date_of_registration) = YEAR(rd.date_of_registration)
    )
ORDER BY sub.name_of_subject, highest_score DESC;

DROP VIEW IF EXISTS ExpiringCertificates;
CREATE VIEW ExpiringCertificates AS
SELECT
    c.number_of_certificate,
    c.certificate_issuance_date,
    c.status,
    s.last_name AS student,
    (YEAR(CURRENT_DATE()) - c.year_of_certificate) AS years_since_issuance
FROM Certificate c
JOIN Student s ON c.id_student = s.id_student
WHERE TIMESTAMPDIFF(YEAR, c.certificate_issuance_date, CURRENT_DATE()) >= 2
        AND c.status = 'Дійсний';

DROP VIEW IF EXISTS ExamAttendanceStatistics;
CREATE VIEW ExamAttendanceStatistics AS
SELECT
    e.id_exam,
    sub.name_of_subject AS subject_name,
    e.date_of_holding AS exam_date,
    COUNT(DISTINCT rd.id_student) AS total_participants,
    SUM(CASE WHEN g.numerical_value >= e.passing_score THEN 1 ELSE 0 END) AS successful_participants,
    ROUND((SUM(CASE WHEN g.numerical_value >= e.passing_score THEN 1 ELSE 0 END) / COUNT(DISTINCT rd.id_student)) * 100, 2) AS success_rate
FROM Exam e
LEFT JOIN Registration_docs rd ON e.id_exam = rd.id_exam
LEFT JOIN Grade g ON rd.number = g.registration_docs_number
LEFT JOIN Subject sub ON e.id_subject = sub.id_subject
GROUP BY e.id_exam, sub.name_of_subject, e.date_of_holding;