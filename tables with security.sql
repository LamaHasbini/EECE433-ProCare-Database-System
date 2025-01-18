-- EMPLOYEE
CREATE TABLE Employee (
    EmployeeID VARCHAR(10) PRIMARY KEY, -- Format: EMP00000
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100) NOT NULL CHECK (Email LIKE '%@procare.com'),
    Address TEXT,
    Salary DECIMAL(10, 2) NOT NULL CHECK (Salary > 0),
    JobTitle VARCHAR(50) NOT NULL
);
COMMENT ON COLUMN Employee.Salary IS 'Employee salary in USD';
CREATE UNIQUE INDEX unique_email_employee ON Employee (LOWER(Email));

-- CLIENT
CREATE TABLE Client (
    ClientID VARCHAR(10) PRIMARY KEY, --CLI00000
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL CHECK (DOB < CURRENT_DATE),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Email VARCHAR(100) NOT NULL CHECK (Email ~ '^[A-Za-z0-9._]+@[A-Za-z0-9.]+\.[A-Za-z]{2,}$')
);
CREATE UNIQUE INDEX unique_email_client ON Client (LOWER(Email));

-- CLIENT PHONE
CREATE TABLE ClientPhoneNumber (
    ClientID VARCHAR(10), 
	CONSTRAINT fk_ClientID FOREIGN KEY (ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    PhoneNumber VARCHAR(15) NOT NULL, -- not unique since can have 2 clients living in same house = same landline
    CONSTRAINT client_phone_id PRIMARY KEY (ClientID, PhoneNumber)
);

-- CLIENT ADDRESS
CREATE TABLE ClientAddress (
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    Address TEXT NOT NULL,
	CONSTRAINT client_address_ID PRIMARY KEY (ClientID, Address)
);

-- MEDICAL RECORDS
CREATE TABLE MedicalRecords (
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    ICDCode VARCHAR(50) NOT NULL CHECK (ICDCode ~ '^[A-Z0-9]{3,4}(\.[A-Z0-9]{1,4})?$'),
    DateCreated DATE DEFAULT CURRENT_DATE NOT NULL CHECK (DateCreated <= CURRENT_DATE),
    ConditionName VARCHAR(100) NOT NULL,
    Description TEXT,
    CONSTRAINT medical_record_id PRIMARY KEY (ClientID, ICDCode)
);

-- INSURANCE PLAN
CREATE TABLE InsurancePlan (
    InsurancePlanName VARCHAR(100) PRIMARY KEY,
    PlanType VARCHAR(50) NOT NULL,
    Description TEXT,
    CoverageLevel VARCHAR(50) NOT NULL,
    Premium DECIMAL(10, 2) NOT NULL CHECK (Premium > 0),
    Deductible DECIMAL(10, 2) NOT NULL CHECK (Deductible >= 0)
);

-- CLAIM REQUESTS
CREATE TABLE RequestClaim (
    EmployeeID VARCHAR(10),
	CONSTRAINT fk_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE,
    ClientID VARCHAR(10),
	CONSTRAINT fk_CLientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DateCreated DATE DEFAULT CURRENT_DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    ApprovalStatus VARCHAR(50) DEFAULT 'Pending' NOT NULL,
    DecisionDate DATE,
    CONSTRAINT request_id PRIMARY KEY (EmployeeID, ClientID, DateCreated)
);

-- PAYS
CREATE TABLE Pays (
    EmployeeID VARCHAR(10),
	CONSTRAINT fk_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE SET NULL ON UPDATE CASCADE,
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    Date DATE DEFAULT CURRENT_DATE NOT NULL CHECK (Date <= CURRENT_DATE),
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    Purpose TEXT,
    CONSTRAINT payment_id PRIMARY KEY (EmployeeID, ClientID, Date)
);

-- EMPLOYEE DEPENDENT
CREATE TABLE EmployeeDependent (
    EmployeeID VARCHAR(10),
	CONSTRAINT fk_EmployeeID FOREIGN KEY(EmployeeID) REFERENCES Employee(EmployeeID) ON DELETE CASCADE ON UPDATE CASCADE,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) DEFAULT '' NOT NULL, -- will need for PK so not null
    LastName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL CHECK (DOB < CURRENT_DATE),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')), 
    Relationship VARCHAR(50) NOT NULL,
    CONSTRAINT employee_dependent_id PRIMARY KEY (EmployeeID, FirstName, MiddleName, LastName)
);

-- CLIENT DEPENDENT
CREATE TABLE ClientDependent (
    ClientID VARCHAR(10),
	CONSTRAINT fk_ClientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50) DEFAULT '' NOT NULL, -- will need for PK so not null
    LastName VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL CHECK (DOB < CURRENT_DATE),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')), 
    Relationship VARCHAR(50) NOT NULL,
    CONSTRAINT client_dependent_id PRIMARY KEY (ClientID, FirstName, MiddleName, LastName)
);

-- HEALTHCARE PROVIDERS
CREATE TABLE HealthcareProvider (
    HealthcareProviderID VARCHAR(10) PRIMARY KEY, -- Format: HCP00000
    ProviderName VARCHAR(50) NOT NULL,
    ProviderType VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL,
    Address TEXT NOT NULL
);

-- DOCTOR
CREATE TABLE Doctor (
    DoctorID VARCHAR(10) PRIMARY KEY, -- Format: DOC00000
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL CHECK (Email ~ '^[A-Za-z0-9._]+@[A-Za-z0-9.]+\.[A-Za-z]{2,}$'),
    PhoneNumber VARCHAR(15) UNIQUE,
    SupervisorHealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_healthcare_provider_id FOREIGN KEY(SupervisorHealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE UNIQUE INDEX unique_email_doctor ON Doctor (LOWER(Email));

-- DOCTOR SPECIALTY
CREATE TABLE DoctorSpecialization (
    DoctorID VARCHAR(10),
	CONSTRAINT fk_DoctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE ON UPDATE CASCADE,
    Specialization VARCHAR(50) NOT NULL,
    CONSTRAINT specialization_id PRIMARY KEY (DoctorID, Specialization)
);

-- EMPLOY DOCTORS
CREATE TABLE EmployDoctor (
    HealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_healthcareProviderID FOREIGN KEY(HealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID VARCHAR(10),
	CONSTRAINT fk_DoctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT employ_doctor_id PRIMARY KEY (HealthcareProviderID, DoctorID)
);

-- AGENT
CREATE TABLE Agent (
    AgentID VARCHAR(10) PRIMARY KEY, -- Format: AGT00000
    AgentName VARCHAR(100) NOT NULL,
    CommissionRate DECIMAL(5, 2) NOT NULL CHECK (CommissionRate >= 0), 
    Email VARCHAR(100) NOT NULL CHECK (Email ~ '^[A-Za-z0-9._]+@[A-Za-z0-9.]+\.[A-Za-z]{2,}$'),
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE NOT NULL
);
CREATE UNIQUE INDEX unique_email_agent ON Agent (LOWER(Email));

-- POLICIES
CREATE TABLE Policy (
    PolicyNumber VARCHAR(10) PRIMARY KEY, -- Format: PNM00000
    ExactCost DECIMAL(10, 2) CHECK (ExactCost >= 0) NOT NULL,
    StartDate DATE NOT NULL DEFAULT CURRENT_DATE,
    EndDate DATE NOT NULL,
    InsurancePlanName VARCHAR(100),
	CONSTRAINT fk_insurancePlanName FOREIGN KEY(InsurancePlanName) REFERENCES InsurancePlan(InsurancePlanName) 
	ON DELETE CASCADE ON UPDATE CASCADE
);

-- COVERS 
CREATE TABLE Covers (
    InsurancePlanName VARCHAR(100),
	CONSTRAINT fk_InsurancePlanName FOREIGN KEY(InsurancePlanName) REFERENCES InsurancePlan(InsurancePlanName) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    HealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_HealthcareProviderID FOREIGN KEY(HealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT coverage_id PRIMARY KEY (InsurancePlanName, HealthcareProviderID)
);

-- MEDICAL SERVICES
CREATE TABLE MedicalService (
    ServiceID VARCHAR(10) PRIMARY KEY, -- Format: MDS00000
    ServiceName VARCHAR(100) NOT NULL,
    Description TEXT
);

-- PROVIDE
CREATE TABLE Provide (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID VARCHAR(10),
	CONSTRAINT fk_doctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE SET NULL,
    ServiceID VARCHAR(10),
	CONSTRAINT fk_serviceID FOREIGN KEY(ServiceID) REFERENCES MedicalService(ServiceID) ON DELETE SET NULL,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    ServiceCost DECIMAL(10, 2) CHECK (ServiceCost >= 0) NOT NULL,
    CONSTRAINT provided_service_id PRIMARY KEY (ClientID, DoctorID, ServiceID, Date)
);

-- DOCTOR REQUEST
CREATE TABLE RequestDoctor (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(CLientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    DoctorID VARCHAR(10),
	CONSTRAINT fk_doctorID FOREIGN KEY(DoctorID) REFERENCES Doctor(DoctorID) ON DELETE CASCADE ON UPDATE CASCADE,
    HealthcareProviderID VARCHAR(10),
	CONSTRAINT fk_healthcareProviderID FOREIGN KEY(HealthcareProviderID) REFERENCES HealthcareProvider(HealthcareProviderID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT doctor_request_id PRIMARY KEY (ClientID, DoctorID, HealthcareProviderID, Date)
);

-- DOCTOR REFER
CREATE TABLE Refer (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    ReferringDoctorID VARCHAR(10),
	CONSTRAINT fk_referringDoctorID FOREIGN KEY(ReferringDoctorID) REFERENCES Doctor(DoctorID) 
	ON DELETE SET NULL ON UPDATE CASCADE,
    ReferredDoctorID VARCHAR(10),
	CONSTRAINT fk_referredDoctorID FOREIGN KEY(ReferredDoctorID) REFERENCES Doctor(DoctorID) 
	ON DELETE CASCADE ON UPDATE CASCADE,
    Date DATE NOT NULL DEFAULT CURRENT_DATE,
    Reason TEXT,
    CONSTRAINT referal_id PRIMARY KEY (ClientID, ReferringDoctorID, ReferredDoctorID, Date)
);

-- SELL
CREATE TABLE Sell (
    ClientID VARCHAR(10),
	CONSTRAINT fk_clientID FOREIGN KEY(ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE ON UPDATE CASCADE,
    PolicyNumber VARCHAR(10),
	CONSTRAINT fk_policyNumber FOREIGN KEY(PolicyNumber) REFERENCES Policy(PolicyNumber) ON DELETE CASCADE ON UPDATE CASCADE,
    AgentID VARCHAR(10),
	CONSTRAINT fk_agentID FOREIGN KEY(AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT sell_transaction_id PRIMARY KEY (ClientID, PolicyNumber, AgentID)
);

-- INSERT STATEMENTS
INSERT INTO Employee (EmployeeID, FirstName, MiddleName, LastName, PhoneNumber, Email, Address, Salary, JobTitle) VALUES
('EMP00001', 'Omar', 'Khaled', 'Haddad', '712345678', 'omar.haddad@procare.com', '12 Main St, Beirut', 1500, 'Software Developer'),
('EMP00002', 'Layla', 'Samir', 'Kassem', '703456789', 'layla.kassem@procare.com', '34 Elm St, Tripoli', 1800, 'Claims Manager'),
('EMP00003', 'Ziad', 'Rami', 'Nassar', '714567890', 'ziad.nassar@procare.com', '56 Cedar St, Sidon', 2000, 'Marketing Specialist'),
('EMP00004', 'Hana', 'Nour', 'Jebril', '705678901', 'hana.jebril@procare.com', '78 Olive St, Tyre', 1700, 'HR Coordinator'),
('EMP00005', 'Fadi', 'Joe', 'Salameh', '716789012', 'fadi.salameh@procare.com', '90 Palm St, Baabda', 1600, 'Claims Specialist'),
('EMP00006', 'Rania', 'Tarek', 'Matar', '707890123', 'rania.matar@procare.com', '23 Jasmine St, Zahle', 1900, 'UX Designer'),
('EMP00007', 'Karim', 'Ali', 'Issa', '718901234', 'karim.boukhallil@procare.com', '45 Rose St, Byblos', 2100, 'Sales Executive'),
('EMP00008', 'Dalia', 'Ziad', 'Sayegh', '709012345', 'dalia.sayegh@procare.com', '67 Orchid St, Jounieh', 1750, 'Customer Service Rep'),
('EMP00009', 'Noor', 'Fadi', 'Ghazal', '718912345', 'noor.ghazal@procare.com', '89 Pinetree St, Beirut', 2200, 'Account Manager'),
('EMP00010', 'Sami', 'Omar', 'Shams', '712345670', 'sami.shams@procare.com', '44 Sunset Ave, Tripoli', 1850, 'Financial Coordinator');
UPDATE Employee
SET LastName = 'Bou Khalil'
WHERE EmployeeID = 'EMP00007';  

INSERT INTO Client (ClientID, FirstName, MiddleName, LastName, DOB, Gender, Email) VALUES
('CLI00001', 'Ali', 'Jamal', 'Hajj', '1985-02-14', 'M', 'ali.hajj@email.com'),
('CLI00002', 'Lina', 'Samir', 'Karam', '1990-08-25', 'F', 'lina.karam@email.com'),
('CLI00003', 'Omar', 'Fouad', 'Nasr', '1987-11-03', 'M', 'omar.nasr@email.com'),
('CLI00004', 'Nour', 'Rami', 'Daher', '1992-07-19', 'F', 'nour.daher@email.com'),
('CLI00005', 'Rami', 'Khaled', 'Saab', '1983-05-30', 'M', 'rami.saab@email.com'),
('CLI00006', 'Hiba', 'Ahmad', 'Sayegh', '1988-12-12', 'F', 'hiba.sayegh@email.com'),
('CLI00007', 'Samir', 'Fadi', 'Youssef', '1991-01-22', 'M', 'samir.youssef@email.com'),
('CLI00008', 'Layal', 'Tarek', 'Khalil', '1989-04-15', 'F', 'layal.khalil@email.com'),
('CLI00009', 'Karim', 'Walid', 'Assaf', '1993-09-17', 'M', 'karim.assaf@email.com'),
('CLI00010', 'Nadine', 'Ziad', 'Jaber', '1995-03-08', 'F', 'nadine.jaber@email.com');

INSERT INTO ClientPhoneNumber (ClientID, PhoneNumber) VALUES
('CLI00001', '71234567'),
('CLI00001', '01860123'),
('CLI00002', '70345678'),
('CLI00003', '71456789'),
('CLI00004', '70567890'),
('CLI00005', '71678901'),
('CLI00006', '70789012'),
('CLI00007', '71890123'),
('CLI00008', '70901234'),
('CLI00009', '71234567'),
('CLI00010', '70345678');

INSERT INTO ClientAddress (ClientID, Address) VALUES
('CLI00001', '15 Cedar Rd, Beirut'),
('CLI00002', '28 Maple St, Tripoli'),
('CLI00003', '34 Pine Ave, Sidon'),
('CLI00004', '56 Jasmine St, Tyre'),
('CLI00004', 'Banque du Liban, Riad El Solh, Beirut'),
('CLI00005', '78 Olive Rd, Zahle'),
('CLI00006', '90 Palm Ave, Baabda'),
('CLI00007', '12 Cedar Blvd, Byblos'),
('CLI00008', '23 Rose Ln, Jounieh'),
('CLI00009', '45 Oak St, Nabatieh'),
('CLI00010', '67 Birch Ave, Aley');

INSERT INTO MedicalRecords (ClientID, ICDCode, DateCreated, ConditionName, Description) VALUES
('CLI00001', 'A01.0', '2024-01-15', 'Typhoid Fever', 'Acute bacterial infection'),
('CLI00002', 'J20.9', '2023-11-20', 'Acute Bronchitis', 'Inflammation of the bronchial tubes'),
('CLI00003', 'E11.9', '2024-02-03', 'Type 2 Diabetes', 'Chronic condition affecting metabolism'),
('CLI00004', 'I10', '2023-05-18', 'Essential Hypertension', 'High blood pressure'),
('CLI00005', 'K21.9', '2023-08-22', 'Gastroesophageal Reflux', 'Acid reflux in the esophagus'),
('CLI00006', 'L50.0', '2024-03-10', 'Urticaria', 'Condition with red, itchy welts'),
('CLI00007', 'M54.5', '2024-06-15', 'Low Back Pain', 'Pain in the lower back region'),
('CLI00008', 'F32.9', '2023-09-12', 'Major Depressive Disorder', 'Persistent feeling of sadness'),
('CLI00009', 'N39.0', '2024-04-25', 'Urinary Tract Infection', 'Bacterial infection in the urinary tract'),
('CLI00010', 'H52.4', '2023-12-30', 'Presbyopia', 'Age-related difficulty in seeing close objects');

INSERT INTO InsurancePlan (InsurancePlanName, PlanType, Description, CoverageLevel, Premium, Deductible) VALUES
('Basic Health Plan', 'HMO', 'Provides comprehensive health coverage', 'Silver', 200, 1000),
('Flexible Care Plan', 'PPO', 'Offers flexibility in choosing healthcare providers', 'Gold', 300, 500),
('Comprehensive Plan', 'POS', 'Combines HMO and PPO features for more options', 'Platinum', 350, 300),
('Essential Coverage', 'EPO', 'Covers essential health benefits with no out-of-network coverage', 'Bronze', 180, 1500),
('High Deductible Health Plan', 'HDHP', 'Lower premiums with higher deductibles for catastrophic coverage', 'Bronze', 150, 2500),
('Family Protection Plan', 'HMO', 'Family-focused plan with low out-of-pocket costs', 'Silver', 250, 750),
('Premium Wellness Plan', 'PPO', 'High-level coverage with extensive provider network', 'Platinum', 400, 250),
('Student Health Plan', 'EPO', 'Designed for students, with essential coverage', 'Gold', 150, 1200),
('Senior Advantage Plan', 'HMO', 'Tailored for seniors, includes wellness programs', 'Gold', 220, 800),
('Preventive Care Plan', 'POS', 'Focused on preventive care and routine checkups', 'Silver', 170, 1000);

INSERT INTO RequestClaim (EmployeeID, ClientID, DateCreated, Amount, ApprovalStatus, DecisionDate) VALUES
('EMP00005', 'CLI00001', '2024-01-05', 250, 'Approved', '2024-01-10'),
('EMP00002', 'CLI00002', '2024-02-12', 500, 'Approved', '2024-02-15'),
('EMP00002', 'CLI00003', '2024-03-01', 300, 'Pending', NULL),
('EMP00002', 'CLI00004', '2024-03-18', 450, 'Approved', '2024-03-20'),
('EMP00005', 'CLI00005', '2024-04-05', 600, 'Denied', '2024-04-08'),
('EMP00002', 'CLI00006', '2024-04-20', 400, 'Approved', '2024-04-25'),
('EMP00005', 'CLI00007', '2024-05-10', 700, 'Pending', NULL),
('EMP00005', 'CLI00008', '2024-06-02', 550, 'Approved', '2024-06-05'),
('EMP00002', 'CLI00009', '2024-06-15', 250, 'Denied', '2024-06-18'),
('EMP00002', 'CLI00010', '2024-07-01', 650, 'Approved', '2024-07-10');

INSERT INTO Pays (EmployeeID, ClientID, Date, Amount, Purpose) VALUES
('EMP00008', 'CLI00001', '2024-01-10', 500, 'Service Fees'),
('EMP00009', 'CLI00002', '2024-02-15', 750, 'Claims Processing Fee'),
('EMP00010', 'CLI00003', '2024-03-05', 300, 'Policy Issuance Fee'),
('EMP00010', 'CLI00004', '2024-03-20', 600, 'Annual Premium Payment'),
('EMP00009', 'CLI00005', '2024-04-08', 450, 'Risk Assessment Fee'),
('EMP00008', 'CLI00006', '2024-04-25', 800, 'Insurance Consultation Fee'),
('EMP00008', 'CLI00007', '2024-05-12', 700, 'Claims Adjustment Fee'),
('EMP00008', 'CLI00008', '2024-06-01', 400, 'Coverage Modification Fee'),
('EMP00010', 'CLI00009', '2024-06-18', 550, 'Insurance Renewal Fee'),
('EMP00009', 'CLI00010', '2024-07-10', 650, 'Services Fees');

INSERT INTO EmployeeDependent (EmployeeID, FirstName, MiddleName, LastName, DOB, Gender, Relationship) VALUES
('EMP00001', 'Khaled', 'Omar', 'Haddad', '2010-05-15', 'M', 'Son'),
('EMP00002', 'Tia', 'Hadi', 'Saab', '2012-08-20', 'M', 'Son'),
('EMP00003', 'Rami', 'Ziad', 'Nassar', '2008-03-12', 'M', 'Son'),
('EMP00004', 'Latifa', 'Abed', 'Bakri', '1957-07-25', 'F', 'Parent'),
('EMP00005', 'Anthony', 'Fadi', 'Salameh', '2011-09-30', 'M', 'Son'),
('EMP00006', 'Omar', 'Sami', 'Mansour', '2013-06-10', 'M', 'Son'),
('EMP00007', 'Dalia', 'Karim', 'Issa', '2009-11-05', 'F', 'Daughter'),
('EMP00008', 'Ziad', 'Jad', 'Sabbagh', '2014-02-28', 'M', 'Son'),
('EMP00009', 'Fadi', 'Ayman', 'Ghazal', '1960-04-14', 'M', 'Parent'),
('EMP00010', 'Yara', 'Sami', 'Shams', '2012-12-18', 'F', 'Daughter');

UPDATE EmployeeDependent
SET LastName = 'Bou Khalil'
WHERE EmployeeID = 'EMP00007'; 

INSERT INTO ClientDependent (ClientID, FirstName, MiddleName, LastName, DOB, Gender, Relationship) VALUES
('CLI00001', 'Cynthia', 'Ali', 'Hajj', '2000-01-01', 'F', 'Daughter'),
('CLI00001', 'Dana', 'Ali', 'Hajj', '2002-02-02', 'F', 'Daughter'),
('CLI00003', 'Ahmad', 'Omar', 'Nasr', '2001-03-03', 'M', 'Son'),
('CLI00005', 'Elie', 'Rami', 'Saab', '2003-04-04', 'M', 'Son'),
('CLI00007', 'Sam', 'Samir', 'Youssef', '2004-05-05', 'M', 'Son'),
('CLI00007', 'Layal', 'Samir', 'Youssef', '2006-06-06', 'F', 'Daughter'),
('CLI00010', 'Abed', 'Tarek', 'Bader', '2002-07-07', 'M', 'Son'),
('CLI00004', 'Ghazi', 'Saad', 'Batrouni', '2001-08-08', 'M', 'Son'),
('CLI00006', 'Nada', 'Dani', 'Kanj', '2003-09-09', 'F', 'Daughter'),
('CLI00006', 'Kamal', 'Dani', 'Kanj', '2005-10-10', 'M', 'Son');

INSERT INTO HealthcareProvider (HealthcareProviderID, ProviderName, ProviderType, PhoneNumber, Address) VALUES
('HCP00001', 'HealthFirst Clinic', 'Clinic', '01234567123', 'Wellness St, Ashrafieh, Beirut'),
('HCP00002', 'CarePlus Hospital', 'Hospital', '01345678456', 'Care Rd, Hamra, Beirut'),
('HCP00003', 'MediQuick Pharmacy', 'Pharmacy', '01456789789', 'Rx Ave, Jdeideh, Beirut'),
('HCP00004', 'Family Health Center', 'Clinic', '01567890101', 'Family Ln, Tripoli'),
('HCP00005', 'Wellness Medical Group', 'Specialist Center', '01678901202', 'Health Dr, Sidon'),
('HCP00006', 'Emergency Care Unit', 'Hospital', '01789012303', 'Urgent St, Zahle'),
('HCP00007', 'Pediatric Specialists', 'Specialist Center', '01890123404', 'Kids Blvd, Byblos'),
('HCP00008', 'Senior Health Services', 'Home Care', '01901234505', 'Elder St, Baabda'),
('HCP00009', 'Dental Wellness Center', 'Dental Clinic', '01012345606', 'Smile St, Bekaa'),
('HCP00010', 'Vision Care Center', 'Specialist Center', '01123456707', 'Sight St, Nabatieh');

INSERT INTO Doctor (DoctorID, FirstName, MiddleName, LastName, Email, PhoneNumber, SupervisorHealthcareProviderID) VALUES
('DOC00001', 'Ahmad', 'Khaled', 'Khoury', 'ahmad.khoury@email.com', '03456789', 'HCP00001'),
('DOC00002', 'Layla', 'Samir', 'Kabbani', 'layla.hariri@email.com', '03567890', 'HCP00002'),
('DOC00003', 'Ziad', 'Omar', 'Rahme', 'ziad.rahme@email.com', '03678901', 'HCP00003'),
('DOC00004', 'Rania', 'Fouad', 'Jabbour', 'rania.jabbour@email.com', '03789012', 'HCP00004'),
('DOC00005', 'Samir', 'Jamil', 'Fahed', 'samir.fahed@email.com', '03890123', 'HCP00005'),
('DOC00006', 'Dalia', 'Ziad', 'Ghanem', 'dalia.ghanem@email.com', '03901234', 'HCP00006'),
('DOC00007', 'Omar', 'Tariq', 'Husseini', 'omar.husseini@email.com', '03012345', 'HCP00007'),
('DOC00008', 'Nour', 'Sami', 'Itani', 'nour.aoun@email.com', '03123456', 'HCP00008'),
('DOC00009', 'Hiba', 'Rami', 'Kassem', 'hiba.kassem@email.com', '03234567', 'HCP00009'),
('DOC00010', 'Yara', 'Ali', 'Najm', 'yara.najm@email.com', '03345678', 'HCP00010');

INSERT INTO DoctorSpecialization (DoctorID, Specialization) VALUES
('DOC00001', 'Cardiology'),
('DOC00001', 'Internal Medicine'),
('DOC00002', 'Pediatrics'),
('DOC00003', 'Orthopedics'),
('DOC00003', 'Sports Medicine'),
('DOC00004', 'Obstetrics'),
('DOC00004', 'Gynecology'),
('DOC00005', 'Dermatology'),
('DOC00006', 'Psychiatry'),
('DOC00006', 'Neurology'),
('DOC00007', 'General Surgery'),
('DOC00008', 'Family Medicine'),
('DOC00009', 'Dentistry'),
('DOC00010', 'Ophthalmology');

INSERT INTO EmployDoctor (HealthcareProviderID, DoctorID) VALUES
('HCP00001', 'DOC00001'),
('HCP00001', 'DOC00005'),
('HCP00002', 'DOC00002'),
('HCP00003', 'DOC00003'),
('HCP00004', 'DOC00004'),
('HCP00005', 'DOC00006'),
('HCP00006', 'DOC00007'),
('HCP00007', 'DOC00008'),
('HCP00008', 'DOC00009'),
('HCP00009', 'DOC00010');

INSERT INTO Agent (AgentID, AgentName, CommissionRate, Email, LicenseNumber, PhoneNumber) VALUES
('AGT00001', 'Rami Hbeish', 5.00, 'rami.h@email.com', 'L001', '71234567'),
('AGT00002', 'Nour Youssef', 6.00, 'nour.y@email.com', 'L002', '71234568'),
('AGT00003', 'Leila Bahji', 4.00, 'leila.b@email.com', 'L003', '71234569'),
('AGT00004', 'Jamil Akl', 7.00, 'jamil.a@email.com', 'L004', '71234570'),
('AGT00005', 'Mira Khamis', 5.00, 'mira.k@email.com', 'L005', '71234571'),
('AGT00006', 'Sami Zaatari', 6.00, 'sami.z@email.com', 'L006', '71234572'),
('AGT00007', 'Nadine Qassem', 5.00, 'nadine.q@email.com', 'L007', '71234573'),
('AGT00008', 'Tarek Soufi', 4.00, 'tarek.s@email.com', 'L008', '71234574'),
('AGT00009', 'Hala Chams', 5.00, 'hala.c@email.com', 'L009', '71234575'),
('AGT00010', 'Ziad Dabbous', 6.00, 'ziad.d@email.com', 'L010', '71234576');

INSERT INTO Policy (PolicyNumber, ExactCost, StartDate, EndDate, InsurancePlanName) VALUES
('PNM00001', 500.00, '2024-01-01', '2024-12-31', 'Basic Health Plan'),
('PNM00002', 750.00, '2024-02-01', '2025-01-31', 'Flexible Care Plan'),
('PNM00003', 1200.00, '2024-03-01', '2025-02-28', 'Comprehensive Plan'),
('PNM00004', 400.00, '2024-04-01', '2024-10-01', 'Essential Coverage'),
('PNM00005', 1000.00, '2024-05-01', '2025-04-30', 'High Deductible Health Plan'),
('PNM00006', 600.00, '2024-06-01', '2025-05-31', 'Family Protection Plan'),
('PNM00007', 800.00, '2024-07-01', '2025-06-30', 'Premium Wellness Plan'),
('PNM00008', 350.00, '2024-08-01', '2024-11-30', 'Student Health Plan'),
('PNM00009', 550.00, '2024-09-01', '2025-08-31', 'Senior Advantage Plan'),
('PNM00010', 450.00, '2024-10-01', '2025-09-30', 'Preventive Care Plan');

INSERT INTO Covers (InsurancePlanName, HealthcareProviderID) VALUES
('Basic Health Plan', 'HCP00001'),
('Flexible Care Plan', 'HCP00001'),
('Essential Coverage', 'HCP00002'),
('Comprehensive Plan', 'HCP00003'),
('Essential Coverage', 'HCP00004'),
('High Deductible Health Plan', 'HCP00005'),
('Family Protection Plan', 'HCP00006'),
('Premium Wellness Plan', 'HCP00007'),
('Student Health Plan', 'HCP00008'),
('Senior Advantage Plan', 'HCP00009'),
('Preventive Care Plan', 'HCP00010'),
('Premium Wellness Plan', 'HCP00010');

INSERT INTO MedicalService (ServiceID, ServiceName, Description) VALUES
('MDS00001', 'General Check-up', 'Routine examination to assess overall health.'),
('MDS00002', 'Blood Test', 'Laboratory analysis to evaluate blood conditions.'),
('MDS00003', 'X-ray', 'Imaging technique to view bones and structures.'),
('MDS00004', 'MRI Scan', 'Advanced imaging for detailed body analysis.'),
('MDS00005', 'Physical Therapy', 'Rehabilitation treatment to improve mobility.'),
('MDS00006', 'Vaccination', 'Immunization to prevent diseases.'),
('MDS00007', 'Allergy Testing', 'Tests to identify specific allergies.'),
('MDS00008', 'Ultrasound', 'Imaging technique using sound waves for diagnosis.'),
('MDS00009', 'Surgical Consultation', 'Evaluation and planning for potential surgery.'),
('MDS00010', 'Dermatology Services', 'Treatment for skin-related issues.');

INSERT INTO Provide (ClientID, DoctorID, ServiceID, Date, ServiceCost) VALUES
('CLI00005', 'DOC00003', 'MDS00001', '2024-10-01', 100),
('CLI00002', 'DOC00007', 'MDS00006', '2024-10-02', 150),
('CLI00009', 'DOC00001', 'MDS00004', '2024-10-03', 200),
('CLI00001', 'DOC00008', 'MDS00002', '2024-10-04', 400),
('CLI00010', 'DOC00005', 'MDS00007', '2024-10-05', 250),
('CLI00004', 'DOC00002', 'MDS00005', '2024-10-06', 80),
('CLI00006', 'DOC00009', 'MDS00008', '2024-10-07', 120),
('CLI00003', 'DOC00010', 'MDS00009', '2024-10-08', 300),
('CLI00008', 'DOC00006', 'MDS00003', '2024-10-09', 500),
('CLI00007', 'DOC00004', 'MDS00010', '2024-10-10', 90);

INSERT INTO RequestDoctor (ClientID, DoctorID, HealthcareProviderID, Date) VALUES
('CLI00001', 'DOC00001', 'HCP00001', '2024-10-01'),
('CLI00002', 'DOC00002', 'HCP00002', '2024-10-02'),
('CLI00003', 'DOC00003', 'HCP00003', '2024-10-03'),
('CLI00004', 'DOC00004', 'HCP00004', '2024-10-04'),
('CLI00005', 'DOC00005', 'HCP00005', '2024-10-05'),
('CLI00006', 'DOC00006', 'HCP00006', '2024-10-06'),
('CLI00007', 'DOC00007', 'HCP00007', '2024-10-07'),
('CLI00008', 'DOC00008', 'HCP00008', '2024-10-08'),
('CLI00009', 'DOC00009', 'HCP00009', '2024-10-09'),
('CLI00010', 'DOC00010', 'HCP00010', '2024-10-10');

INSERT INTO Refer (ClientID, ReferringDoctorID, ReferredDoctorID, Date, Reason) VALUES
('CLI00001', 'DOC00001', 'DOC00002', '2024-10-01', 'Specialist Consultation'),
('CLI00002', 'DOC00002', 'DOC00003', '2024-10-02', 'Further Evaluation'),
('CLI00003', 'DOC00003', 'DOC00004', '2024-10-03', 'Surgical Assessment'),
('CLI00004', 'DOC00004', 'DOC00005', '2024-10-04', 'Dermatological Concern'),
('CLI00005', 'DOC00005', 'DOC00006', '2024-10-05', 'Mental Health Evaluation'),
('CLI00006', 'DOC00006', 'DOC00007', '2024-10-06', 'Neurological Assessment'),
('CLI00007', 'DOC00007', 'DOC00008', '2024-10-07', 'Family Medicine Follow-up'),
('CLI00008', 'DOC00008', 'DOC00009', '2024-10-08', 'Dental Issues'),
('CLI00009', 'DOC00009', 'DOC00010', '2024-10-09', 'Vision Check'),
('CLI00010', 'DOC00010', 'DOC00001', '2024-10-10', 'General Health Review');

INSERT INTO Sell (ClientID, PolicyNumber, AgentID) VALUES
('CLI00001', 'PNM00005', 'AGT00002'),
('CLI00002', 'PNM00010', 'AGT00002'),
('CLI00003', 'PNM00001', 'AGT00001'),
('CLI00004', 'PNM00006', 'AGT00004'),
('CLI00005', 'PNM00002', 'AGT00005'),
('CLI00006', 'PNM00007', 'AGT00005'),
('CLI00007', 'PNM00003', 'AGT00007'),
('CLI00008', 'PNM00009', 'AGT00008'),
('CLI00009', 'PNM00004', 'AGT00009'),
('CLI00010', 'PNM00008', 'AGT00010');

SELECT * FROM Employee;
SELECT * FROM Client;
SELECT * FROM ClientPhoneNumber;
SELECT * FROM ClientAddress;
SELECT * FROM MedicalRecords;
SELECT * FROM InsurancePlan;
SELECT * FROM RequestClaim;
SELECT * FROM Pays;
SELECT * FROM EmployeeDependent;
SELECT * FROM ClientDependent;
SELECT * FROM HealthcareProvider;
SELECT * FROM Doctor;
SELECT * FROM DoctorSpecialization;
SELECT * FROM EmployDoctor;
SELECT * FROM Agent;
SELECT * FROM Policy;
SELECT * FROM Covers;
SELECT * FROM MedicalService;
SELECT * FROM Provide;
SELECT * FROM RequestDoctor;
SELECT * FROM Refer;
SELECT * FROM Sell;

-- COMPLEX QUERIES
-- top 5 monthly revenue by service in a specific healthcare provider
DROP VIEW IF EXISTS Top5MonthlyServiceSummary;
CREATE VIEW Top5MonthlyServiceSummary AS
WITH RankedServices AS (
	SELECT ed.HealthcareProviderId,
	       ms.ServiceID,
	       ms.ServiceName,
	       CONCAT(
	           EXTRACT(YEAR FROM pr.Date)::TEXT, '-', 
	           LPAD(EXTRACT(MONTH FROM pr.Date)::TEXT, 2, '0')
	       ) AS ServicePeriod,
	       COUNT(*) AS TotalUses,
	       SUM(pr.ServiceCost) AS TotalGenerated,
	       ROW_NUMBER() OVER (
	           PARTITION BY ed.HealthcareProviderId, EXTRACT(YEAR FROM pr.Date), EXTRACT(MONTH FROM pr.Date)
	           ORDER BY SUM(pr.ServiceCost) DESC
	       ) AS Rank
	FROM Provide pr
	JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
	JOIN EmployDoctor ed ON pr.DoctorID = ed.DoctorID
	GROUP BY ed.HealthcareProviderId, ms.ServiceID, ms.ServiceName, EXTRACT(YEAR FROM pr.Date), EXTRACT(MONTH FROM pr.Date)
)

SELECT HealthcareProviderID, ServiceID, ServiceName, ServicePeriod, TotalUses, TotalGenerated
FROM RankedServices
WHERE Rank <= 5
ORDER BY HealthcareProviderID, ServicePeriod, TotalGenerated DESC;

SELECT * FROM Top5MonthlyServiceSummary;

INSERT INTO Provide (ClientID, DoctorID, ServiceID, Date, ServiceCost) VALUES
('CLI00005', 'DOC00001', 'MDS00001', '2024-10-01', 100),
('CLI00002', 'DOC00001', 'MDS00010', '2024-10-02', 150),
('CLI00009', 'DOC00001', 'MDS00004', '2024-10-04', 200),
('CLI00001', 'DOC00005', 'MDS00002', '2024-10-04', 400),
('CLI00010', 'DOC00005', 'MDS00009', '2024-10-05', 250),
('CLI00004', 'DOC00001', 'MDS00005', '2024-10-06', 80),
('CLI00006', 'DOC00001', 'MDS00008', '2024-10-07', 120),
('CLI00008', 'DOC00005', 'MDS00003', '2024-10-09', 500);

-- the distribution of clients in the hospitals based on the insurance plans level
SELECT 
    H.HealthcareProviderID, 
    H.ProviderName AS HealthcareProviderName, 
    IP.CoverageLevel AS InsurancePlanLevel, 
    COUNT(DISTINCT C.ClientID) AS ClientCount  
FROM Provide P 
JOIN Client C ON P.ClientID = C.ClientID 
JOIN Sell S ON C.ClientID = S.ClientID 
JOIN Policy L ON S.PolicyNumber = L.PolicyNumber 
JOIN InsurancePlan IP ON L.InsurancePlanName = IP.InsurancePlanName 
JOIN EmployDoctor ED ON P.DoctorID = ED.DoctorID 
JOIN HealthcareProvider H ON ED.HealthcareProviderID = H.HealthcareProviderID 
GROUP BY H.HealthcareProviderID, H.ProviderName, IP.CoverageLevel 
ORDER BY H.HealthcareProviderID, IP.CoverageLevel;

-- the spendings of the clients in different healthcare providers
DROP VIEW IF EXISTS ClientServicePaymentsView;
CREATE VIEW ClientServicePaymentsView AS 
WITH ClientServicePayments AS ( 
	SELECT 
        H.HealthcareProviderID, 
        H.ProviderName AS HealthcareProviderName, 
        C.ClientID, 
        CONCAT(C.FirstName, ' ', COALESCE(C.MiddleName, ''), ' ', C.LastName) AS ClientFullName, 
        MS.ServiceID, 
        MS.ServiceName, 
        DATE(P.Date) AS PaymentDate, 
        TO_CHAR(P.Date, 'YYYY-MM') AS RevenueMonth, 
        P.ServiceCost AS PaymentAmount 
    FROM Provide P 
    JOIN Client C ON P.ClientID = C.ClientID
    JOIN Doctor D ON P.DoctorID = D.DoctorID 
    JOIN EmployDoctor ED ON D.DoctorID = ED.DoctorID 
    JOIN HealthcareProvider H ON ED.HealthcareProviderID = H.HealthcareProviderID 
    JOIN MedicalService MS ON P.ServiceID = MS.ServiceID 
)
SELECT 
    HealthcareProviderID, 
    HealthcareProviderName, 
    ClientID, 
    ClientFullName, 
    ServiceID, 
    ServiceName, 
    PaymentDate, 
    RevenueMonth, 
    PaymentAmount
FROM ClientServicePayments;
SELECT 
    HealthcareProviderID, 
    HealthcareProviderName, 
    ClientID, 
    ClientFullName, 
    ServiceID, 
    ServiceName, 
    PaymentDate, 
    RevenueMonth, 
    PaymentAmount
FROM ClientServicePaymentsView 
ORDER BY PaymentDate, ClientFullName, ServiceName;

-- fraud claims
DROP VIEW IF EXISTS ClientSummaryFiltered;
CREATE VIEW ClientSummaryFiltered AS
SELECT 
    rc.ClientID,
    CONCAT(c.FirstName, ' ', COALESCE(c.MiddleName, ''), ' ', c.LastName) AS ClientName,
    COUNT(*) AS TotalClaims,
    SUM(rc.Amount) AS TotalAmount,
    ROUND(SUM(CASE WHEN rc.ApprovalStatus = 'Rejected' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS RejectionRate
FROM RequestClaim rc
JOIN Client c ON rc.ClientID = c.ClientID
WHERE rc.DateCreated >= NOW() - INTERVAL '3 MONTH'
GROUP BY rc.ClientID, c.FirstName, c.MiddleName, c.LastName
HAVING COUNT(*) > 10 AND SUM(rc.Amount) > 100000 
ORDER BY TotalClaims DESC;
SELECT * FROM ClientSummaryFiltered;

INSERT INTO RequestClaim (EmployeeID, ClientID, DateCreated, Amount, ApprovalStatus, DecisionDate) VALUES
('EMP00008', 'CLI00001', '2024-11-08', 25000, 'Rejected', NULL),
('EMP00009', 'CLI00001', '2024-11-06', 25000, 'Rejected', NULL),
('EMP00008', 'CLI00001', '2024-11-07', 25000, 'Rejected', NULL),
('EMP00001', 'CLI00001', '2024-10-08', 50000, 'Rejected', NULL),
('EMP00008', 'CLI00001', '2024-10-08', 25000, 'Rejected', NULL),
('EMP00009', 'CLI00001', '2024-11-16', 25000, 'Rejected', NULL),
('EMP00008', 'CLI00001', '2024-09-07', 25000, 'Rejected', NULL),
('EMP00008', 'CLI00001', '2024-09-08', 25000, 'Rejected', NULL),
('EMP00009', 'CLI00001', '2024-11-10', 25000, 'Rejected', NULL),
('EMP00008', 'CLI00001', '2024-11-17', 25000, 'Rejected', NULL),
('EMP00001', 'CLI00001', '2024-11-18', 50000, 'Rejected', NULL);
SELECT * FROM RequestClaim where ClientID = 'CLI00001';

-- client spending in different HCP
DROP VIEW IF EXISTS HealthcareProviderServicePayments;
CREATE VIEW HealthcareProviderServicePayments AS
SELECT ed.HealthcareProviderId,
c.ClientID,
ms.ServiceName,
pr.Date,
p.Amount AS AmountPaid
FROM EmployDoctor ed
JOIN Provide pr ON ed.DoctorID = pr.DoctorID
JOIN Client c ON pr.ClientID = c.ClientID
JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
JOIN Pays p ON c.ClientID = p.ClientID;

SELECT * FROM HealthcareProviderServicePayments;

-- agent revenue
DROP VIEW IF EXISTS AgentEarningsAnnually;
CREATE VIEW AgentEarningsAnnually AS
SELECT s.AgentID,
EXTRACT(YEAR FROM p.StartDate) AS Year,
COUNT(s.ClientID) AS TotalClients,
SUM(p.ExactCost) AS TotalRevenue,
ROUND(SUM(a.CommissionRate/100 * p.ExactCost), 2) AS TotalCommission
FROM Sell s
JOIN Policy p ON s.PolicyNumber = p.PolicyNumber
JOIN Agent a ON s.AgentID = a.AgentID
GROUP BY s.AgentID, EXTRACT(YEAR FROM p.StartDate)
ORDER BY TotalRevenue DESC;
SELECT * FROM AgentEarningsAnnually;

-- total profit of company
CREATE OR REPLACE VIEW TotalCompanyProfitPastYear AS
WITH RevenueFromPolicies AS (
    SELECT SUM(p.ExactCost - (a.CommissionRate / 100) * p.ExactCost) AS PoliciesRevenue
    FROM Policy p
    JOIN Sell s ON p.PolicyNumber = s.PolicyNumber
    JOIN Agent a ON s.AgentID = a.AgentID
    WHERE p.StartDate >= CURRENT_DATE - INTERVAL '1 year'
),
RevenueFromPayments AS (
    SELECT SUM(py.Amount) AS PaymentRevenue
    FROM Pays py
    WHERE py.Date >= CURRENT_DATE - INTERVAL '1 year'
),
NetRevenue AS (
    SELECT ROUND((SELECT PoliciesRevenue FROM RevenueFromPolicies) + (SELECT PaymentRevenue FROM RevenueFromPayments), 2) AS TotalRevenue
),
TotalEmployeeSalary AS (
    SELECT SUM(e.Salary * 12) AS TotalEmployeeSalaries
    FROM Employee e
),
TotalClaimAmount AS (
    SELECT SUM(CASE WHEN rc.ApprovalStatus = 'Approved' THEN rc.Amount ELSE 0 END) AS TotalClaims
    FROM RequestClaim rc
    WHERE rc.DateCreated >= CURRENT_DATE - INTERVAL '1 year'
),
NetExpenses AS (
    SELECT ROUND((SELECT TotalEmployeeSalaries FROM TotalEmployeeSalary) + (SELECT TotalClaims FROM TotalClaimAmount), 2) AS TotalExpenses
),
Profit AS (
    SELECT ROUND((SELECT TotalRevenue FROM NetRevenue) - (SELECT TotalExpenses FROM NetExpenses), 2) AS NetProfit
)
SELECT 
    (SELECT TotalRevenue FROM NetRevenue) AS TotalRevenue, 
    (SELECT TotalExpenses FROM NetExpenses) AS TotalExpenses, 
    (SELECT NetProfit FROM Profit) AS NetProfit;
SELECT * FROM TotalCompanyProfitPastYear;

-- top 10 medical conditions & their services
WITH ConditionFrequency AS (
    SELECT mr.ConditionName, COUNT(mr.ClientID) AS ConditionCount
    FROM MedicalRecords mr
    GROUP BY mr.ConditionName
    ORDER BY ConditionCount DESC
    LIMIT 10
),
ServicesForConditions AS (
    SELECT cf.ConditionName,
	cf.ConditionCount, 
	ms.ServiceName,
	ip.CoverageLevel,
	COUNT(DISTINCT pr.ClientID) AS ClientsServed
    FROM ConditionFrequency cf
    JOIN MedicalRecords mr ON cf.ConditionName = mr.ConditionName
    JOIN Provide pr ON mr.ClientID = pr.ClientID
    JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
    JOIN Sell sl ON mr.ClientID = sl.ClientID
    JOIN Policy pl ON sl.PolicyNumber = pl.PolicyNumber
    JOIN InsurancePlan ip ON pl.InsurancePlanName = ip.InsurancePlanName
    GROUP BY cf.ConditionName, cf.ConditionCount, ms.ServiceName, ip.CoverageLevel
)
SELECT 
    ConditionName,
    ConditionCount, 
    ServiceName,
    CoverageLevel,
    ClientsServed
FROM ServicesForConditions
ORDER BY ConditionCount DESC, ConditionName, CoverageLevel, ClientsServed DESC;

INSERT INTO MedicalRecords (ClientID, ICDCode, DateCreated, ConditionName, Description) VALUES
('CLI00009', 'A01.0', '2024-01-15', 'Typhoid Fever', 'Acute bacterial infection'),
('CLI00009', 'L50.0', '2024-04-10', 'Urticaria', 'Condition with red, itchy welts'),
('CLI00008', 'L50.0', '2024-03-10', 'Urticaria', 'Condition with red, itchy welts');

-- high risk client
WITH AggregatedMedicalRecords AS (
    SELECT ClientID, 
	COUNT(DISTINCT ICDCode) AS MedicalRecordCount
    FROM MedicalRecords
    GROUP BY ClientID
),
AggregatedRequestClaims AS (
    SELECT ClientID, 
        SUM(CASE 
            WHEN ApprovalStatus IN ('Approved', 'Pending') THEN Amount 
            ELSE 0 
        END) AS TotalClaimAmount
    FROM RequestClaim
    GROUP BY ClientID
),
AggregatedDependents AS (
    SELECT ClientID, COUNT(*) AS NumberOfDependents
    FROM ClientDependent
    GROUP BY ClientID
)
SELECT c.ClientID,
CONCAT(c.FirstName, ' ', COALESCE(c.MiddleName, ''), ' ', c.LastName) AS ClientName,
    COALESCE(mr.MedicalRecordCount, 0) AS MedicalRecordCount,
    COALESCE(rc.TotalClaimAmount, 0) AS TotalClaimAmount,
    COALESCE(dep.NumberOfDependents, 0) AS NumberOfDependents
FROM Client c
LEFT JOIN AggregatedMedicalRecords mr ON c.ClientID = mr.ClientID
LEFT JOIN AggregatedRequestClaims rc ON c.ClientID = rc.ClientID
LEFT JOIN AggregatedDependents dep ON c.ClientID = dep.ClientID
WHERE COALESCE(mr.MedicalRecordCount, 0) > 10 
	AND COALESCE(rc.TotalClaimAmount, 0) > 100000
    AND COALESCE(dep.NumberOfDependents, 0) > 0
ORDER BY rc.TotalClaimAmount DESC;
	
INSERT INTO RequestClaim (EmployeeID, ClientID, DateCreated, Amount, ApprovalStatus, DecisionDate)
VALUES 
('EMP00001', 'CLI00005', '2024-01-15', 40000.00, 'Approved', '2024-01-20'),
('EMP00002', 'CLI00005', '2024-02-10', 35000.00, 'Approved', '2024-02-12'),
('EMP00003', 'CLI00005', '2024-03-01', 30000.00, 'Approved', '2024-03-05');
INSERT INTO MedicalRecords (ClientID, ICDCode, ConditionName, Description)
VALUES 
('CLI00005', 'I10', 'Essential Hypertension', 'Chronic high blood pressure without a known secondary cause.'),
('CLI00005', 'E11.9', 'Type 2 Diabetes Mellitus', 'A form of diabetes where the body does not properly use insulin, typically occurring in adulthood.'),
('CLI00005', 'J45.40', 'Moderate Persistent Asthma', 'A chronic inflammatory disease of the airways characterized by wheezing, breathlessness, and coughing.'),
('CLI00005', 'M81.0', 'Osteoporosis, Age-Related', 'A condition where bones become weak and brittle, often occurring as a result of aging.'),
('CLI00005', 'F41.9', 'Anxiety Disorder', 'A mental health condition characterized by excessive worry, fear, or anxiety.'),
('CLI00005', 'C50.9', 'Breast Cancer', 'A malignant tumor that originates in the cells of the breast.'),
('CLI00005', 'N40', 'Benign Prostatic Hyperplasia', 'Enlargement of the prostate gland, a common condition in older men that can cause urinary problems.'),
('CLI00005', 'L40.0', 'Psoriasis Vulgaris', 'A chronic autoimmune skin condition that leads to the rapid buildup of skin cells, forming scaly patches.'),
('CLI00005', 'J44.9', 'Chronic Obstructive Pulmonary Disease (COPD)', 'A group of lung diseases that block airflow and make it difficult to breathe, often caused by smoking.'),
('CLI00005', 'I63.9', 'Cerebrovascular Accident (Stroke)', 'A medical emergency where blood flow to a part of the brain is interrupted, leading to brain cell death.');

INSERT INTO RequestClaim (EmployeeID, ClientID, DateCreated, Amount, ApprovalStatus, DecisionDate)
VALUES 
('EMP00001', 'CLI00007', '2024-01-15', 40000.00, 'Approved', '2024-01-20'),
('EMP00002', 'CLI00007', '2024-02-10', 35000.00, 'Approved', '2024-02-12'),
('EMP00003', 'CLI00007', '2024-03-01', 30000.00, 'Approved', '2024-03-05');
INSERT INTO MedicalRecords (ClientID, ICDCode, ConditionName, Description)
VALUES 
('CLI00007', 'I10', 'Essential Hypertension', 'Chronic high blood pressure without a known secondary cause.'),
('CLI00007', 'E11.9', 'Type 2 Diabetes Mellitus', 'A form of diabetes where the body does not properly use insulin, typically occurring in adulthood.'),
('CLI00007', 'J45.40', 'Moderate Persistent Asthma', 'A chronic inflammatory disease of the airways characterized by wheezing, breathlessness, and coughing.'),
('CLI00007', 'M81.0', 'Osteoporosis, Age-Related', 'A condition where bones become weak and brittle, often occurring as a result of aging.'),
('CLI00007', 'F41.9', 'Anxiety Disorder', 'A mental health condition characterized by excessive worry, fear, or anxiety.'),
('CLI00007', 'C50.9', 'Breast Cancer', 'A malignant tumor that originates in the cells of the breast.'),
('CLI00007', 'N40', 'Benign Prostatic Hyperplasia', 'Enlargement of the prostate gland, a common condition in older men that can cause urinary problems.'),
('CLI00007', 'L40.0', 'Psoriasis Vulgaris', 'A chronic autoimmune skin condition that leads to the rapid buildup of skin cells, forming scaly patches.'),
('CLI00007', 'J44.9', 'Chronic Obstructive Pulmonary Disease (COPD)', 'A group of lung diseases that block airflow and make it difficult to breathe, often caused by smoking.'),
('CLI00007', 'I63.9', 'Cerebrovascular Accident (Stroke)', 'A medical emergency where blood flow to a part of the brain is interrupted, leading to brain cell death.');

-- network utilization and coverage gap
WITH ActivePolicies AS (
    SELECT s.ClientID, s.PolicyNumber, p.StartDate, p.EndDate, c.InsurancePlanName, c.HealthcareProviderID
    FROM Sell s
    INNER JOIN Policy p ON s.PolicyNumber = p.PolicyNumber
    INNER JOIN Covers c ON p.InsurancePlanName = c.InsurancePlanName
    WHERE p.EndDate >= CURRENT_DATE
),
ProviderUsage AS (
    SELECT ap.ClientID, ap.HealthcareProviderID, h.ProviderName, COUNT(DISTINCT pr.ServiceID) AS ServicesUsed
    FROM ActivePolicies ap
    LEFT JOIN Provide pr ON ap.ClientID = pr.ClientID
        AND pr.DoctorID IN (
            SELECT DoctorID FROM EmployDoctor WHERE HealthcareProviderID = ap.HealthcareProviderID
        )
    LEFT JOIN HealthcareProvider h ON ap.HealthcareProviderID = h.HealthcareProviderID
    GROUP BY ap.ClientID, ap.HealthcareProviderID, h.ProviderName
),
UnusedProviders AS (
    SELECT DISTINCT h.HealthcareProviderID, h.ProviderName, c.InsurancePlanName
    FROM Covers c
    LEFT JOIN ProviderUsage pu ON c.HealthcareProviderID = pu.HealthcareProviderID
    LEFT JOIN HealthcareProvider h ON c.HealthcareProviderID = h.HealthcareProviderID
    WHERE pu.ServicesUsed IS NULL
)
SELECT 	up.ProviderName AS UnusedProvider, 
		up.InsurancePlanName AS CoveredPlan,
		COUNT(DISTINCT ap.ClientID) AS ClientsCovered,
    	COUNT(DISTINCT pr.ClientID) AS ClientsUtilizing
FROM UnusedProviders up
LEFT JOIN ActivePolicies ap ON up.HealthcareProviderID = ap.HealthcareProviderID
LEFT JOIN Provide pr ON ap.ClientID = pr.ClientID
GROUP BY up.ProviderName, up.InsurancePlanName
ORDER BY ClientsCovered DESC;

-- employees and claims
WITH EmployeeClaimStats AS (
SELECT e.EmployeeID,
		e.FirstName || ' ' || COALESCE(e.MiddleName, '') || ' ' || e.LastName AS EmployeeName,
        rc.ApprovalStatus,
        COUNT(rc.ClientID) AS ClaimCount,
        SUM(rc.Amount) AS TotalClaimAmount
FROM RequestClaim rc
INNER JOIN Employee e ON rc.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.MiddleName, e.LastName, rc.ApprovalStatus
)
SELECT 
ecs.EmployeeID,
ecs.EmployeeName,
ecs.ApprovalStatus,
ecs.ClaimCount,
ecs.TotalClaimAmount,
ROUND((ecs.ClaimCount::DECIMAL / SUM(ecs.ClaimCount) OVER (PARTITION BY ecs.EmployeeID)) * 100, 2) AS PercentageOfTotalClaims
FROM EmployeeClaimStats ecs
ORDER BY ecs.EmployeeID, ecs.ApprovalStatus;

CREATE TABLE Users (
    UserID VARCHAR(50) PRIMARY KEY,
    Username VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,  -- Store plain text password
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Employee', 'Client', 'Agent', 'Doctor', 'Admin')),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Users (UserID, Username, Password, Role)
SELECT
    EmployeeID AS UserID,
    Email AS Username,
    'eece433project' AS Password, 
    'Employee' AS Role
FROM Employee;

INSERT INTO Users (UserID, Username, Password, Role)
SELECT
    ClientID AS UserID,
    Email AS Username,
    'eece433project' AS Password,
    'Client' AS Role
FROM Client;

INSERT INTO Users (UserID, Username, Password, Role)
SELECT
    AgentID AS UserID,
    Email AS Username,
    'eece433project' AS Password,
    'Agent' AS Role
FROM Agent;

INSERT INTO Users (UserID, Username,Password, Role)
SELECT
    DoctorID AS UserID,
    Email AS Username,
    'eece433project' AS Password,
    'Doctor' AS Role
FROM Doctor;

CREATE ROLE employee_role NOINHERIT;
CREATE ROLE client_role NOINHERIT;
CREATE ROLE agent_role NOINHERIT;
CREATE ROLE doctor_role NOINHERIT;

-- Employees can manage client and medical record data
GRANT SELECT, INSERT, UPDATE, DELETE ON Client, MedicalRecords TO employee_role;

-- Clients can view their own data
GRANT SELECT ON Client TO client_role;

-- Agents can manage policies
GRANT SELECT, INSERT, UPDATE ON Policy TO agent_role;

-- Doctors can manage medical records and services
GRANT SELECT, INSERT ON MedicalRecords, Provide TO doctor_role;

DO $$
DECLARE
    user_record RECORD; -- Define variable to hold each row of Users table
BEGIN
    FOR user_record IN SELECT * FROM Users LOOP
        -- Step 1: Check if the role exists; if not, create it
        IF NOT EXISTS (
            SELECT 1 FROM pg_roles WHERE rolname = user_record.Username
        ) THEN
            EXECUTE 'CREATE ROLE "' || user_record.Username || '" WITH LOGIN PASSWORD ''defaultpassword''';
        END IF;

        -- Step 2: Assign appropriate role to the user
        IF user_record.Role = 'Employee' THEN
            EXECUTE 'GRANT employee_role TO "' || user_record.Username || '"';
        ELSIF user_record.Role = 'Client' THEN
            EXECUTE 'GRANT client_role TO "' || user_record.Username || '"';
        ELSIF user_record.Role = 'Agent' THEN
            EXECUTE 'GRANT agent_role TO "' || user_record.Username || '"';
        ELSIF user_record.Role = 'Doctor' THEN
            EXECUTE 'GRANT doctor_role TO "' || user_record.Username || '"';
        END IF;
    END LOOP;
END $$;

-- Enable Row-Level Security on Client table
ALTER TABLE Client ENABLE ROW LEVEL SECURITY;

-- Enable Row-Level Security on Agent table
ALTER TABLE Agent ENABLE ROW LEVEL SECURITY;

-- Policy to allow each client to see only their own row
CREATE POLICY client_row_policy ON Client
USING (Email = current_user); -- current_user represents the logged-in role

-- Policy to allow each agent to see only their own row
CREATE POLICY agent_row_policy ON Agent
USING (Email = current_user);

GRANT SELECT ON Agent TO agent_role;

ALTER TABLE Client ENABLE ROW LEVEL SECURITY;
ALTER TABLE Agent ENABLE ROW LEVEL SECURITY;

CREATE POLICY client_complex_query_policy ON Client
USING (Email = current_user);
CREATE POLICY agent_complex_query_policy ON Agent
USING (Email = current_user);

SELECT 
    H.HealthcareProviderID,
    H.ProviderName AS HealthcareProviderName,
    C.ClientID,
    CONCAT(C.FirstName, ' ', COALESCE(C.MiddleName, ''), ' ', C.LastName) AS ClientFullName,
    SUM(P.ServiceCost) AS TotalSpending
FROM Provide P
JOIN Client C ON P.ClientID = C.ClientID -- RLS applies here
JOIN EmployDoctor ED ON P.DoctorID = ED.DoctorID
JOIN HealthcareProvider H ON ED.HealthcareProviderID = H.HealthcareProviderID
GROUP BY H.HealthcareProviderID, H.ProviderName, C.ClientID, C.FirstName, C.MiddleName, C.LastName
ORDER BY TotalSpending DESC;

CREATE OR REPLACE VIEW AgentEarningsAnnually AS
SELECT 
    s.AgentID,
    EXTRACT(YEAR FROM p.StartDate) AS Year,
    COUNT(s.ClientID) AS TotalClients,
    SUM(p.ExactCost) AS TotalRevenue,
    ROUND(SUM(a.CommissionRate / 100 * p.ExactCost), 2) AS TotalCommission
FROM Sell s
JOIN Policy p ON s.PolicyNumber = p.PolicyNumber
JOIN Agent a ON s.AgentID = a.AgentID
WHERE a.Email = current_user -- Restrict to the logged-in agent
GROUP BY s.AgentID, EXTRACT(YEAR FROM p.StartDate)
ORDER BY TotalRevenue DESC;

GRANT SELECT ON AgentEarningsAnnually TO agent_role;
GRANT SELECT ON Sell TO agent_role;
GRANT SELECT ON Policy TO agent_role;
GRANT SELECT ON Agent TO agent_role;

CREATE OR REPLACE VIEW Top5MonthlyServiceSummary AS
WITH RankedServices AS (
    SELECT 
        ed.HealthcareProviderId,
        ms.ServiceID,
        ms.ServiceName,
        CONCAT(
            EXTRACT(YEAR FROM pr.Date)::TEXT, '-', 
            LPAD(EXTRACT(MONTH FROM pr.Date)::TEXT, 2, '0')
        ) AS ServicePeriod,
        COUNT(*) AS TotalUses,
        SUM(pr.ServiceCost) AS TotalGenerated,
        ROW_NUMBER() OVER (
            PARTITION BY ed.HealthcareProviderId, EXTRACT(YEAR FROM pr.Date), EXTRACT(MONTH FROM pr.Date)
            ORDER BY SUM(pr.ServiceCost) DESC
        ) AS Rank
    FROM Provide pr
    JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
    JOIN EmployDoctor ed ON pr.DoctorID = ed.DoctorID
    GROUP BY ed.HealthcareProviderId, ms.ServiceID, ms.ServiceName, EXTRACT(YEAR FROM pr.Date), EXTRACT(MONTH FROM pr.Date)
)
SELECT 
    HealthcareProviderId,
    ServiceID,
    ServiceName,
    ServicePeriod,
    TotalUses,
    TotalGenerated
FROM RankedServices
WHERE Rank <= 5
ORDER BY HealthcareProviderId, ServicePeriod, TotalGenerated DESC;

GRANT SELECT ON Top5MonthlyServiceSummary TO employee_role;
REVOKE ALL ON Top5MonthlyServiceSummary FROM PUBLIC;
REVOKE ALL ON AgentEarningsAnnually FROM PUBLIC;
REVOKE ALL ON AgentEarningsAnnually FROM agent_role;
GRANT SELECT ON AgentEarningsAnnually TO employee_role;

CREATE OR REPLACE VIEW Top5MonthlyServiceSummary AS
WITH RankedServices AS (
    SELECT 
        ed.HealthcareProviderId,
        ms.ServiceID,
        ms.ServiceName,
        CONCAT(
            EXTRACT(YEAR FROM pr.Date)::TEXT, '-', 
            LPAD(EXTRACT(MONTH FROM pr.Date)::TEXT, 2, '0')
        ) AS ServicePeriod,
        COUNT(*) AS TotalUses,
        SUM(pr.ServiceCost) AS TotalGenerated,
        ROW_NUMBER() OVER (
            PARTITION BY ed.HealthcareProviderId, EXTRACT(YEAR FROM pr.Date), EXTRACT(MONTH FROM pr.Date)
            ORDER BY SUM(pr.ServiceCost) DESC
        ) AS Rank
    FROM Provide pr
    JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
    JOIN EmployDoctor ed ON pr.DoctorID = ed.DoctorID
    GROUP BY ed.HealthcareProviderId, ms.ServiceID, ms.ServiceName, EXTRACT(YEAR FROM pr.Date), EXTRACT(MONTH FROM pr.Date)
)
SELECT 
    HealthcareProviderId,
    ServiceID,
    ServiceName,
    ServicePeriod,
    TotalUses,
    TotalGenerated
FROM RankedServices
WHERE Rank <= 5
ORDER BY HealthcareProviderId, ServicePeriod, TotalGenerated DESC;

GRANT SELECT ON Top5MonthlyServiceSummary TO employee_role;
REVOKE ALL ON Top5MonthlyServiceSummary FROM PUBLIC;


GRANT SELECT ON Top5MonthlyServiceSummary TO "sami.shams@procare.com";
REVOKE ALL ON Top5MonthlyServiceSummary FROM PUBLIC;
REVOKE SELECT ON Top5MonthlyServiceSummary FROM employee_role;

DO $$
BEGIN
    -- Check if the role exists
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sami.shams@procare.com') THEN
        CREATE ROLE "sami.shams@procare.com" WITH LOGIN PASSWORD 'securepassword';
    END IF;
END $$;


GRANT SELECT ON ClientSummaryFiltered TO "layla.kassem@procare.com";
REVOKE ALL ON ClientSummaryFiltered FROM PUBLIC;
REVOKE SELECT ON ClientSummaryFiltered FROM employee_role;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'layla.kassem@procare.com') THEN
        CREATE ROLE "layla.kassem@procare.com" WITH LOGIN PASSWORD 'securepassword';
    END IF;
END $$;

GRANT SELECT ON HealthcareProviderServicePayments TO "layla.kassem@procare.com";
REVOKE ALL ON HealthcareProviderServicePayments FROM PUBLIC;
REVOKE SELECT ON HealthcareProviderServicePayments FROM employee_role;
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'layla.kassem@procare.com') THEN
        CREATE ROLE "layla.kassem@procare.com" WITH LOGIN PASSWORD 'securepassword';
    END IF;
END $$;

GRANT SELECT ON HealthcareProviderServicePayments TO "sami.shams@procare.com";
REVOKE ALL ON HealthcareProviderServicePayments FROM PUBLIC;
REVOKE SELECT ON HealthcareProviderServicePayments FROM employee_role;
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'sami.shams@procare.com') THEN
        CREATE ROLE "sami.shams@procare.com" WITH LOGIN PASSWORD 'securepassword';
    END IF;
END $$;

CREATE OR REPLACE VIEW HealthcareProviderServicePaymentsRestricted AS
SELECT 
    ed.HealthcareProviderId,
    ms.ServiceName,
    pr.Date,
    p.Amount AS AmountPaid
FROM EmployDoctor ed
JOIN Provide pr ON ed.DoctorID = pr.DoctorID
JOIN Client c ON pr.ClientID = c.ClientID
JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
JOIN Pays p ON c.ClientID = p.ClientID;
GRANT SELECT ON HealthcareProviderServicePaymentsRestricted TO "sami.shams@procare.com";
REVOKE SELECT ON HealthcareProviderServicePayments FROM "sami.shams@procare.com";

ALTER TABLE Users
    ALTER COLUMN Role TYPE VARCHAR(20), -- Expand the length if needed
    ADD CONSTRAINT role_check CHECK (Role IN ('Employee', 'Client', 'Agent', 'Doctor', 'HealthcareProvider'));

SELECT conname 
FROM pg_constraint 
WHERE conrelid = 'Users'::regclass AND contype = 'c';
ALTER TABLE Users DROP CONSTRAINT users_role_check;

ALTER TABLE Users 
ADD CONSTRAINT users_role_check 
CHECK (Role IN ('Employee', 'Client', 'Agent', 'Doctor', 'HealthcareProvider'));

INSERT INTO Users (UserID, Username, Password, Role)
SELECT 
    HealthcareProviderID AS UserID,
    LOWER(REPLACE(ProviderName, ' ', '.')) || '@healthcare.com' AS Username, 
    'eece433project' AS Password,
    'HealthcareProvider' AS Role
FROM HealthcareProvider
WHERE HealthcareProviderID NOT IN (SELECT UserID FROM Users WHERE Role = 'HealthcareProvider');

ALTER TABLE HealthcareProvider ENABLE ROW LEVEL SECURITY;
CREATE POLICY healthcare_provider_policy ON HealthcareProvider
USING (LOWER(REPLACE(ProviderName, ' ', '.')) || '@healthcare.com' = current_user);

CREATE ROLE healthcare_provider_role NOINHERIT;
GRANT SELECT ON HealthcareProvider TO healthcare_provider_role;

DO $$
DECLARE
    provider RECORD; -- Define the loop variable as a record type
BEGIN
    FOR provider IN 
        SELECT LOWER(REPLACE(ProviderName, ' ', '.')) || '@healthcare.com' AS username
        FROM HealthcareProvider
    LOOP
        -- Check if the role exists and create it if it doesn't
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = provider.username) THEN
            EXECUTE 'CREATE ROLE "' || provider.username || '" WITH LOGIN PASSWORD ''securepassword''';
        END IF;
        
        -- Grant the healthcare_provider_role to the user
        EXECUTE 'GRANT healthcare_provider_role TO "' || provider.username || '"';
    END LOOP;
END $$;

ALTER TABLE HealthcareProvider ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON HealthcareProvider TO healthcare_provider_role;

CREATE OR REPLACE VIEW HealthcareProviderServicePayments AS
SELECT 
    ed.HealthcareProviderId,
    c.ClientID,
    ms.ServiceName,
    pr.Date,
    p.Amount AS AmountPaid
FROM EmployDoctor ed
JOIN Provide pr ON ed.DoctorID = pr.DoctorID
JOIN Client c ON pr.ClientID = c.ClientID
JOIN MedicalService ms ON pr.ServiceID = ms.ServiceID
JOIN Pays p ON c.ClientID = p.ClientID
WHERE ed.HealthcareProviderId IN (
    SELECT HealthcareProviderID
    FROM HealthcareProvider
    WHERE LOWER(REPLACE(ProviderName, ' ', '.')) || '@healthcare.com' = current_user
);
GRANT SELECT ON HealthcareProviderServicePayments TO healthcare_provider_role;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'karim.boukhallil@procare.com') THEN
        CREATE ROLE "karim.boukhallil@procare.com" WITH LOGIN PASSWORD 'securepassword';
    END IF;
END $$;

GRANT SELECT ON AgentEarningsAnnually TO "karim.boukhallil@procare.com";
CREATE ROLE sales_executive_role NOINHERIT;
GRANT SELECT ON AgentEarningsAnnually TO sales_executive_role;
GRANT sales_executive_role TO "karim.boukhallil@procare.com";
GRANT SELECT ON Agent TO "karim.boukhallil@procare.com";

CREATE POLICY agent_access_policy ON Agent
USING (true); -- This allows all rows to be visible

ALTER TABLE Agent ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE VIEW RestrictedAgent AS
SELECT * FROM Agent
WHERE Email = 'karim.boukhallil@procare.com'; -- Example of restrictive filtering

ALTER TABLE RequestClaim ENABLE ROW LEVEL SECURITY;
CREATE POLICY request_claim_client_policy ON RequestClaim
USING (
    ClientID = (
        SELECT ClientID
        FROM Client
        WHERE LOWER(Email) = current_user
    )
);
GRANT SELECT ON RequestClaim TO client_role;

GRANT SELECT ON RequestClaim TO "fadi.salameh@procare.com";
GRANT SELECT ON RequestClaim TO "layla.kassem@procare.com";

DROP POLICY IF EXISTS request_claim_client_policy ON RequestClaim;

CREATE POLICY request_claim_client_policy ON RequestClaim
USING (
    -- Allow clients to see only their own rows
    ClientID = (SELECT ClientID FROM Client WHERE LOWER(Email) = current_user)
    OR
    -- Allow Fadi and Layla to see all rows
    current_user IN ('fadi.salameh@procare.com', 'layla.kassem@procare.com')
);

CREATE ROLE hr_role NOINHERIT;

CREATE OR REPLACE VIEW HealthcareProviderClientCount AS
SELECT 
    H.HealthcareProviderID, 
    H.ProviderName AS HealthcareProviderName, 
    IP.CoverageLevel AS InsurancePlanLevel, 
    COUNT(DISTINCT C.ClientID) AS ClientCount  
FROM Provide P 
JOIN Client C ON P.ClientID = C.ClientID 
JOIN Sell S ON C.ClientID = S.ClientID 
JOIN Policy L ON S.PolicyNumber = L.PolicyNumber 
JOIN InsurancePlan IP ON L.InsurancePlanName = IP.InsurancePlanName 
JOIN EmployDoctor ED ON P.DoctorID = ED.DoctorID 
JOIN HealthcareProvider H ON ED.HealthcareProviderID = H.HealthcareProviderID 
GROUP BY H.HealthcareProviderID, H.ProviderName, IP.CoverageLevel 
ORDER BY H.HealthcareProviderID, IP.CoverageLevel;


GRANT SELECT ON HealthcareProviderClientCount TO hr_role;

REVOKE SELECT ON HealthcareProviderClientCount FROM PUBLIC;
GRANT hr_role TO "hana.jebril@procare.com";

SELECT * FROM pg_views WHERE viewname = 'HealthcareProviderClientCount';

SELECT * FROM Provide;
SELECT * FROM Client;
SELECT * FROM Sell;
SELECT * FROM Policy;
SELECT * FROM InsurancePlan;
SELECT * FROM EmployDoctor;
SELECT * FROM HealthcareProvider;
SELECT * FROM HealthcareProviderClientCount;

GRANT SELECT ON ClientServicePaymentsView TO "sami.shams@procare.com";

GRANT SELECT, INSERT, UPDATE, DELETE ON users TO "noor.ghazal@procare.com" WITH GRANT OPTION;

CREATE EXTENSION IF NOT EXISTS pgcrypto;
UPDATE Users
SET Password = crypt(Password, gen_salt('bf'))
WHERE Password NOT LIKE '$2b$%'; -- Only encrypt if not already encrypted

REVOKE ALL ON AgentEarningsAnnually FROM PUBLIC;

GRANT SELECT ON AgentEarningsAnnually TO agent_role;
CREATE OR REPLACE VIEW AgentEarningsAnnually AS
SELECT 
    s.AgentID,
    EXTRACT(YEAR FROM p.StartDate) AS Year,
    COUNT(s.ClientID) AS TotalClients,
    SUM(p.ExactCost) AS TotalRevenue,
    ROUND(SUM(a.CommissionRate / 100 * p.ExactCost), 2) AS TotalCommission
FROM Sell s
JOIN Policy p ON s.PolicyNumber = p.PolicyNumber
JOIN Agent a ON s.AgentID = a.AgentID
WHERE a.Email = current_user  -- Filter rows by the current user's email
GROUP BY s.AgentID, EXTRACT(YEAR FROM p.StartDate);

REVOKE SELECT ON AgentEarningsAnnually FROM employee_role, client_role, doctor_role;

CREATE OR REPLACE VIEW AgentEarningsWithoutCommission AS
SELECT 
    s.AgentID,
    EXTRACT(YEAR FROM p.StartDate) AS Year,
    COUNT(s.ClientID) AS TotalClients,
    SUM(p.ExactCost) AS TotalRevenue,
    ROUND(SUM(p.ExactCost), 2) AS TotalRevenueWithoutCommission -- Recalculated if needed
FROM Sell s
JOIN Policy p ON s.PolicyNumber = p.PolicyNumber
JOIN Agent a ON s.AgentID = a.AgentID
GROUP BY s.AgentID, EXTRACT(YEAR FROM p.StartDate);

GRANT SELECT ON AgentEarningsWithoutCommission TO "karim.boukhallil@procare.com";
SET ROLE "karim.boukhallil@procare.com";

SELECT * FROM AgentEarningsWithoutCommission;