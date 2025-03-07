-- --TRIGGERS----

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