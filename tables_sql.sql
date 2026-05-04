-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM
--  UCS310 – Database Management Systems
--  Thapar Institute of Engineering & Technology
--  Group: Ishaan Mishra (1024030346)
--         Samyak Bhushan (1024030344)
--         Chetanya Chawla (1024030351)
--  Lab Instructor: Dr. Amrita
--  Academic Year: 2025–26
-- ============================================================

-- ============================================================
-- SECTION 1: CREATE TABLES (DDL)
-- ============================================================

-- Drop tables in reverse dependency order to avoid FK errors
DROP TABLE IF EXISTS Billing;
DROP TABLE IF EXISTS Treatment;
DROP TABLE IF EXISTS Appointment;
DROP TABLE IF EXISTS Doctor;
DROP TABLE IF EXISTS Patient;


-- 1. Patient Table
CREATE TABLE Patient (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    dob DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    phone VARCHAR(15)   UNIQUE,
    address VARCHAR(200),
    blood_group VARCHAR(5),
    reg_date DATE DEFAULT (CURRENT_DATE)
);

-- 2. Doctor Table
CREATE TABLE Doctor (
    doctor_id INT PRIMARY KEY,
    full_name  VARCHAR(100)  NOT NULL,
    specialization  VARCHAR(100),
    phone VARCHAR(15)   UNIQUE,
    email VARCHAR(100),
    salary DECIMAL(10,2) CHECK (salary > 0),
    joining_date DATE
);

-- 3. Appointment Table
CREATE TABLE Appointment (
    appointment_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appt_date DATE NOT NULL,
    appt_time TIME,
    status VARCHAR(20)  DEFAULT 'Scheduled'
                                 CHECK (status IN ('Scheduled', 'Completed', 'Cancelled')),
    FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES Doctor(doctor_id)
);

-- 4. Treatment Table
CREATE TABLE Treatment (
    treatment_id INT PRIMARY KEY,
    appointment_id INT          NOT NULL,
    diagnosis VARCHAR(200),
    medicine VARCHAR(200),
    treatment_date  DATE,
    notes TEXT,
    FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id)
);

-- 5. Billing Table
CREATE TABLE Billing (
    bill_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2) CHECK (amount >= 0),
    payment_status  VARCHAR(20)   DEFAULT 'Pending'
                                  CHECK (payment_status IN ('Pending', 'Paid', 'Cancelled')),
    bill_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (patient_id)     REFERENCES Patient(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id)
);


-- ============================================================
-- SECTION 2: INSERT SAMPLE DATA (DML)
-- ============================================================

-- Patients
INSERT INTO Patient (patient_id,full_name, dob, gender, phone, address, blood_group, reg_date) VALUES
(1,'Aarav Sharma','1990-03-15', 'M', '9876543210', 'Ludhiana, Punjab','O+',  '2024-01-10'),
(2,'Priya Mehta','1985-07-22', 'F', '9876543211', 'Chandigarh','A+',  '2024-02-05'),
(3,'Rohan Singh','2000-11-01', 'M', '9876543212', 'Amritsar, Punjab','B+',  '2024-02-18'),
(4,'Sneha Kapoor','1995-05-30', 'F', '9876543213', 'Delhi','AB-', '2024-03-01'),
(5,'Vikram Joshi','1978-09-09', 'M', '9876543214', 'Jalandhar, Punjab','O-',  '2024-03-15'),
(6,'Ananya Gupta','2003-01-20', 'F', '9876543215', 'Patiala, Punjab','A-',  '2024-04-02'),
(7,'Manish Verma','1988-06-11', 'M', '9876543216', 'Ludhiana, Punjab','B-',  '2024-04-20'),
(8,'Kavya Nair','1992-12-25', 'F', '9876543217', 'Mumbai','AB+', '2024-05-05');

-- Doctors
INSERT INTO Doctor (doctor_id,full_name, specialization, phone, email, salary, joining_date) VALUES
(1,'Dr. Ramesh Kumar','Cardiology','9111111101','ramesh@hms.com',120000.00,'2018-06-01'),
(2,'Dr. Sunita Rao','Neurology','9111111102','sunita@hms.com',130000.00,'2019-03-15'),
(3,'Dr. Anil Patel','Orthopedics','9111111103','anil@hms.com',110000.00,'2020-01-10'),
(4,'Dr. Meena Khanna','General Medicine','9111111104', 'meena@hms.com',90000.00,'2021-07-20'),
(5,'Dr. Suresh Iyer','Dermatology','9111111105', 'suresh@hms.com',95000.00,'2022-02-28');

-- Appointments
INSERT INTO Appointment (appointment_id,patient_id, doctor_id, appt_date, appt_time, status) VALUES
(1,1,1,'2024-06-01','10:00:00','Completed'),
(2,2,2,'2024-06-03','11:30:00','Completed'),
(3,3,3,'2024-06-05','09:00:00','Completed'),
(4,4,4,'2024-06-07','14:00:00','Completed'),
(5,5,1,'2024-06-10','10:30:00','Completed'),
(6,6,5,'2024-06-12','15:00:00','Scheduled'),
(7,7,2,'2024-06-15','11:00:00','Cancelled'),
(8,8,4,'2024-06-18','09:30:00','Completed');

-- Treatments
INSERT INTO Treatment (appointment_id, diagnosis, medicine, treatment_date, notes) VALUES
(1,'Hypertension','Amlodipine 5mg','2024-06-01','Monitor BP weekly'),
(2,'Migraine','Sumatriptan 50mg','2024-06-03','Avoid triggers'),
(3,'Knee Pain','Ibuprofen 400mg','2024-06-05','Physiotherapy advised'),
(4,'Viral Fever','Paracetamol 500mg','2024-06-07','Rest and hydration'),
(5,'Chest Discomfort','Nitroglycerin 0.5mg','2024-06-10','ECG scheduled'),
(8,'Skin Allergy','Cetirizine 10mg','2024-06-18','Avoid allergens');

-- Billing
INSERT INTO Billing (bill_id,patient_id, appointment_id, amount, payment_status, bill_date) VALUES
(1,1,1,1500.00,'Paid','2024-06-01'),
(2,2,2,2000.00,'Paid','2024-06-03'),
(3,3,3,1200.00,'Paid','2024-06-05'),
(4,4,4,800.00,'Pending','2024-06-07'),
(5,5,5,1800.00,'Paid','2024-06-10'),
(6,8,8,950.00,'Pending','2024-06-18');


-- ============================================================
-- SECTION 3: SQL QUERIES
-- ============================================================

-- Query 1: All patients with their appointment details (INNER JOIN)
SELECT
    p.patient_id,
    p.full_name AS Patient,
    d.full_name AS Doctor,
    d.specialization,
    a.appt_date,
    a.status
FROM Patient p
JOIN Appointment a ON p.patient_id = a.patient_id
JOIN Doctor d ON a.doctor_id  = d.doctor_id
ORDER BY a.appt_date;


-- Query 2: Total billing per patient (Aggregate + GROUP BY)
SELECT
    p.full_name,
    COUNT(b.bill_id) AS Total_Visits,
    SUM(b.amount) AS Total_Amount
FROM Patient p
JOIN Billing b ON p.patient_id = b.patient_id
GROUP BY p.patient_id, p.full_name
ORDER BY Total_Amount DESC;


-- Query 3: Doctors with more than 1 appointment (HAVING)
SELECT
    d.full_name,
    d.specialization,
    COUNT(a.appointment_id) AS Appointments
FROM Doctor d
JOIN Appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.full_name, d.specialization
HAVING COUNT(a.appointment_id) > 1;


-- Query 4: Patients with pending bills (Subquery)
SELECT full_name, phone
FROM Patient
WHERE patient_id IN (
    SELECT patient_id FROM Billing WHERE payment_status = 'Pending'
);


-- Query 5: View – Completed appointments with treatment info
CREATE OR REPLACE VIEW vw_CompletedTreatments AS
SELECT
    p.full_name AS Patient,
    d.full_name AS Doctor,
    a.appt_date,
    t.diagnosis,
    t.medicine
FROM Patient p
JOIN Appointment a ON p.patient_id    = a.patient_id
JOIN Doctor d ON a.doctor_id = d.doctor_id
JOIN Treatment t   ON a.appointment_id = t.appointment_id
WHERE a.status = 'Completed';

-- Use the view
SELECT * FROM vw_CompletedTreatments;


-- Query 6: Average salary of doctors by specialization
SELECT
    specialization,
    ROUND(AVG(salary), 2) AS Avg_Salary
FROM Doctor
GROUP BY specialization
ORDER BY Avg_Salary DESC;


-- Query 7: Patients who have never been billed (LEFT JOIN)
SELECT p.full_name, p.phone
FROM Patient p
LEFT JOIN Billing b ON p.patient_id = b.patient_id
WHERE b.bill_id IS NULL;


-- Query 8: Full patient summary (patient + appointment + treatment + billing)
SELECT
    p.full_name AS Patient,
    p.blood_group,
    d.full_name AS Doctor,
    d.specialization,
    a.appt_date,
    a.status AS Appt_Status,
    t.diagnosis,
    t.medicine,
    b.amount,
    b.payment_status
FROM Patient p
LEFT JOIN Appointment a ON p.patient_id = a.patient_id
LEFT JOIN Doctor d ON a.doctor_id  = d.doctor_id
LEFT JOIN Treatment t ON a.appointment_id = t.appointment_id
LEFT JOIN Billing b ON a.appointment_id = b.appointment_id
ORDER BY p.patient_id, a.appt_date;


-- ============================================================
-- SECTION 4: TRANSACTION MANAGEMENT
-- ============================================================

-- Book an appointment and log a pending bill atomically
START TRANSACTION;

INSERT INTO Appointment (patient_id, doctor_id, appt_date, appt_time, status)
VALUES (6, 3, '2024-07-01', '10:00:00', 'Scheduled');

SAVEPOINT sp_before_billing;

INSERT INTO Billing (patient_id, appointment_id, amount, payment_status, bill_date)
VALUES (6, LAST_INSERT_ID(), 1100.00, 'Pending', CURRENT_DATE);

-- Commit if everything is fine
COMMIT;

-- To undo only the billing step (example):
-- ROLLBACK TO sp_before_billing;
-- COMMIT;
