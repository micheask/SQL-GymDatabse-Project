# What's the average BMI for men and women and what's the average for both?

USE gym_membership_db;

DROP VIEW IF EXISTS avg_bmi_by_gender;

CREATE VIEW avg_bmi_by_gender AS
SELECT 
	Gender, 
    ROUND(AVG(BMI)) AS avg_BMI,
    (SELECT ROUND(AVG(BMI)) FROM BioMetrics) AS Overall_Avg_BMI
FROM Members
JOIN Gender
ON Members.Gender_id = Gender.Gender_id
JOIN BioMetrics
ON Members.Member_id = BioMetrics.Member_id
GROUP BY Gender;

SELECT * FROM avg_bmi_by_gender;




# How do different workouts affect heart rate and calories burned?

USE gym_membership_db;

DROP VIEW IF EXISTS workout_impact;

CREATE VIEW workout_impact AS
SELECT 
    Workout_Type,
    ROUND(AVG(Avg_BPM)) AS Avg_Heart_Rate,
    ROUND(AVG(Max_BPM)) AS Avg_Max_Heart_Rate,
    ROUND(AVG(Calories_Burned)) AS Avg_Calories
FROM WorkoutSession
JOIN WorkoutType
ON WorkoutSession.Workout_Type_id = WorkoutType.Workout_Type_id
GROUP BY Workout_Type;

SELECT * FROM workout_impact;



# How does experience level influence workout intensity?

USE gym_membership_db;

DROP VIEW IF EXISTS Experience_Intensity;

CREATE VIEW Experience_Intensity AS
SELECT 
    Experience_Level,
    ROUND(AVG(Max_BPM)) AS Avg_Max_BPM,
    ROUND(AVG(Calories_Burned)) AS Avg_Calories
FROM WorkoutSession
JOIN Members 
ON WorkoutSession.Member_id = Members.Member_id
JOIN ExperienceLevel 
ON Members.Experience_Level_id = ExperienceLevel.Experience_Level_id
GROUP BY Experience_Level;


# Is water intake level affected by experience level? Which members drink more water than average?

USE gym_membership_db;

DROP VIEW IF EXISTS high_water_intake;

CREATE VIEW high_water_intake AS
SELECT 
    Age,
    Gender,
    Water_Intake_litres,
    Experience_Level 
FROM Members
JOIN Gender 
ON Members.Gender_id = Gender.Gender_id
JOIN BioMetrics
ON Members.Member_id = BioMetrics.Member_id
JOIN ExperienceLevel
ON Members.Experience_Level_id = ExperienceLevel.Experience_Level_id
WHERE Water_Intake_litres > (
    SELECT AVG(Water_Intake_litres) FROM BioMetrics
);

SELECT * FROM high_water_intake; 


# Procedure to see members calories burned and MaxBPM.

USE gym_membership_db;

DROP PROCEDURE IF EXISTS Calories_Burned_Member;

DELIMITER //

CREATE PROCEDURE Calories_Burned_Member(IN calories_member INT)
BEGIN
    SELECT
    Calories_Burned,
    Max_BPM
    FROM WorkoutSession
    WHERE Member_id = calories_member;
END //

DELIMITER ;

CALL Calories_Burned_Member(973);




# Procedure to see the gym members BMI and the workout_type they do.

USE gym_membership_db;

DROP PROCEDURE IF EXISTS Total_Workouts_Member;

DELIMITER //

CREATE PROCEDURE Total_Workouts_Member(IN workout_member INT)
BEGIN
    SELECT 
        WorkoutSession.Member_id AS Gym_Member,
        Workout_Type,
        ROUND(BMI) AS BMI
    FROM WorkoutSession
    JOIN WorkoutType
    ON WorkoutSession.Workout_Type_id = WorkoutType.Workout_Type_id
    JOIN BioMetrics
    ON WorkoutSession.Member_id = BioMetrics.Member_id
    WHERE WorkoutSession.Member_id = workout_member;
END //

DELIMITER ;

CALL Total_Workouts_Member(66);



# Function that determines if gym members may be obese/overweight.
USE gym_membership_db;

DROP FUNCTION IF EXISTS Obesity_Chart;

DELIMITER //

CREATE FUNCTION Obesity_Chart(BMI_Value DECIMAL(5,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    IF BMI_Value > 30 THEN
        RETURN 'Yes';
    ELSE
        RETURN 'No';
    END IF;
END //

DELIMITER ;


SELECT Member_id, BMI, Obesity_Chart(BMI) AS Obese
FROM BioMetrics;




# Function to see who is younger than 24 in the gym.

USE gym_membership_db;

DROP FUNCTION IF EXISTS Is_Young;

DELIMITER //

CREATE FUNCTION Is_Young(Young_Member INT)
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
    DECLARE member_age INT;
    SELECT Age INTO member_age
    FROM Members
    WHERE Member_id = Young_Member;
    IF member_age < 24 THEN
        RETURN 'Yes';
    ELSE
        RETURN 'No';
    END IF;
END //

DELIMITER ;

SELECT Member_id, Age, Is_Young(Member_id) AS Young
FROM Members;


