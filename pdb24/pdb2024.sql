CREATE TABLE user (
    username VARCHAR(30) PRIMARY KEY UNIQUE NOT NULL,
    password VARCHAR(20) NOT NULL,
    name VARCHAR(25) NOT NULL,
    lastname VARCHAR(35) NOT NULL,
    reg_date DATETIME NOT NULL,
    email VARCHAR(30) NOT NULL,
    role ENUM('admin','user','evaluator') DEFAULT 'user'
);


CREATE TABLE etaireia (
    AFM CHAR(9) PRIMARY KEY NOT NULL,
    DOY VARCHAR(30) NOT NULL,
    name VARCHAR(35) NOT NULL,
    tel VARCHAR(10) NOT NULL,
    street VARCHAR(15) NOT NULL,
    num INT(11) NOT NULL,
    city VARCHAR(45) NOT NULL,
    country VARCHAR(15) NOT NULL
);

CREATE TABLE evaluator (
    username VARCHAR(30),
    exp_years TINYINT(4) NOT NULL,
    firm CHAR(9),
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES user(username),
    FOREIGN KEY (firm) REFERENCES etaireia(AFM)
);

CREATE TABLE employee (
    username VARCHAR(30) UNIQUE NOT NULL,
    bio TEXT,
    sistatikes VARCHAR(35),
    certificates VARCHAR(35),
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES user(username)
);

CREATE TABLE languages (
    candid VARCHAR(30),
    lang SET('EN','FR','SP','GE','CH','GR'),
    PRIMARY KEY (candid, lang),
    FOREIGN KEY (candid) REFERENCES employee(username)
);

CREATE TABLE project (
    candid VARCHAR(30),
    num TINYINT(4) NOT NULL,
    descr TEXT NOT NULL,
    url VARCHAR(60) NOT NULL,
    PRIMARY KEY (candid, num),
    FOREIGN KEY (candid) REFERENCES employee(username)
);


CREATE TABLE job (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    start_date DATE NOT NULL,
    salary FLOAT,
    position VARCHAR(60) NOT NULL,
    edra VARCHAR(60) NOT NULL,
    evaluator VARCHAR(30),
    announce_date DATETIME NOT NULL,
    submission_date DATE NOT NULL,
    FOREIGN KEY (evaluator) REFERENCES evaluator(username)
);


 CREATE TABLE `applies` (
  `cand_usrname` varchar(30) NOT NULL,
  `job_id` int(11) NOT NULL,
  `status` enum('active','completed','cancelled') NOT NULL DEFAULT 'active',
  `application_date` date NOT NULL DEFAULT curdate(),
  PRIMARY KEY (`cand_usrname`,`job_id`),
  KEY `job_id` (`job_id`),
  CONSTRAINT `applies_ibfk_1` FOREIGN KEY (`cand_usrname`) REFERENCES `employee` (`username`),
  CONSTRAINT `applies_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `job` (`id`)
);


CREATE TABLE subject (
    title VARCHAR(36) PRIMARY KEY,
    descr TEXT,
    belongs_to VARCHAR(36),
    FOREIGN KEY (belongs_to) REFERENCES subject(title)
);


CREATE TABLE requires (
    job_id INT(11),
    subject_title VARCHAR(36),
    PRIMARY KEY (job_id, subject_title), 
    FOREIGN KEY (job_id) REFERENCES job(id),
    FOREIGN KEY (subject_title) REFERENCES subject(title)
);

CREATE TABLE degree (
    titlos VARCHAR(150) NOT NULL,
    idryma VARCHAR(150) NOT NULL,
    bathmida ENUM('BSc', 'MSc', 'PhD') NOT NULL,
    PRIMARY KEY (titlos, idryma)
);

CREATE TABLE has_degree (
    degr_title VARCHAR(150) NOT NULL,
    degr_idryma VARCHAR(150) NOT NULL,
    cand_usrname VARCHAR(30) NOT NULL,
    etos YEAR(4) NOT NULL,
    grade FLOAT NOT NULL,
    PRIMARY KEY (degr_title, degr_idryma, cand_usrname),
    FOREIGN KEY (degr_title, degr_idryma) REFERENCES degree(titlos, idryma),
    FOREIGN KEY (cand_usrname) REFERENCES employee(username)
);


CREATE TABLE evaluation (
    cand_usrname VARCHAR(30),
    job_id INT(11),
    evaluator1 VARCHAR(30),
    evaluator2 VARCHAR(30),
    score1 TINYINT(4),
    score2 TINYINT(4),
    PRIMARY KEY (cand_usrname, job_id),
    FOREIGN KEY (cand_usrname) REFERENCES employee(username),
    FOREIGN KEY (job_id) REFERENCES job(id)
);

CREATE TABLE application_history (
    cand_usrname VARCHAR(30),
    job_id INT(11),
    eval1 VARCHAR(30),
    eval2 VARCHAR(30),
    status ENUM('completed', 'cancelled') NOT NULL,
    grade TINYINT(4),
    PRIMARY KEY (cand_usrname, job_id)
);

CREATE TABLE `application_history2` (
  `cand_usrname` varchar(30) NOT NULL,
  `job_id` int(11) NOT NULL,
  `status` enum('active','completed','cancelled') NOT NULL DEFAULT 'active',
  `application_date` date NOT NULL DEFAULT curdate()
);


CREATE TABLE dba (
    dba_username VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    FOREIGN KEY (dba_username) REFERENCES user(username)
);


CREATE TABLE dba_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    dba_username VARCHAR(30) NOT NULL,
    action VARCHAR(255) NOT NULL,
    log_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dba_username) REFERENCES dba(dba_username)
);



ALTER TABLE evaluation
ADD CONSTRAINT chk_score1_range CHECK (score1 BETWEEN 1 AND 20),
ADD CONSTRAINT chk_score2_range CHECK (score2 BETWEEN 1 AND 20);




INSERT INTO user (username, password, name, lastname, reg_date, email) VALUES
('johnv', '$2y$10$BtfvAEPme', 'John', 'Vasileiou', '2024-01-8 08:30:00', 'john.v@gmail.com'),
('dimg', '$2y$10$BtfvAEPmeW', 'Dimitris', 'Giannias', '2024-01-6 02:30:00', 'dim.g@gmail.com'),
('Emily32', '$2y$10$BtfvAEP', 'Emily', 'Jones', '2024-01-03 10:15:00', 'emilyJones32@gmail.com'),
('Ol2', '$2y$10$BtfvAEPme', 'Olivia', 'Miller', '2024-01-07 14:35:00', 'olivia.mille22@gmail.com'),
('dannyW', '$2y$10$BtfvAEPm', 'Daniel', 'Wilson', '2024-01-08 15:40:00', 'daniel.wilson@proton.me'),
('sophiaM', '$2y$10$BtfvAEP', 'Sophia', 'Moore', '2024-01-09 16:45:00', 'sophia.moore@gmail.com'),
('mariak', '$2y$10$BtfvAEPm', 'Maria', 'Kontos', '2024-01-13 08:50:00', 'maria.kontos@gmail.com'),
('nickp', '$2ashedValueHere', 'Nick', 'Papadopoulos', '2024-01-14 09:15:00', 'nick.papadopoulos@gmail.com'),
('georgek', 'HashedPassword123', 'George', 'Kostas', '2024-01-15 10:25:00', 'george.kostas@gmail.com'),
('elenid', 'HashedPasswordHere', 'Eleni', 'Dimitriou', '2024-01-16 11:35:00', 'eleni.dimitriou@gmail.com'),
('alexz', '$$2y$10$BtfvAEPmeW', 'Alex', 'Zorbas', '2024-01-17 12:45:00', 'alex.zorbas@gmail.com'),
('chrisv', '$2y$10$BtfvAEPmeW', 'Chris', 'Vasilakis', '2024-01-18 13:55:00', 'chris.vasilakis@gmail.com');


INSERT INTO employee (username, bio, sistatikes, certificates) VALUES
('mariak', 'Experienced marketing specialist with a proven track record of successful campaigns and strategic planning.', 'mariak_rec.pdf', 'certificate_maria.pdf'),
('nickp', 'Senior software developer with expertise in full-stack development, cloud services, and scalable architectures.', 'papadopoulos.pdf', 'cert_nick_papadopoulos.pdf'),
('georgek', 'Financial analyst with extensive experience in budgeting, forecasting, and financial reporting.', 'kostas_recommendations.docx', 'georgek.pdf'),
('elenid', 'Creative graphic designer with a passion for brand identity, digital art, and user experience design.', 'eleniD.pdf', 'certifications-Eleni.pdf'),
('alexz', 'Project manager with a focus on IT projects, agile methodologies, and team collaboration.', 'zorbas.pdf', 'alexz.pdf'),
('chrisv', 'HR specialist with a focus on recruitment, employee development programs, and workplace diversity.', 'vasilakis.doc', 'vascert.pdf');


INSERT INTO etaireia (AFM, DOY, name, tel, street, num, city, country) VALUES
('123456789', 'Athens DOY', 'Innovative Solutions Ltd.', '2101234567', 'Innovation Str.', 42, 'Athens', 'Greece'),
('234567891', 'Thessaloniki DOY', 'Tech Pioneers Inc.', '2310123456', 'Innovator Ave.', 10, 'Thessaloniki', 'Greece'),
('345678912', 'Patras DOY', 'Green Energy Solutions S.A.', '2610123456', 'Eco Street', 5, 'Patras', 'Greece');

INSERT INTO evaluator (username, exp_years, firm) VALUES
('johnv', 5, '123456789'),
('dimg', 10, '234567891'),
('sophiaM', 8, '345678912');

INSERT INTO job (start_date, salary, position, edra, evaluator, announce_date, submission_date) VALUES
('2024-02-01', 55000, 'Software Developer', 'Athens', 'johnv', '2024-01-15 09:00:00', '2024-03-01'),
('2024-03-01', 45000, 'Marketing Specialist', 'Thessaloniki', 'dimg', '2024-01-20 10:00:00', '2024-04-01'),
('2024-04-01', 65000, 'Project Manager', 'Patras', 'sophiaM', '2024-01-25 11:00:00', '2024-05-01'),
('2024-02-15', 48000, 'Graphic Designer', 'Athens', 'johnv', '2024-01-10 08:00:00', '2024-03-15'),
('2024-03-20', 52000, 'Data Analyst', 'Thessaloniki', 'dimg', '2024-01-30 09:30:00', '2024-04-20'),
('2024-05-01', 70000, 'IT Manager', 'Patras', 'sophiaM', '2024-02-15 10:00:00', '2024-06-01'),
('2024-03-05', 56000, 'HR Specialist', 'Athens', 'johnv', '2024-02-01 08:45:00', '2024-04-05'),
('2024-04-10', 53000, 'Sales Executive', 'Thessaloniki', 'dimg', '2024-02-20 11:00:00', '2024-05-10');


INSERT INTO applies (cand_usrname, job_id) VALUES
('mariak', 1),
('nickp', 2),
('georgek', 3),
('elenid', 1),
('alexz', 4),
('chrisv', 5),
('mariak', 6),
('nickp', 7);

INSERT INTO languages (candid, lang) VALUES
('mariak', 'EN'),
('nickp', 'EN,FR'),
('georgek', 'EN,GR'),
('elenid', 'EN,SP'),
('alexz', 'EN,GE'),
('chrisv', 'EN,FR,SP');

INSERT INTO project (candid, num, descr, url) VALUES
('mariak', 1, 'Market Analysis for Product X', 'http://projectx.com'),
('nickp', 1, 'Development of Cloud-Based Tool Y', 'http://tooly.com'),
('georgek', 1, 'Financial Forecasting for Q3', 'http://forecastq3.com'),
('elenid', 1, 'Brand Identity Design for Brand Z', 'http://brandzdesign.com'),
('alexz', 1, 'IT Infrastructure Upgrade Project', 'http://itupgrade.com'),
('chrisv', 1, 'Employee Wellness Initiative', 'http://wellnessinitiative.com');


INSERT INTO degree (titlos, idryma, bathmida) VALUES
('Computer Science', 'MIT', 'BSc'),
('Marketing', 'Harvard University', 'MSc'),
('Project Management', 'Stanford University', 'PhD'),
('Graphic Design', 'Rhode Island School of Design', 'BSc'),
('Finance', 'London Business School', 'MSc'),
('Human Resources Management', 'Oxford University', 'PhD');



INSERT INTO has_degree (degr_title, degr_idryma, cand_usrname, etos, grade) VALUES
('Computer Science', 'MIT', 'mariak', '2018', 3.7),
('Marketing', 'Harvard University', 'nickp', '2016', 3.8),
('Project Management', 'Stanford University', 'georgek', '2019', 3.9),
('Graphic Design', 'Rhode Island School of Design', 'elenid', '2017', 3.6),
('Finance', 'London Business School', 'alexz', '2015', 3.5),
('Human Resources Management', 'Oxford University', 'chrisv', '2020', 3.8);


INSERT INTO subject (title, descr) VALUES
('Software Development', 'Subjects related to developing and maintaining software applications.'),
('Digital Marketing', 'Includes topics like SEO, SEM, content marketing, and social media marketing.'),
('Project Management', 'Covers methodologies like Agile, Scrum, and Waterfall.'),
('Graphic Design', 'Encompasses design principles, typography, and user experience design.'),
('Financial Analysis', 'Concerns with financial planning, analysis, and reporting.'),
('Human Resources', 'Involves recruitment, training, employee relations, and compliance.');

INSERT INTO requires (job_id, subject_title) VALUES
(1, 'Software Development'),
(2, 'Digital Marketing'),
(3, 'Project Management'),
(1, 'Graphic Design'),
(4, 'Financial Analysis'),
(5, 'Human Resources');

INSERT INTO dba (dba_username, start_date, end_date) VALUES
('alexz', '2024-01-17', NULL),
('dannyW', '2024-01-08', NULL);

-- - --- --- --- --- 3.1.2.1 ------ --- --- --- --- 

-- Exoun ginei panw sta creates
-- ALTER TABLE applies
-- ADD COLUMN status ENUM('active', 'completed', 'cancelled') NOT NULL DEFAULT 'active';

-- ALTER TABLE applies
-- ADD COLUMN application_date DATE NOT NULL DEFAULT CURRENT_DATE;

DELIMITER //

CREATE PROCEDURE register_application(
    IN p_cand_usrname VARCHAR(30), 
    IN p_job_id INT(11)
)
BEGIN
    DECLARE job_start_date DATE;
    DECLARE active_applications INT;
    DECLARE threshold_date DATE;

    -- Retrieve the start date of the job
    SELECT start_date INTO job_start_date
    FROM job
    WHERE id = p_job_id;

    -- Calculate the threshold date which is 15 days before the job's start date
    SET threshold_date = DATE_SUB(job_start_date, INTERVAL 15 DAY);

    -- Count the number of active applications for the candidate
    SELECT COUNT(*) INTO active_applications
    FROM applies
    WHERE cand_usrname = p_cand_usrname AND status = 'active';

    -- Check if the candidate already has 3 active applications
    IF (active_applications >= 3) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot register application: Candidate has 3 active applications.';
    -- Check if the current date is not within the allowed time frame to submit the application
    ELSEIF (CURDATE() > threshold_date) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot register application: Application period expired!';
    ELSE
        -- Insert the new application since all conditions are met
        INSERT INTO applies (cand_usrname, job_id, status, application_date)
        VALUES (p_cand_usrname, p_job_id, 'active', CURDATE());
    END IF;
END //

DELIMITER ;




DELIMITER //
CREATE PROCEDURE cancel_application(
    IN p_cand_usrname VARCHAR(30), 
    IN p_job_id INT(11)
)
BEGIN
    DECLARE job_start_date DATE;

    -- Check the start date of the job
    SELECT start_date INTO job_start_date
    FROM job
    WHERE id = p_job_id;

    -- Check if condition is met
    IF (CURDATE() <= DATE_SUB(job_start_date, INTERVAL 10 DAY)) THEN
        -- Update the application status to 'cancelled'
        UPDATE applies
        SET status = 'cancelled'
        WHERE cand_usrname = p_cand_usrname AND job_id = p_job_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot cancel application: Deadline exceeded';
    END IF;
END //
DELIMITER ;



-- -------------3122---------------------

-- ---- Ylopoieitai sto 3133!!!


-- -------------- 3123 --------------------------
--  egine sto create panw!
-- CREATE TABLE application_history (
--     cand_usrname VARCHAR(30),
--     job_id INT(11),
--     eval1 VARCHAR(30),
--     eval2 VARCHAR(30),
--     status ENUM('completed', 'cancelled') NOT NULL,
--     grade TINYINT(4),
--     PRIMARY KEY (cand_usrname, job_id)
-- );

DELIMITER //
CREATE PROCEDURE populate_application_history()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 90000 DO
        INSERT INTO application_history(eval1, eval2, cand_usrname, job_id, status, grade) 
        VALUES (
            CONCAT('evaluator', FLOOR(RAND() * 10)), 
            CONCAT('evaluator', FLOOR(RAND() * 10)), 
            CONCAT('employee', FLOOR(RAND() * 100)),
            FLOOR(RAND() * 1000) + 1, 
            'completed', 
            FLOOR(RAND() * 20) + 1
        )
        ON DUPLICATE KEY UPDATE 
            grade = VALUES(grade); 
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;



-- ----3124---------
-- Eginan panw sto create!
-- CREATE TABLE dba (
--     dba_username VARCHAR(30) NOT NULL,
--     start_date DATE NOT NULL,
--     end_date DATE,
--     FOREIGN KEY (dba_username) REFERENCES user(username)
-- );
-- INSERT INTO dba (dba_username, start_date, end_date) VALUES
-- ('alexz', '2024-01-17', NULL),
-- ('dannyW', '2024-01-08', NULL);

-- CREATE TABLE dba_log (
--     log_id INT PRIMARY KEY AUTO_INCREMENT,
--     dba_username VARCHAR(30) NOT NULL,
--     action VARCHAR(255) NOT NULL,
--     log_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
--     FOREIGN KEY (dba_username) REFERENCES dba(dba_username)
-- );

-- -- Triggers gia ton pinaka dba log!!!-----
DELIMITER //

CREATE TRIGGER after_job_insert
AFTER INSERT ON job
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz', 
        CONCAT('Inserted new job with ID ', NEW.id),
        NOW()
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_job_update
AFTER UPDATE ON job
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz', 
        CONCAT('Updated job with ID ', OLD.id),
        NOW()
    );
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER after_job_delete
AFTER DELETE ON job
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',  
        CONCAT('Deleted job with ID ', OLD.id),
        NOW()
    );
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER after_user_insert
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',
        CONCAT('Inserted new user with username ', NEW.username),
        NOW()
    );
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER after_user_update
AFTER UPDATE ON user
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',
        CONCAT('Updated user with username ', OLD.username),
        NOW()
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_user_delete
AFTER DELETE ON user
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',
        CONCAT('Deleted user with username ', OLD.username),
        NOW()
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_degree_insert
AFTER INSERT ON degree
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',
        CONCAT('Inserted new degree with title ', NEW.titlos, ' at ', NEW.idryma),
        NOW()
    );
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER after_degree_update
AFTER UPDATE ON degree
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',
        CONCAT('Updated degree with title ', OLD.titlos, ' at ', OLD.idryma),
        NOW()
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_degree_delete
AFTER DELETE ON degree
FOR EACH ROW
BEGIN
    INSERT INTO dba_log (dba_username, action, log_timestamp)
    VALUES (
        'alexz',
        CONCAT('Deleted degree with title ', OLD.titlos, ' from ', OLD.idryma),
        NOW()
    );
END //

DELIMITER ;




-- -------------- 3131 --------------------------


DELIMITER //

CREATE PROCEDURE check_and_calculate_evaluation(
    IN evaluator VARCHAR(30),
    IN employee_username VARCHAR(30),
    IN job_id INT,
    OUT grade TINYINT
)
BEGIN
    DECLARE degree_points INT DEFAULT 0;
    DECLARE language_points INT DEFAULT 0;
    DECLARE project_points INT DEFAULT 0;
    DECLARE existing_score1 TINYINT;
    DECLARE existing_score2 TINYINT;
    DECLARE ev1 VARCHAR(30);
    DECLARE ev2 VARCHAR(30);

    -- Check if an evaluation score has been registered by the evaluator
    SELECT score1, score2, evaluator1, evaluator2 INTO existing_score1, existing_score2, ev1, ev2
    FROM evaluation
    WHERE (ev1 = evaluator) OR (ev2 = evaluator) 
    AND cand_usrname = employee_username
    AND job_id = job_id;

    IF (existing_score1 IS NOT NULL AND evaluator = ev1) THEN
        SET grade = existing_score1;
    ELSEIF (existing_score2 IS NOT NULL AND evaluator = ev2) THEN
        SET grade = existing_score2;
    END IF;

    IF (existing_score1 IS NULL AND evaluator = ev1) OR (existing_score2 IS NULL AND evaluator = ev2) THEN
    SELECT SUM(
        CASE 
            WHEN d.bathmida = 'BSc' THEN 1
            WHEN d.bathmida = 'MSc' THEN 2
            WHEN d.bathmida = 'PhD' THEN 3
        END
    ) INTO degree_points
    FROM has_degree h
    INNER JOIN degree d ON h.degr_title = d.titlos AND h.degr_idryma = d.idryma 
    INNER JOIN employee e ON h.cand_usrname = e.username 
    INNER JOIN applies a ON e.username = a.cand_usrname
    WHERE h.cand_usrname = employee_username AND a.status='active';

        -- Calculate language points
        SELECT (LENGTH(lang) - LENGTH(REPLACE(lang, ',', '')) + 1) INTO language_points
        FROM languages
        WHERE candid = employee_username;

        -- Calculate project points
        SELECT COUNT(*) INTO project_points
        FROM project
        WHERE candid = employee_username;

        -- Sum up points
        SET grade = degree_points + language_points + project_points;
    END IF;


END //

DELIMITER ;



-- --------------  3132 --------------------------
DELIMITER //

CREATE PROCEDURE `manage_job_application`(IN `p_employee_username` VARCHAR(30), IN `p_job_id` INT, IN `p_action_char` CHAR(1))
BEGIN
    DECLARE v_applicationExists BOOLEAN DEFAULT FALSE;
    DECLARE v_applicationStatus VARCHAR(10);
    DECLARE v_evaluator1 VARCHAR(30);
    DECLARE v_evaluator2 VARCHAR(30);


    SELECT COUNT(*), status INTO v_applicationExists, v_applicationStatus
    FROM applies
    WHERE cand_usrname = p_employee_username AND job_id = p_job_id;

    SET v_applicationExists = v_applicationExists > 0;

    IF p_action_char = 'i' THEN

        SELECT evaluator1, evaluator2 INTO v_evaluator1, v_evaluator2
        FROM evaluation
        WHERE job_id = p_job_id;


        IF v_evaluator1 IS NOT NULL AND v_evaluator2 IS NOT NULL THEN
            IF NOT v_applicationExists THEN
                INSERT INTO applies (cand_usrname, job_id, status) VALUES (p_employee_username, p_job_id, 'active');
                SELECT 'Application created successfully';
            ELSE
                SELECT 'Application already exists';
            END IF;
        ELSE


            SET v_evaluator1 = (SELECT username FROM evaluator ORDER BY RAND() LIMIT 1);
            SET v_evaluator2 = (SELECT username FROM evaluator WHERE username <> v_evaluator1 ORDER BY RAND() LIMIT 1);


            INSERT INTO evaluation VALUES(p_employee_username,p_job_id,v_evaluator1, v_evaluator2,NULL,NULL);
            SELECT 'Evaluators updated, please reapply';
        END IF;
    ELSEIF p_action_char = 'c' THEN

        IF v_applicationExists AND v_applicationStatus = 'active' THEN
            UPDATE applies SET status = 'cancelled' WHERE cand_usrname = p_employee_username AND job_id = p_job_id;
            SELECT 'Application cancelled successfully';
        ELSE
            SELECT 'No active application to cancel';
        END IF;
    ELSEIF p_action_char = 'a' THEN

        IF v_applicationExists AND v_applicationStatus = 'cancelled' THEN
            UPDATE applies SET status = 'active' WHERE cand_usrname = p_employee_username AND job_id = p_job_id;
            SELECT 'Application activated successfully';
        ELSE
            SELECT 'No cancelled application to activate';
        END IF;
    ELSE
        SELECT 'Invalid action character';
    END IF;

END //
DELIMITER ;

-- -------------- 3133 --------------------------
DELIMITER //
CREATE PROCEDURE process_single_application(IN a_job_id INT)
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temp_results;
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_results (
        cand_usrname VARCHAR(30),
        total_score DECIMAL(5,2),
        application_date DATE,
        PRIMARY KEY (cand_usrname)
    );

    -- Fetch scores from evaluations and qualifications
    INSERT INTO temp_results (cand_usrname, total_score, application_date)
    SELECT 
        a.cand_usrname,
        CASE 
            WHEN ev.score1 IS NOT NULL AND ev.score2 IS NOT NULL THEN (ev.score1 + ev.score2) / 2
            ELSE SUM(
                CASE 
                    WHEN d.bathmida = 'PhD' THEN 3 
                    WHEN d.bathmida = 'MSc' THEN 2 
                    WHEN d.bathmida = 'BSc' THEN 1 
                    ELSE 0 
                END
            ) + (SELECT (LENGTH(lang) - LENGTH(REPLACE(lang, ',', '')) + 1)) + COUNT(DISTINCT p.num)
        END AS total_score,
        a.application_date
    FROM applies a
    LEFT JOIN evaluation ev ON a.cand_usrname = ev.cand_usrname AND a.job_id = ev.job_id
    LEFT JOIN has_degree hd ON a.cand_usrname = hd.cand_usrname
    LEFT JOIN degree d ON hd.degr_title = d.titlos AND hd.degr_idryma = d.idryma
    LEFT JOIN languages l ON a.cand_usrname = l.candid
    LEFT JOIN project p ON a.cand_usrname = p.candid
    WHERE a.job_id = a_job_id AND a.status = 'active'
    GROUP BY a.cand_usrname, a.application_date
    ORDER BY total_score DESC, a.application_date ASC;

    -- Debugging: Select all data from temp_results
    SELECT cand_usrname as Top_applicant, 'for job id:', a_job_id , ' with grade:', total_score
    FROM temp_results;

    -- Determine the candidate with the highest score
    SET @winner := (SELECT cand_usrname FROM temp_results ORDER BY total_score DESC, application_date ASC LIMIT 1);

    -- Move the selected candidate's application to application_history2 and mark as 'completed'
    INSERT INTO application_history2 (top_applicant, job_id, status)
    SELECT cand_usrname, job_id, 'completed'
    FROM applies
    WHERE job_id = a_job_id AND cand_usrname = @winner;

    -- Update the status of the winning application to 'completed'
    UPDATE applies
    SET status = 'completed'
    WHERE job_id = a_job_id AND cand_usrname = @winner;

    -- Update other applications for the same job to 'cancelled'
    UPDATE applies
    SET status = 'cancelled'
    WHERE job_id = a_job_id AND cand_usrname != @winner;

    -- Cleanup: drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_results;
END //

DELIMITER ;





-- -----------3134---------------
-- ----------INDEXES------------
-- a) --
CREATE INDEX idx_grade ON application_history (grade);
-- b) --
CREATE INDEX idx_eval1 ON application_history (eval1);
CREATE INDEX idx_eval2 ON application_history (eval2);

-- a--

DELIMITER //
CREATE PROCEDURE get_applications_by_grade_range(
    IN min_grade TINYINT,
    IN max_grade TINYINT
)
BEGIN
    SELECT cand_usrname, job_id
    FROM application_history
    WHERE grade BETWEEN min_grade AND max_grade;
END //

DELIMITER ;


-- b--
DELIMITER //
CREATE PROCEDURE get_applications_by_evaluator(
    IN evaluator_username VARCHAR(30)
)
BEGIN
    SELECT cand_usrname, job_id FROM application_history WHERE eval1 = evaluator_username
    UNION
    SELECT cand_usrname, job_id FROM application_history WHERE eval2 = evaluator_username;
END //

DELIMITER ;






-- --TRIGGERS----

-- ----3.1.4.2 -----
DELIMITER //

CREATE TRIGGER prevent_application_entry
BEFORE INSERT ON applies
FOR EACH ROW
BEGIN
  DECLARE application_count INT;
  
  -- Check if the submission date is less than 15 days from the start date
  SELECT start_date INTO @job_start_date FROM job WHERE id = NEW.job_id;
  IF NEW.application_date > DATE_SUB(@job_start_date, INTERVAL 15 DAY) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Application cannot be submitted less than 15 days from the job start date';
  END IF;

  -- Check if the employee already has three active applications
  SELECT COUNT(*) INTO application_count
  FROM applies
  WHERE cand_usrname = NEW.cand_usrname AND status = 'active';

  IF application_count >= 3 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Employee already has three active applications';
  END IF;
END;
//

DELIMITER ;

-- ----3.1.4.3 -----
DELIMITER //

CREATE TRIGGER prevent_application_cancellation
BEFORE UPDATE ON applies
FOR EACH ROW
BEGIN
  DECLARE application_count INT;
  DECLARE job_start_date DATE;

  -- Check if the status is being updated to 'cancelled'
  IF NEW.status = 'cancelled' AND OLD.status <> 'cancelled' THEN
    -- Get the start date of the job associated with the application
    SELECT start_date INTO job_start_date FROM job WHERE id = NEW.job_id;
    
    -- Check if the date of cancellation is less than 10 days from the start date
    IF NEW.application_date >= DATE_SUB(job_start_date, INTERVAL 10 DAY) THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Application cannot be cancelled less than 10 days from the job start date';
    END IF;
  END IF;

  -- Check if the employee already has three active applications
  IF NEW.status = 'active' THEN
    SELECT COUNT(*) INTO application_count
    FROM applies
    WHERE cand_usrname = NEW.cand_usrname AND status = 'active';

    IF application_count >= 3 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Employee already has three active applications';
    END IF;
  END IF;
END;
//

DELIMITER ;





