
--  HOSPITAL MANAGEMENT SYSTEM
--  UCS310 - Database Management Systems
--  Thapar Institute of Engineering & Technology
--  Group: Ishaan Mishra (1024030346)
--         Samyak Bhushan (1024030344)
--         Chetanya Chawla (1024030351)
--  Lab Instructor: Dr. Amrita
--  Academic Year: 2025-26



-- ============================================================
-- SECTION 1: STORED PROCEDURES
-- ============================================================

-- Procedure 1: Book a new appointment
-- Validates patient and doctor existence before inserting.
-- Mirrors the INSERT action triggered from the frontend.

CREATE OR REPLACE PROCEDURE book_appointment (
    p_patient_id IN Appointment.patient_id%TYPE,
    p_doctor_id IN Appointment.doctor_id%TYPE,
    p_date IN Appointment.appt_date%TYPE,
    p_time IN Appointment.appt_time%TYPE
) AS
    v_count NUMBER;
BEGIN
    -- Validate patient
    SELECT COUNT(*) INTO v_count
    FROM Patient WHERE patient_id = p_patient_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Patient ID does not exist.');
    END IF;

    -- Validate doctor
    SELECT COUNT(*) INTO v_count
    FROM Doctor WHERE doctor_id = p_doctor_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Doctor ID does not exist.');
    END IF;

    -- Insert appointment with default status 'Scheduled'
    INSERT INTO Appointment (patient_id, doctor_id, appt_date, appt_time, status)
    VALUES (p_patient_id, p_doctor_id, p_date, p_time, 'Scheduled');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Appointment booked successfully for Patient ID: ' || p_patient_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error in book_appointment: ' || SQLERRM);
END;
/

-- How to call Procedure 1:
-- EXEC book_appointment(1, 2, TO_DATE('2024-07-10','YYYY-MM-DD'), '10:00');


-- ─────────────────────────────────────────────────────────────

-- Procedure 2: Update payment status of a bill
-- Mirrors the "Mark as Paid / Edit bill status" action in the frontend.
CREATE OR REPLACE PROCEDURE update_payment (
    p_bill_id IN Billing.bill_id%TYPE,
    p_status IN Billing.payment_status%TYPE
) AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Billing WHERE bill_id = p_bill_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Bill ID not found.');
    END IF;

    UPDATE Billing
    SET payment_status = p_status
    WHERE bill_id = p_bill_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Bill #' || p_bill_id || ' payment status updated to: ' || p_status);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error in update_payment: ' || SQLERRM);
END;
/

-- How to call Procedure 2:
-- EXEC update_payment(4, 'Paid');


-- ─────────────────────────────────────────────────────────────

-- Procedure 3: Add or update a treatment record
--   Mirrors the "Add Treatment" action in the frontend.
CREATE OR REPLACE PROCEDURE add_treatment (
    p_appt_id IN Treatment.appointment_id%TYPE,
    p_diagnosis IN Treatment.diagnosis%TYPE,
    p_medicine IN Treatment.medicine%TYPE,
    p_date IN Treatment.treatment_date%TYPE,
    p_notes IN Treatment.notes%TYPE
) AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Appointment WHERE appointment_id = p_appt_id;
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Appointment ID does not exist.');
    END IF;

    INSERT INTO Treatment (appointment_id, diagnosis, medicine, treatment_date, notes)
    VALUES (p_appt_id, p_diagnosis, p_medicine, p_date, p_notes);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Treatment recorded for Appointment ID: ' || p_appt_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error in add_treatment: ' || SQLERRM);
END;
/

-- How to call Procedure 3:
-- EXEC add_treatment(6, 'Dermatitis', 'Hydrocortisone 1%', SYSDATE, 'Follow-up in 2 weeks');


-- ============================================================
-- SECTION 2: FUNCTIONS
-- ============================================================

-- Function 1: Get total bill amount for a patient
--   Called in the frontend dashboard to show per-patient totals.
CREATE OR REPLACE FUNCTION get_total_bill (
    p_patient_id IN Patient.patient_id%TYPE
) RETURN NUMBER AS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(amount), 0) INTO v_total
    FROM Billing
    WHERE patient_id = p_patient_id;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in get_total_bill: ' || SQLERRM);
        RETURN -1;
END;
/


-- Function 2: Get total appointment count for a doctor
-- Used in the dashboard "Doctor Appointment Summary" panel.
CREATE OR REPLACE FUNCTION get_doctor_appt_count (
    p_doctor_id IN Doctor.doctor_id%TYPE
) RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Appointment
    WHERE doctor_id = p_doctor_id;

    RETURN v_count;

EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END;
/


-- ============================================================
-- SECTION 3: CURSORS
-- ============================================================

-- Cursor 1: Display all patients with pending bill amounts
--   Equivalent to the "Pending Bills" panel on the dashboard.
DECLARE
    CURSOR cur_pending_bills IS
        SELECT p.full_name, b.amount, b.bill_date
        FROM Patient p
        JOIN Billing b ON p.patient_id = b.patient_id
        WHERE b.payment_status = 'Pending';

    v_name Patient.full_name%TYPE;
    v_amount Billing.amount%TYPE;
    v_date Billing.bill_date%TYPE;
BEGIN
    OPEN cur_pending_bills;
    DBMS_OUTPUT.PUT_LINE('=== Pending Bills ===');
    LOOP
        FETCH cur_pending_bills INTO v_name, v_amount, v_date;
        EXIT WHEN cur_pending_bills%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Patient: ' || v_name || '  |  Amount: Rs.' || v_amount || '  |  Date: ' || v_date
        );
    END LOOP;
    CLOSE cur_pending_bills;
END;
/


-- Cursor 2 (FOR LOOP): List all doctors with their appointment count
-- Equivalent to the "Doctor Appointment Summary" panel on the dashboard.
DECLARE
    CURSOR cur_doctors IS
        SELECT d.full_name, d.specialization,
               COUNT(a.appointment_id) AS appt_count
        FROM Doctor d
        LEFT JOIN Appointment a ON d.doctor_id = a.doctor_id
        GROUP BY d.doctor_id, d.full_name, d.specialization;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Doctor Appointment Summary ===');
    FOR rec IN cur_doctors LOOP
        DBMS_OUTPUT.PUT_LINE(
            rec.full_name || ' (' || rec.specialization || ')' || '  =>  Appointments: ' || rec.appt_count
        );
    END LOOP;
END;
/


-- ============================================================
-- SECTION 4: TRIGGERS
-- ============================================================

-- Trigger 1: Auto-generate a bill when an appointment is marked 'Completed'
-- This is the backend equivalent of the frontend's automatic bill
-- generation that fires when appointment status is set to 'Completed'.
CREATE OR REPLACE TRIGGER trg_auto_billing
AFTER UPDATE ON Appointment
FOR EACH ROW
WHEN (NEW.status = 'Completed' AND OLD.status != 'Completed')
BEGIN
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM Billing WHERE appointment_id = :NEW.appointment_id;

        IF v_count = 0 THEN
            INSERT INTO Billing (patient_id, appointment_id, amount, payment_status, bill_date)
            VALUES (:NEW.patient_id, :NEW.appointment_id, 500.00, 'Pending', SYSDATE);
            DBMS_OUTPUT.PUT_LINE(
                'Auto-billing: Bill generated for Appointment #' || :NEW.appointment_id ||
                ' | Patient ID: ' || :NEW.patient_id
            );
        END IF;
    END;
END;
/

-- Test Trigger 1:
-- UPDATE Appointment SET status = 'Completed' WHERE appointment_id = 6;
-- SELECT * FROM Billing ORDER BY bill_id DESC;


-- ─────────────────────────────────────────────────────────────

-- Trigger 2: Prevent deleting a patient who has existing appointments
--   Backend enforcement of the frontend's delete-guard logic.
CREATE OR REPLACE TRIGGER trg_prevent_patient_delete
BEFORE DELETE ON Patient
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Appointment
    WHERE patient_id = :OLD.patient_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20010,
            'Cannot delete Patient ID ' || :OLD.patient_id || ' – ' || v_count || ' appointment(s) exist.'
        );
    END IF;
END;
/

-- Test Trigger 2:
-- DELETE FROM Patient WHERE patient_id = 1;  -- raises ORA-20010


-- ─────────────────────────────────────────────────────────────

-- Trigger 3: Audit log - record every payment status change
--   Mirrors the SQL log panel in the frontend that records every
--   UPDATE made to the Billing table.

-- Audit log table (create once)
CREATE TABLE Billing_Log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bill_id NUMBER,
    old_status VARCHAR2(20),
    new_status VARCHAR2(20),
    changed_on DATE DEFAULT SYSDATE
);

CREATE OR REPLACE TRIGGER trg_billing_audit
AFTER UPDATE OF payment_status ON Billing
FOR EACH ROW
BEGIN
    INSERT INTO Billing_Log (bill_id, old_status, new_status, changed_on)
    VALUES (:OLD.bill_id, :OLD.payment_status, :NEW.payment_status, SYSDATE);
END;
/

-- Test Trigger 3:
-- EXEC update_payment(4, 'Paid');
-- SELECT * FROM Billing_Log;


-- ─────────────────────────────────────────────────────────────

-- Trigger 4: Prevent duplicate billing for the same appointment
CREATE OR REPLACE TRIGGER trg_prevent_duplicate_bill
BEFORE INSERT ON Billing
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Billing
    WHERE appointment_id = :NEW.appointment_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20011,
            'A bill already exists for Appointment #' || :NEW.appointment_id
        );
    END IF;
END;
/

-- Test Trigger 4:
-- INSERT INTO Billing (patient_id, appointment_id, amount, payment_status, bill_date)
-- VALUES (1, 1, 999, 'Pending', SYSDATE);  -- raises ORA-20011


-- ============================================================
-- SECTION 5: EXCEPTION HANDLING (Standalone Block)
-- ============================================================

-- Safe patient lookup with full exception handling
DECLARE
    v_patient_id Patient.patient_id%TYPE  := 99;  -- Non-existent ID
    v_name Patient.full_name%TYPE;
    v_blood Patient.blood_group%TYPE;
BEGIN
    SELECT full_name, blood_group
    INTO v_name, v_blood
    FROM Patient
    WHERE patient_id = v_patient_id;

    DBMS_OUTPUT.PUT_LINE('Patient Found: ' || v_name || ' | Blood Group: ' || v_blood);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No patient found with ID = ' || v_patient_id);
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Error: Multiple records returned.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected Error: ' || SQLERRM);
END;
/


-- ============================================================
-- SECTION 6: ANONYMOUS PL/SQL BLOCK (Combined Demo)
-- ============================================================

-- Full patient summary: name, all appointments, total bill
-- This is the backend equivalent of the patient detail view
-- that can be reconstructed from frontend state.
DECLARE
    v_pid NUMBER := 1;
    v_name Patient.full_name%TYPE;
    v_appt_count NUMBER := 0;
    v_total_bill NUMBER := 0;

    CURSOR cur_appts IS
        SELECT a.appt_date, a.status, d.full_name AS doctor, t.diagnosis
        FROM Appointment a
        JOIN Doctor d ON a.doctor_id     = d.doctor_id
        LEFT JOIN Treatment t ON a.appointment_id = t.appointment_id
        WHERE a.patient_id = v_pid
        ORDER BY a.appt_date;
BEGIN
    SELECT full_name INTO v_name FROM Patient WHERE patient_id = v_pid;

    DBMS_OUTPUT.PUT_LINE('====================================');
    DBMS_OUTPUT.PUT_LINE('Patient Summary: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('====================================');

    FOR rec IN cur_appts LOOP
        v_appt_count := v_appt_count + 1;
        DBMS_OUTPUT.PUT_LINE(
            'Appt ' || v_appt_count || ': ' || rec.appt_date || ' | Doctor: '    || rec.doctor || ' | Status: '    || rec.status || ' | Diagnosis: ' || NVL(rec.diagnosis, 'N/A')
        );
    END LOOP;

    v_total_bill := get_total_bill(v_pid);
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Billed: Rs. ' || v_total_bill);
    DBMS_OUTPUT.PUT_LINE('Appointment Count: ' || v_appt_count);
    DBMS_OUTPUT.PUT_LINE('====================================');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Patient ID ' || v_pid || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
