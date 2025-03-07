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
-- --AT 3133!----


-- -------------- 3123 --------------------------


DELIMITER //
CREATE PROCEDURE populate_application_history()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 70000 DO
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


-- --------------- 3131-----------------

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



-- -------------- 3132 --------------------------

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

-- -------------3134---------------
-- ------------INDEXES------------
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