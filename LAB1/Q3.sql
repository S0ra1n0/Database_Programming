-- Create the database
-- USE master;
-- GO
-- CREATE DATABASE MedicalClinicDB;
-- GO
-- USE MedicalClinicDB;
-- GO

-- 1. Patient Table
CREATE TABLE Patient (
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Address VARCHAR(255),
    Phone VARCHAR(20),
    PrimaryInsuranceProvider VARCHAR(100)
);

-- 2. Doctor Table
CREATE TABLE Doctor (
    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100),
    Phone VARCHAR(20)
);

-- 3. Appointment Table (Patient <-> Doctor: M:M via Appointment, constrained to 1:1 per appointment instance)
CREATE TABLE Appointment (
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDateTime DATETIME NOT NULL,
    Status VARCHAR(50) NOT NULL CHECK (Status IN ('Scheduled', 'Unscheduled - Emergency', 'Kept', 'Cancelled')),
    ReasonForVisit VARCHAR(255),
    
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

-- 4. Visit Table (Core entity for medical record and billing, linked to Appointment optionally)
CREATE TABLE Visit (
    VisitID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    -- AppointmentID is NULL for unscheduled emergency visits
    AppointmentID INT UNIQUE NULL, 
    VisitDate DATE NOT NULL,
    VisitTime TIME NOT NULL,
    MedicalHistoryUpdate TEXT, -- Represents the updated patient record/history from this visit
    
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

-- 5. Diagnosis Table (Visit -> Diagnosis: 1:M)
CREATE TABLE Diagnosis (
    DiagnosisID INT IDENTITY(1,1) PRIMARY KEY,
    VisitID INT NOT NULL,
    DiagnosisCode VARCHAR(50) NOT NULL,
    Description TEXT,
    
    FOREIGN KEY (VisitID) REFERENCES Visit(VisitID)
);

-- 6. Treatment Table (Visit -> Treatment: 1:M)
CREATE TABLE Treatment (
    TreatmentID INT IDENTITY(1,1) PRIMARY KEY,
    VisitID INT NOT NULL,
    Type VARCHAR(100),
    Description TEXT,
    Cost DECIMAL(10, 2),
    
    FOREIGN KEY (VisitID) REFERENCES Visit(VisitID)
);

-- 7. Bill Table (Visit -> Bill: 1:1)
CREATE TABLE Bill (
    BillID INT IDENTITY(1,1) PRIMARY KEY,
    VisitID INT UNIQUE NOT NULL, -- Each visit creates ONE bill
    BillDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    BalanceDue DECIMAL(10, 2) NOT NULL,
    BillingStatus VARCHAR(50) NOT NULL CHECK (BillingStatus IN ('Unpaid', 'Partially Paid', 'Paid', 'Claim Filed')),
    
    FOREIGN KEY (VisitID) REFERENCES Visit(VisitID)
);

-- 8. Payment Table
CREATE TABLE Payment (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentDate DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod VARCHAR(50),
    PaymentType VARCHAR(50) NOT NULL CHECK (PaymentType IN ('Patient', 'Insurance', 'Installment'))
);

-- 9. BillPayment Table (Junction for M:M relationship: Bill <-> Payment)
CREATE TABLE BillPayment (
    BillID INT NOT NULL,
    PaymentID INT NOT NULL,
    AmountApplied DECIMAL(10, 2) NOT NULL,
    
    PRIMARY KEY (BillID, PaymentID),
    FOREIGN KEY (BillID) REFERENCES Bill(BillID),
    FOREIGN KEY (PaymentID) REFERENCES Payment(PaymentID)
);

-- 10. InsuranceClaim Table (Bill -> Claim: 1:1 optional)
CREATE TABLE InsuranceClaim (
    ClaimID INT IDENTITY(1,1) PRIMARY KEY,
    BillID INT UNIQUE NOT NULL, -- The bill is the basis for ONE claim
    PatientID INT NOT NULL, -- Redundant but useful for query efficiency
    SubmissionDate DATE NOT NULL,
    ClaimStatus VARCHAR(50) NOT NULL CHECK (ClaimStatus IN ('Submitted', 'Pending', 'Approved', 'Denied')),
    
    FOREIGN KEY (BillID) REFERENCES Bill(BillID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);

-- 11. Deductible Table (Linked to bill and patient for payment submission)
CREATE TABLE Deductible (
    DeductibleID INT IDENTITY(1,1) PRIMARY KEY,
    BillID INT UNIQUE NOT NULL, -- Linked to the bill that was paid by insurance
    PatientID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    DueDate DATE,
    DeductibleStatus VARCHAR(50) NOT NULL CHECK (DeductibleStatus IN ('Outstanding', 'Paid', 'Waived')),
    
    FOREIGN KEY (BillID) REFERENCES Bill(BillID),
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);
