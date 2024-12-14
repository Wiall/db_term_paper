USE exam_db;
-- -----------------------------DROP USERS---------------------------------
DROP ROLE IF EXISTS 'DB_admin'@'localhost', 'Exam_manager'@'localhost', 'Testing_Center_Operator'@'localhost',
                    'Appeal_Moderator'@'localhost', 'Student'@'localhost', 'Guest'@'localhost', 'School_Director'@'localhost';
DROP USER IF EXISTS 'db_admin_user@localhost' , 'exam_manager_user@localhost', 'testcent_operator_user@localhost',
                    'appeal_moderator_user@localhost', 'student_user@localhost', 'guest_user@localhost',
                    'school_director_user@localhost';

-- ----------------------CREATING & GRANTING ROLES-------------------------
CREATE ROLE IF NOT EXISTS 'DB_admin'@'localhost', 'Exam_manager'@'localhost', 'Testing_Center_Operator'@'localhost',
    'Appeal_Moderator'@'localhost', 'Student'@'localhost', 'Guest'@'localhost', 'School_Director'@'localhost';

GRANT ALL PRIVILEGES ON exam_db.* TO 'DB_admin'@'localhost';

GRANT SELECT, INSERT, UPDATE, DELETE ON exam_db.Grade TO 'Exam_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON exam_db.Exam TO 'Exam_manager'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON exam_db.Subject TO 'Exam_manager'@'localhost';

GRANT SELECT, UPDATE ON exam_db.Testing_center TO 'Testing_Center_Operator'@'localhost';
GRANT SELECT, UPDATE ON exam_db.Exam_Testing_center TO 'Testing_Center_Operator'@'localhost';

GRANT SELECT, UPDATE ON exam_db.Appeal TO 'Appeal_Moderator'@'localhost';
GRANT SELECT, UPDATE ON exam_db.Grade TO 'Appeal_Moderator'@'localhost';

GRANT SELECT ON exam_db.Student TO 'Student'@'localhost';
GRANT SELECT ON exam_db.Grade TO 'Student'@'localhost';
GRANT SELECT ON exam_db.Appeal TO 'Student'@'localhost';
GRANT SELECT ON exam_db.Certificate TO 'Student'@'localhost';

GRANT SELECT ON exam_db.Exam TO 'Guest'@'localhost';
GRANT SELECT ON exam_db.Subject TO 'Guest'@'localhost';

GRANT SELECT ON exam_db.School TO 'School_Director'@'localhost';
GRANT SELECT ON exam_db.Student TO 'School_Director'@'localhost';
GRANT SELECT ON exam_db.Grade TO 'School_Director'@'localhost';

-- ----------------------CREATING & GRANTING USERS-------------------------
CREATE USER 'db_admin_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'DB_admin'@'localhost' TO 'db_admin_user'@'localhost';

CREATE USER 'exam_manager_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'Exam_manager'@'localhost' TO 'exam_manager_user'@'localhost';

CREATE USER 'testcent_operator_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'Testing_Center_Operator'@'localhost' TO 'testcent_operator_user'@'localhost';

CREATE USER 'appeal_moderator_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'Appeal_Moderator'@'localhost' TO 'appeal_moderator_user'@'localhost';

CREATE USER 'student_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'Student'@'localhost' TO 'student_user'@'localhost';

CREATE USER 'guest_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'Guest'@'localhost' TO 'guest_user'@'localhost';

CREATE USER 'school_director_user'@'localhost' IDENTIFIED BY 'password';
GRANT 'School_Director'@'localhost' TO 'school_director_user'@'localhost';

-- ---------------------------SHOWING GRANTS-------------------------------
SHOW GRANTS FOR 'DB_admin'@'localhost';
SHOW GRANTS FOR 'Exam_manager'@'localhost';
SHOW GRANTS FOR 'Testing_Center_Operator'@'localhost';
SHOW GRANTS FOR 'Appeal_Moderator'@'localhost';
SHOW GRANTS FOR 'Student'@'localhost';
SHOW GRANTS FOR 'Guest'@'localhost';
SHOW GRANTS FOR 'School_Director'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'db_admin_user'@'localhost';
SHOW GRANTS FOR 'exam_manager_user'@'localhost';
SHOW GRANTS FOR 'testcent_operator_user'@'localhost';
SHOW GRANTS FOR 'appeal_moderator_user'@'localhost';
SHOW GRANTS FOR 'student_user'@'localhost';
SHOW GRANTS FOR 'guest_user'@'localhost';
SHOW GRANTS FOR 'school_director_user'@'localhost';

-- ---------------------------SWITCH ON ROLES-------------------------------
SET DEFAULT ROLE 'DB_admin'@'localhost' TO 'db_admin_user'@'localhost';
SET DEFAULT ROLE 'Exam_manager'@'localhost' TO 'exam_manager_user'@'localhost';
SET DEFAULT ROLE 'Testing_Center_Operator'@'localhost' TO 'testcent_operator_user'@'localhost';
SET DEFAULT ROLE 'Appeal_Moderator'@'localhost' TO 'appeal_moderator_user'@'localhost';
SET DEFAULT ROLE 'Student'@'localhost' TO 'student_user'@'localhost';
SET DEFAULT ROLE 'Guest'@'localhost' TO 'guest_user'@'localhost';
SET DEFAULT ROLE 'School_Director'@'localhost' TO 'school_director_user'@'localhost';

SELECT CURRENT_ROLE();

SELECT User, Host FROM mysql.user;