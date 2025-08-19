use project_1
delete project_1

-- Temporary static lists for names (you can extend to 200+ names)
DECLARE @FirstNames TABLE (Name VARCHAR(50));
INSERT INTO @FirstNames VALUES 
('John'), ('Michael'), ('Emily'), ('Sarah'), ('David'), ('Olivia'),
('James'), ('Emma'), ('Daniel'), ('Sophia'), ('Matthew'), ('Ava'),
('Ethan'), ('Isabella'), ('Liam'), ('Mia'), ('Noah'), ('Charlotte'),
('Lucas'), ('Amelia');

DECLARE @LastNames TABLE (Name VARCHAR(50));
INSERT INTO @LastNames VALUES 
('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'), ('Garcia'),
('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'), ('Hernandez'), ('Lopez'),
('Gonzalez'), ('Wilson'), ('Anderson'), ('Thomas'), ('Taylor'), ('Moore'),
('Jackson'), ('Martin');


CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100),
    DOB DATE,
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    Address VARCHAR(255),
    NationalID VARCHAR(20),
    TaxID VARCHAR(20),
    EmploymentStatus VARCHAR(50),
    AnnualIncome DECIMAL(18,2),
    CreatedAt DATETIME,
    UpdatedAt DATETIME
);

-- Generate 1500 Customers with real names
DECLARE @i INT = 1;
DECLARE @FirstName VARCHAR(50), @LastName VARCHAR(50), @FullName VARCHAR(100);
WHILE @i <= 1500
BEGIN
    -- Pick random first and last name
    SELECT TOP 1 @FirstName = Name FROM @FirstNames ORDER BY NEWID();
    SELECT TOP 1 @LastName = Name FROM @LastNames ORDER BY NEWID();

    SET @FullName = @FirstName + ' ' + @LastName;

    INSERT INTO Customers
    VALUES (
        @i,
        @FullName,
        DATEADD(DAY, -1 * (365 * (18 + ABS(CHECKSUM(NEWID())) % 40)), GETDATE()), -- Age 18-60
        LOWER(CONCAT(@FirstName, '.', @LastName, @i, '@examplebank.com')),
        CONCAT('+9989', FORMAT(@i, '0000000')),
        CONCAT('Street ', @i, ', Tashkent, UZ'),
        FORMAT(@i, '0000000000'),
        FORMAT(@i * 3, '0000000000'),
        CASE WHEN @i % 3 = 0 THEN 'Employed' WHEN @i % 3 = 1 THEN 'Unemployed' ELSE 'Student' END,
        ROUND(15000 + (RAND() * 85000), 2),
        GETDATE(),
        GETDATE()
    );

    SET @i += 1;
END;





CREATE TABLE Branches (
    BranchID INT PRIMARY KEY,
    BranchName VARCHAR(100),
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    ManagerID INT,
    ContactNumber VARCHAR(20)
);

-- Static City List
DECLARE @Cities TABLE (City VARCHAR(100));
INSERT INTO @Cities VALUES
('Tashkent'), ('Samarkand'), ('Bukhara'), ('Fergana'), ('Namangan'),
('Andijan'), ('Nukus'), ('Khiva'), ('Jizzakh'), ('Navoi');

-- Insert 50 branches
DECLARE @b INT = 1;
WHILE @b <= 50
BEGIN
    DECLARE @City VARCHAR(100);
    SELECT TOP 1 @City = City FROM @Cities ORDER BY NEWID();

    INSERT INTO Branches
    VALUES (
        @b,
        CONCAT(@City, ' Branch ', @b),
        CONCAT('Main Street ', @b, ', ', @City),
        @City,
        CONCAT(@City, ' Region'),
        'Uzbekistan',
        NULL, -- Set later
        CONCAT('+99871', FORMAT(@b, '000000'))
    );

    SET @b += 1;
END;



CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    BranchID INT FOREIGN KEY REFERENCES Branches(BranchID),
    FullName VARCHAR(100),
    Position VARCHAR(50),
    Department VARCHAR(50),
    Salary DECIMAL(18,2),
    HireDate DATE,
    Status VARCHAR(50)
);

-- Sample Names
DECLARE @EmpFirstNames TABLE (Name VARCHAR(50));
INSERT INTO @EmpFirstNames VALUES 
('Aziz'), ('Dilshod'), ('Malika'), ('Shahnoza'), ('Sardor'), ('Javlon'), ('Dildora'),
('Umid'), ('Lola'), ('Nodira'), ('Sanjar'), ('Nigora'), ('Kamol'), ('Madina');

DECLARE @EmpLastNames TABLE (Name VARCHAR(50));
INSERT INTO @EmpLastNames VALUES 
('Abdullaev'), ('Karimov'), ('Rakhimov'), ('Tursunov'), ('Rustamov'), ('Ergashev'),
('Saidova'), ('Sharipov'), ('Xolmatov'), ('Normurodov');

-- Insert 200 Employees
DECLARE @e INT = 1;
WHILE @e <= 200
BEGIN
    DECLARE @FName VARCHAR(50), @LName VARCHAR(50), @EmpName VARCHAR(100);
    SELECT TOP 1 @FName = Name FROM @EmpFirstNames ORDER BY NEWID();
    SELECT TOP 1 @LName = Name FROM @EmpLastNames ORDER BY NEWID();
    SET @EmpName = CONCAT(@FName, ' ', @LName);

    INSERT INTO Employees
    VALUES (
        @e,
        1 + (@e % 50),
        @EmpName,
        CASE WHEN @e % 6 = 0 THEN 'Manager'
             WHEN @e % 6 = 1 THEN 'Teller'
             WHEN @e % 6 = 2 THEN 'Auditor'
             WHEN @e % 6 = 3 THEN 'Loan Officer'
             WHEN @e % 6 = 4 THEN 'Support'
             ELSE 'Clerk' END,
        CASE WHEN @e % 4 = 0 THEN 'Operations'
             WHEN @e % 4 = 1 THEN 'HR'
             WHEN @e % 4 = 2 THEN 'IT'
             ELSE 'Finance' END,
        ROUND(2000 + (RAND() * 5000), 2),
        DATEADD(DAY, -1 * (365 * (1 + ABS(CHECKSUM(NEWID())) % 10)), GETDATE()),
        'Active'
    );

    SET @e += 1;
END;

-- Assign one Manager per branch
UPDATE b
SET b.ManagerID = e.EmployeeID
FROM Branches b
JOIN (
    SELECT EmployeeID, BranchID, ROW_NUMBER() OVER (PARTITION BY BranchID ORDER BY EmployeeID) AS rn
    FROM Employees
    WHERE Position = 'Manager'
) e ON b.BranchID = e.BranchID AND e.rn = 1;





CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    AccountType VARCHAR(50),
    Balance DECIMAL(18,2),
    Currency VARCHAR(10),
    Status VARCHAR(20),
    BranchID INT FOREIGN KEY REFERENCES Branches(BranchID),
    CreatedDate DATE
);

DECLARE @a INT = 1;
WHILE @a <= 3000
BEGIN
    INSERT INTO Accounts
    VALUES (
        @a,
        1 + (@a % 1500),
        CASE WHEN @a % 3 = 0 THEN 'Savings' 
             WHEN @a % 3 = 1 THEN 'Checking'
             ELSE 'Business' END,
        ROUND(100 + (RAND() * 20000), 2),
        'USD',
        'Active',
        1 + (@a % 50),
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 1000), GETDATE())
    );
    SET @a += 1;
END;





CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    AccountID INT FOREIGN KEY REFERENCES Accounts(AccountID),
    TransactionType VARCHAR(50),
    Amount DECIMAL(18,2),
    Currency VARCHAR(10),
    Date DATETIME,
    Status VARCHAR(20),
    ReferenceNo VARCHAR(100)
);

DECLARE @t INT = 1;
WHILE @t <= 4000
BEGIN
    INSERT INTO Transactions
    VALUES (
        @t,
        1 + (@t % 3000),
        CASE WHEN @t % 4 = 0 THEN 'Deposit'
             WHEN @t % 4 = 1 THEN 'Withdrawal'
             WHEN @t % 4 = 2 THEN 'Transfer'
             ELSE 'Payment' END,
        ROUND(10 + (RAND() * 10000), 2),
        CASE WHEN @t % 5 = 0 THEN 'UZS' ELSE 'USD' END,
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 730), GETDATE()), -- ~2 years back
        CASE WHEN @t % 10 = 0 THEN 'Pending' ELSE 'Completed' END,
        CONCAT('TXN', FORMAT(@t, '000000'))
    );
    SET @t += 1;
END;



---Digital Banking batch

CREATE TABLE CreditCards (
    CardID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CardNumber VARCHAR(20),
    CardType VARCHAR(20),
    CVV CHAR(3),
    ExpiryDate DATE,
    [Limit] DECIMAL(18,2),
    Status VARCHAR(20)
);

DECLARE @cc INT = 1;
WHILE @cc <= 500
BEGIN
    INSERT INTO CreditCards
    VALUES (
        @cc,
        1 + (@cc % 1500), -- FK to Customers
        CONCAT('4', FORMAT(ABS(CHECKSUM(NEWID())) % 10000000000000000, '0000000000000000')),
        CASE WHEN @cc % 2 = 0 THEN 'Visa' ELSE 'MasterCard' END,
        FORMAT(ABS(CHECKSUM(NEWID())) % 1000, '000'),
        DATEADD(YEAR, 2 + (@cc % 3), GETDATE()),
        ROUND(1000 + (RAND() * 9000), 2),
        'Active'
    );
    SET @cc += 1;
END;







CREATE TABLE CreditCardTransactions (
    TransactionID INT PRIMARY KEY,
    CardID INT FOREIGN KEY REFERENCES CreditCards(CardID),
    Merchant VARCHAR(100),
    Amount DECIMAL(18,2),
    Currency VARCHAR(10),
    [Date] DATETIME,
    Status VARCHAR(20)
);

DECLARE @cct INT = 1;
WHILE @cct <= 1000
BEGIN
    INSERT INTO CreditCardTransactions
    VALUES (
        @cct,
        1 + (@cct % 500),
        CASE
            WHEN @cct % 5 = 0 THEN 'AliExpress'
            WHEN @cct % 5 = 1 THEN 'Amazon'
            WHEN @cct % 5 = 2 THEN 'Netflix'
            WHEN @cct % 5 = 3 THEN 'Click'
            ELSE 'UZUM Market'
        END,
        ROUND(5 + (RAND() * 995), 2),
        CASE WHEN @cct % 4 = 0 THEN 'UZS' ELSE 'USD' END,
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 365), GETDATE()),
        CASE WHEN @cct % 20 = 0 THEN 'Declined' ELSE 'Completed' END
    );
    SET @cct += 1;
END;




CREATE TABLE OnlineBankingUsers (
    UserID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    Username VARCHAR(50),
    PasswordHash VARCHAR(100),
    LastLogin DATETIME
);

DECLARE @obu INT = 1;
WHILE @obu <= 800
BEGIN
    INSERT INTO OnlineBankingUsers
    VALUES (
        @obu,
        1 + (@obu % 1500),
        CONCAT('user', @obu),
        CONCAT('HASH', FORMAT(@obu, '000000')),
        DATEADD(DAY, -1 * (@obu % 100), GETDATE())
    );
    SET @obu += 1;
END;






CREATE TABLE BillPayments (
    PaymentID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    BillerName VARCHAR(100),
    Amount DECIMAL(18,2),
    [Date] DATETIME,
    Status VARCHAR(20)
);

DECLARE @bp INT = 1;
WHILE @bp <= 500
BEGIN
    INSERT INTO BillPayments
    VALUES (
        @bp,
        1 + (@bp % 1500),
        CASE
            WHEN @bp % 4 = 0 THEN 'UzGas'
            WHEN @bp % 4 = 1 THEN 'UzElectric'
            WHEN @bp % 4 = 2 THEN 'UzWater'
            ELSE 'Beeline Mobile'
        END,
        ROUND(10 + (RAND() * 500), 2),
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 180), GETDATE()),
        CASE WHEN @bp % 12 = 0 THEN 'Failed' ELSE 'Successful' END
    );
    SET @bp += 1;
END;



CREATE TABLE MobileBankingTransactions (
    TransactionID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    DeviceID VARCHAR(50),
    AppVersion VARCHAR(20),
    TransactionType VARCHAR(50),
    Amount DECIMAL(18,2),
    [Date] DATETIME
);

DECLARE @mbt INT = 1;
WHILE @mbt <= 500
BEGIN
    INSERT INTO MobileBankingTransactions
    VALUES (
        @mbt,
        1 + (@mbt % 1500),
        CONCAT('DEVICE_', FORMAT(@mbt, '00000')),
        CONCAT('v', 1 + (@mbt % 3), '.0.', (@mbt % 10)),
        CASE WHEN @mbt % 3 = 0 THEN 'P2P'
             WHEN @mbt % 3 = 1 THEN 'QR Payment'
             ELSE 'Top-up' END,
        ROUND(5 + (RAND() * 400), 2),
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 60), GETDATE())
    );
    SET @mbt += 1;
END;

--Loans and credits batch




CREATE TABLE Loans (
    LoanID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    LoanType VARCHAR(50),
    Amount DECIMAL(18,2),
    InterestRate DECIMAL(5,2),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(20)
);

DECLARE @l INT = 1;
WHILE @l <= 300
BEGIN
    DECLARE @StartDate DATE = DATEADD(MONTH, -1 * (1 + ABS(CHECKSUM(NEWID()) % 36)), GETDATE());
    INSERT INTO Loans
    VALUES (
        @l,
        1 + (@l % 1500),
        CASE WHEN @l % 4 = 0 THEN 'Mortgage'
             WHEN @l % 4 = 1 THEN 'Personal'
             WHEN @l % 4 = 2 THEN 'Auto'
             ELSE 'Business' END,
        ROUND(500 + (RAND() * 45000), 2),
        ROUND(5 + (RAND() * 10), 2),
        @StartDate,
        DATEADD(YEAR, 1 + (@l % 5), @StartDate),
        CASE WHEN @l % 10 = 0 THEN 'Closed' ELSE 'Active' END
    );
    SET @l += 1;
END;






CREATE TABLE LoanPayments (
    PaymentID INT PRIMARY KEY,
    LoanID INT FOREIGN KEY REFERENCES Loans(LoanID),
    AmountPaid DECIMAL(18,2),
    PaymentDate DATE,
    RemainingBalance DECIMAL(18,2)
);

DECLARE @lp INT = 1;
WHILE @lp <= 400
BEGIN
    DECLARE @LoanRef INT = 1 + (@lp % 300);
    DECLARE @Paid DECIMAL(18,2) = ROUND(100 + (RAND() * 2000), 2);
    DECLARE @Remaining DECIMAL(18,2) = ROUND(1000 + (RAND() * 10000), 2);
    INSERT INTO LoanPayments
    VALUES (
        @lp,
        @LoanRef,
        @Paid,
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 180), GETDATE()),
        @Remaining
    );
    SET @lp += 1;
END;





CREATE TABLE CreditScores (
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CreditScore INT,
    UpdatedAt DATE
);

DECLARE @cs INT = 1;
WHILE @cs <= 1500
BEGIN
    INSERT INTO CreditScores
    VALUES (
        @cs,
        300 + (ABS(CHECKSUM(NEWID())) % 551), -- Range 300–850
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 365), GETDATE())
    );
    SET @cs += 1;
END;





CREATE TABLE DebtCollection (
    DebtID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    AmountDue DECIMAL(18,2),
    DueDate DATE,
    CollectorAssigned VARCHAR(100)
);

DECLARE @dc INT = 1;
WHILE @dc <= 150
BEGIN
    INSERT INTO DebtCollection
    VALUES (
        @dc,
        1 + (@dc % 1500),
        ROUND(200 + (RAND() * 9000), 2),
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 120), GETDATE()),
        CASE WHEN @dc % 3 = 0 THEN 'Collector A'
             WHEN @dc % 3 = 1 THEN 'Collector B'
             ELSE 'Collector C' END
    );
    SET @dc += 1;
END;

--Compliance & Risk Batch




CREATE TABLE KYC (
    KYCID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    DocumentType VARCHAR(50),
    DocumentNumber VARCHAR(50),
    VerifiedBy VARCHAR(100)
);

DECLARE @kyc INT = 1;
WHILE @kyc <= 1500
BEGIN
    INSERT INTO KYC
    VALUES (
        @kyc,
        @kyc,
        CASE WHEN @kyc % 3 = 0 THEN 'Passport'
             WHEN @kyc % 3 = 1 THEN 'ID Card'
             ELSE 'Driver License' END,
        CONCAT('DOC', FORMAT(@kyc * 17, '0000000000')),
        CASE WHEN @kyc % 4 = 0 THEN 'Javlon Karimov'
             WHEN @kyc % 4 = 1 THEN 'Dilshod Nurmatov'
             WHEN @kyc % 4 = 2 THEN 'Aziza Madrahimova'
             ELSE 'Zafar Yunusov' END
    );
    SET @kyc += 1;
END;






CREATE TABLE FraudDetection (
    FraudID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    TransactionID INT FOREIGN KEY REFERENCES Transactions(TransactionID),
    RiskLevel VARCHAR(20),
    ReportedDate DATE
);

DECLARE @fd INT = 1;
WHILE @fd <= 200
BEGIN
    INSERT INTO FraudDetection
    VALUES (
        @fd,
        1 + (@fd % 1500),
        1 + (@fd % 4000),
        CASE WHEN @fd % 3 = 0 THEN 'High'
             WHEN @fd % 3 = 1 THEN 'Medium'
             ELSE 'Low' END,
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 60), GETDATE())
    );
    SET @fd += 1;
END;







CREATE TABLE AMLCases (
    CaseID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CaseType VARCHAR(50),
    Status VARCHAR(50),
    InvestigatorID INT
);

DECLARE @aml INT = 1;
WHILE @aml <= 50
BEGIN
    INSERT INTO AMLCases
    VALUES (
        @aml,
        1 + (@aml % 1500),
        CASE WHEN @aml % 2 = 0 THEN 'Unusual Transaction'
             ELSE 'Large Cash Deposit' END,
        CASE WHEN @aml % 4 = 0 THEN 'Closed'
             ELSE 'Open' END,
        1 + (@aml % 200)
    );
    SET @aml += 1;
END;








CREATE TABLE RegulatoryReports (
    ReportID INT PRIMARY KEY,
    ReportType VARCHAR(100),
    SubmissionDate DATE
);

DECLARE @rr INT = 1;
WHILE @rr <= 30
BEGIN
    INSERT INTO RegulatoryReports
    VALUES (
        @rr,
        CASE WHEN @rr % 3 = 0 THEN 'Monthly Compliance'
             WHEN @rr % 3 = 1 THEN 'Suspicious Activity Report'
             ELSE 'Quarterly AML Review' END,
        DATEADD(MONTH, -1 * (@rr % 12), GETDATE())
    );
    SET @rr += 1;
END;


--HR and payroll


CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100),
    ManagerID INT
);

INSERT INTO Departments
VALUES 
(1, 'Operations', NULL),
(2, 'Finance', NULL),
(3, 'HR', NULL),
(4, 'IT', NULL),
(5, 'Compliance', NULL);




CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    BaseSalary DECIMAL(18,2),
    Bonus DECIMAL(18,2),
    Deductions DECIMAL(18,2),
    PaymentDate DATE
);

DECLARE @s INT = 1;
WHILE @s <= 200
BEGIN
    DECLARE @Base DECIMAL(18,2) = ROUND(2000 + (RAND() * 3000), 2);
    DECLARE @Bonus DECIMAL(18,2) = ROUND(RAND() * 500, 2);
    DECLARE @Deduction DECIMAL(18,2) = ROUND(RAND() * 300, 2);

    INSERT INTO Salaries
    VALUES (
        @s,
        @s,
        @Base,
        @Bonus,
        @Deduction,
        DATEADD(DAY, -1 * (ABS(CHECKSUM(NEWID())) % 30), GETDATE())
    );
    SET @s += 1;
END;





CREATE TABLE EmployeeAttendance (
    AttendanceID INT PRIMARY KEY,
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CheckInTime DATETIME,
    CheckOutTime DATETIME,
    TotalHours AS DATEDIFF(HOUR, CheckInTime, CheckOutTime)
);

DECLARE @ea INT = 1;
WHILE @ea <= 400
BEGIN
    DECLARE @EmpID INT = 1 + (@ea % 200);
    DECLARE @CheckIn DATETIME = DATEADD(HOUR, 9, DATEADD(DAY, -1 * (@ea % 30), GETDATE()));
    DECLARE @CheckOut DATETIME = DATEADD(HOUR, 9 + (7 + (@ea % 3)), DATEADD(DAY, -1 * (@ea % 30), GETDATE()));

    INSERT INTO EmployeeAttendance
    VALUES (
        @ea,
        @EmpID,
        @CheckIn,
        @CheckOut
    );
    SET @ea += 1;
END;


--Investments, Insurance & Merchants Batch



CREATE TABLE Investments (
    InvestmentID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    InvestmentType VARCHAR(50),
    Amount DECIMAL(18,2),
    ROI DECIMAL(5,2),
    MaturityDate DATE
);

DECLARE @inv INT = 1;
WHILE @inv <= 300
BEGIN
    INSERT INTO Investments
    VALUES (
        @inv,
        1 + (@inv % 1500),
        CASE WHEN @inv % 3 = 0 THEN 'Fixed Deposit'
             WHEN @inv % 3 = 1 THEN 'Mutual Fund'
             ELSE 'Government Bond' END,
        ROUND(1000 + (RAND() * 20000), 2),
        ROUND(2 + (RAND() * 10), 2),
        DATEADD(YEAR, 1 + (@inv % 5), GETDATE())
    );
    SET @inv += 1;
END;





CREATE TABLE StockTradingAccounts (
    AccountID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    BrokerageFirm VARCHAR(100),
    TotalInvested DECIMAL(18,2),
    CurrentValue DECIMAL(18,2)
);

DECLARE @sta INT = 1;
WHILE @sta <= 200
BEGIN
    DECLARE @invested DECIMAL(18,2) = ROUND(1000 + (RAND() * 15000), 2);
    INSERT INTO StockTradingAccounts
    VALUES (
        @sta,
        1 + (@sta % 1500),
        CASE WHEN @sta % 2 = 0 THEN 'Freedom Finance' ELSE 'Tinkoff Brokers' END,
        @invested,
        @invested + ROUND(-500 + (RAND() * 1000), 2)
    );
    SET @sta += 1;
END;




CREATE TABLE ForeignExchange (
    FXID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CurrencyPair VARCHAR(20),
    ExchangeRate DECIMAL(10,4),
    AmountExchanged DECIMAL(18,2)
);

DECLARE @fx INT = 1;
WHILE @fx <= 200
BEGIN
    INSERT INTO ForeignExchange
    VALUES (
        @fx,
        1 + (@fx % 1500),
        CASE WHEN @fx % 3 = 0 THEN 'USD/UZS'
             WHEN @fx % 3 = 1 THEN 'EUR/USD'
             ELSE 'USD/RUB' END,
        ROUND(1000 + (RAND() * 2000), 4),
        ROUND(100 + (RAND() * 5000), 2)
    );
    SET @fx += 1;
END;





CREATE TABLE InsurancePolicies (
    PolicyID INT PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    InsuranceType VARCHAR(50),
    PremiumAmount DECIMAL(18,2),
    CoverageAmount DECIMAL(18,2)
);

DECLARE @ip INT = 1;
WHILE @ip <= 400
BEGIN
    INSERT INTO InsurancePolicies
    VALUES (
        @ip,
        1 + (@ip % 1500),
        CASE WHEN @ip % 3 = 0 THEN 'Health'
             WHEN @ip % 3 = 1 THEN 'Auto'
             ELSE 'Life' END,
        ROUND(10 + (RAND() * 50), 2),
        ROUND(1000 + (RAND() * 9000), 2)
    );
    SET @ip += 1;
END;





CREATE TABLE Claims (
    ClaimID INT PRIMARY KEY,
    PolicyID INT FOREIGN KEY REFERENCES InsurancePolicies(PolicyID),
    ClaimAmount DECIMAL(18,2),
    Status VARCHAR(20),
    FiledDate DATE
);

DECLARE @cl INT = 1;
WHILE @cl <= 150
BEGIN
    INSERT INTO Claims
    VALUES (
        @cl,
        1 + (@cl % 400),
        ROUND(100 + (RAND() * 3000), 2),
        CASE WHEN @cl % 4 = 0 THEN 'Pending'
             WHEN @cl % 4 = 1 THEN 'Approved'
             WHEN @cl % 4 = 2 THEN 'Rejected'
             ELSE 'In Review' END,
        DATEADD(DAY, -1 * (@cl % 180), GETDATE())
    );
    SET @cl += 1;
END;





CREATE TABLE UserAccessLogs (
    LogID INT PRIMARY KEY,
    UserID INT FOREIGN KEY REFERENCES OnlineBankingUsers(UserID),
    ActionType VARCHAR(50),
    Timestamp DATETIME
);

DECLARE @log INT = 1;
WHILE @log <= 300
BEGIN
    INSERT INTO UserAccessLogs
    VALUES (
        @log,
        1 + (@log % 800),
        CASE WHEN @log % 3 = 0 THEN 'Login'
             WHEN @log % 3 = 1 THEN 'Transfer'
             ELSE 'BillPayment' END,
        DATEADD(MINUTE, -1 * (@log * 3), GETDATE())
    );
    SET @log += 1;
END;






CREATE TABLE CyberSecurityIncidents (
    IncidentID INT PRIMARY KEY,
    AffectedSystem VARCHAR(100),
    ReportedDate DATE,
    ResolutionStatus VARCHAR(50)
);

DECLARE @inc INT = 1;
WHILE @inc <= 30
BEGIN
    INSERT INTO CyberSecurityIncidents
    VALUES (
        @inc,
        CASE WHEN @inc % 3 = 0 THEN 'OnlineBanking'
             WHEN @inc % 3 = 1 THEN 'ATM Network'
             ELSE 'Core Database' END,
        DATEADD(DAY, -1 * (@inc * 3), GETDATE()),
        CASE WHEN @inc % 4 = 0 THEN 'Resolved'
             WHEN @inc % 4 = 1 THEN 'In Progress'
             WHEN @inc % 4 = 2 THEN 'Under Investigation'
             ELSE 'Escalated' END
    );
    SET @inc += 1;
END;





CREATE TABLE Merchants (
    MerchantID INT PRIMARY KEY,
    MerchantName VARCHAR(100),
    Industry VARCHAR(100),
    Location VARCHAR(100),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
);

DECLARE @m INT = 1;
WHILE @m <= 100
BEGIN
    INSERT INTO Merchants
    VALUES (
        @m,
        CONCAT('Merchant_', @m),
        CASE WHEN @m % 3 = 0 THEN 'Retail'
             WHEN @m % 3 = 1 THEN 'Food & Beverage'
             ELSE 'Transport' END,
        CASE WHEN @m % 2 = 0 THEN 'Tashkent' ELSE 'Samarkand' END,
        1 + (@m % 1500)
    );
    SET @m += 1;
END;






CREATE TABLE MerchantTransactions (
    TransactionID INT PRIMARY KEY,
    MerchantID INT FOREIGN KEY REFERENCES Merchants(MerchantID),
    Amount DECIMAL(18,2),
    PaymentMethod VARCHAR(50),
    [Date] DATE
);

DECLARE @mt INT = 1;
WHILE @mt <= 300
BEGIN
    INSERT INTO MerchantTransactions
    VALUES (
        @mt,
        1 + (@mt % 100),
        ROUND(50 + (RAND() * 1000), 2),
        CASE WHEN @mt % 2 = 0 THEN 'POS' ELSE 'Online' END,
        DATEADD(DAY, -1 * (@mt % 60), GETDATE())
    );
    SET @mt += 1;
END;

--
select * from customers
select * from branches
select * from employees
select * from accounts
select * from transactions
--Digital Banking Batch
select * from CreditCards
select * from CreditCardTransactions
select * from OnlineBankingUsers
select * from BillPayments
select * from MobileBankingTransactions
--Loans and Credit Batch
select * from Loans
select * from LoanPayments
select * from CreditScores
select * from DebtCollection
--Compliance & Risk Batch
select * from KYC
select * from FraudDetection
select * from AMLCases
select * from RegulatoryReports
--HR & Payroll  Batch
select * from Departments
select * from Salaries
select * from EmployeeAttendance
--Investments, Insurance & Merchants Batch
select * from Investments
select * from StockTradingAccounts
select * from ForeignExchange
select * from InsurancePolicies
select * from Claims
select * from UserAccessLogs
select * from CyberSecurityIncidents
select * from Merchants
select * from MerchantTransactions

use project_1


--1. Top 3 Customers with the Highest Total Balance Across All Accounts 
WITH RankedBalances AS (
    SELECT 
        a.CustomerID,
        SUM(a.Balance) AS TotalBalance,
        RANK() OVER (ORDER BY SUM(a.Balance) DESC) AS BalanceRank
    FROM Accounts a
    GROUP BY a.CustomerID
)
SELECT 
    c.FullName,
    rb.TotalBalance,
    rb.BalanceRank
FROM RankedBalances rb
JOIN Customers c ON rb.CustomerID = c.CustomerID
WHERE rb.BalanceRank <= 3
ORDER BY rb.BalanceRank, rb.TotalBalance DESC;

-----------------------------------------------------------------

--2. Customers Who Have More Than One Active Loan
SELECT 
    c.FullName,
    COUNT(*) AS ActiveLoanCount
FROM Loans AS l
JOIN Customers AS c 
ON l.CustomerID = c.CustomerID
WHERE l.Status = 'Active'
GROUP BY c.FullName
HAVING COUNT(*) > 1
ORDER BY ActiveLoanCount DESC;



-----------------------------------------------

--3.Transactions That Were Flagged as Fraudulent
SELECT 
    f.FraudID,
    f.TransactionID,
    t.AccountID,
    t.Amount,
    t.Date,
    t.Status AS TransactionStatus,
    f.RiskLevel,
    f.ReportedDate,
    c.CustomerID,
    c.FullName
FROM FraudDetection f
JOIN Transactions t ON f.TransactionID = t.TransactionID
JOIN Customers c ON f.CustomerID = c.CustomerID
ORDER BY 
    CASE f.RiskLevel
        WHEN 'High' THEN 3
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 1
        ELSE 0
    END DESC,
    f.ReportedDate DESC;


---------------------------------------------------------
--4. Total Loan Amount Issued Per Branch
SELECT 
    b.BranchID,
    b.BranchName,
    SUM(l.Amount) AS TotalLoanAmount
FROM Loans AS l
JOIN Accounts AS a ON l.CustomerID = a.CustomerID
JOIN Branches AS b ON a.BranchID = b.BranchID
GROUP BY b.BranchID, b.BranchName
ORDER BY TotalLoanAmount DESC;


----------------------------------------------

--5. Customers who made multiple large transactions (above $10,000) within a short time frame (less than 1 hour apart)
INSERT INTO Transactions (TransactionID, AccountID, Amount, Date, Status)
VALUES 
(4001, 1002, 12500, '2025-07-19 08:00:00', 'Completed'),
(4002, 1002, 13500, '2025-07-19 08:30:00', 'Completed'),
(4003, 1002, 14500, '2025-07-19 08:50:00', 'Completed'),
(4004, 1002, 15500, '2025-07-19 09:10:00', 'Completed');

SELECT 
    c.FullName,
    a.CustomerID,
    COUNT(*) AS SuspiciousPairs
FROM Transactions AS t1
JOIN Transactions AS t2
  ON t1.AccountID = t2.AccountID
  AND t1.TransactionID < t2.TransactionID
  AND t1.Amount > 10000
  AND t2.Amount > 10000
  AND ABS(DATEDIFF(MINUTE, t1.Date, t2.Date)) < 60
JOIN Accounts AS a ON t1.AccountID = a.AccountID
JOIN Customers AS c ON a.CustomerID = c.CustomerID
GROUP BY a.CustomerID, c.FullName
HAVING COUNT(*) >= 1
ORDER BY SuspiciousPairs DESC;
---------------------------------------------------------

--6. Customers who have made transactions from different countries within 10 minutes, a common red flag for fraud.
INSERT INTO Accounts (
    AccountID, CustomerID, BranchID, AccountType, CreatedDate, Status
)
VALUES (
    3001,       
    1003,       
    3,           
    'Savings',
    '2025-07-19',
    'Active'
);
INSERT INTO Transactions (
    TransactionID, Date, Amount, AccountID, Status
)
VALUES (
    4005,                            
    '2025-07-19 08:07:00.000',      
    16500.00,
    3001,                           
    'Completed'
);
UPDATE Accounts
SET BranchID = 4
WHERE AccountID = 3001;
--Query
SELECT 
    c.CustomerID,
    c.FullName,
    b1.City AS FromCity,
    b2.City AS ToCity,
    t1.TransactionID AS Txn1,
    t2.TransactionID AS Txn2,
    t1.Date AS Time1,
    t2.Date AS Time2,
    DATEDIFF(MINUTE, t1.Date, t2.Date) AS MinutesBetween
FROM Transactions t1
JOIN Transactions t2 
  ON t1.TransactionID < t2.TransactionID
  AND ABS(DATEDIFF(MINUTE, t1.Date, t2.Date)) <= 10
JOIN Accounts a1 ON t1.AccountID = a1.AccountID
JOIN Accounts a2 ON t2.AccountID = a2.AccountID
JOIN Customers c 
  ON a1.CustomerID = c.CustomerID AND a2.CustomerID = c.CustomerID
JOIN Branches b1 ON a1.BranchID = b1.BranchID
JOIN Branches b2 ON a2.BranchID = b2.BranchID
WHERE b1.City <> b2.City;

--------------------------------------
----Extra KPI 

--Pairs of suspicious transactions (for Charlotte Lopez):
SELECT 
    t1.TransactionID AS TransactionID_1,
    t1.Date AS Date_1,
    t1.Amount AS Amount_1,
    t2.TransactionID AS TransactionID_2,
    t2.Date AS Date_2,
    t2.Amount AS Amount_2,
    DATEDIFF(MINUTE, t1.Date, t2.Date) AS TimeDifferenceMinutes,
    c.FullName,
    a.AccountID
FROM Transactions AS t1
JOIN Transactions AS t2
    ON t1.AccountID = t2.AccountID
    AND t1.TransactionID < t2.TransactionID
    AND t1.Amount > 10000
    AND t2.Amount > 10000
    AND ABS(DATEDIFF(MINUTE, t1.Date, t2.Date)) < 60
JOIN Accounts AS a ON t1.AccountID = a.AccountID
JOIN Customers AS c ON a.CustomerID = c.CustomerID
WHERE c.FullName = 'Charlotte Lopez'
ORDER BY t1.Date, t2.Date;

--Employee Attendance Rate
SELECT 
  e.EmployeeID,
  e.FullName,
  COUNT(*) AS TotalDays,
  COUNT(CASE WHEN ea.TotalHours >= 8 THEN 1 END) AS FullDaysWorked,
  ROUND(100.0 * COUNT(CASE WHEN ea.TotalHours >= 8 THEN 1 END) / COUNT(*), 1) AS AttendanceRate
FROM Employees e
JOIN EmployeeAttendance ea 
  ON e.EmployeeID = ea.EmployeeID
GROUP BY e.EmployeeID, e.FullName
ORDER BY e.EmployeeID;


--Number of reports by month
 select * from RegulatoryReports

SELECT 
    FORMAT(SubmissionDate, 'yyyy-MM') AS ReportMonth,
    COUNT(*) AS ReportsSubmitted
FROM RegulatoryReports
GROUP BY FORMAT(SubmissionDate, 'yyyy-MM')
ORDER BY ReportMonth;

--Inactive Customers (No Transactions in Last 6 Months)
--Odina Turdiyeva
select distinct c.FullName
from customers as c
join accounts as a
on c.CustomerID=a.customerID
where not exists (
select 1 from Transactions as t 
where t.AccountID=a.AccountID
and t.date>dateadd(month, -6, getdate()))

--Number of clients served
--Ibrohim Mahmudov
SELECT 
    b.BranchID,
    b.BranchName,
    COUNT(DISTINCT a.CustomerID) AS CustomerCount
FROM Branches b
JOIN Accounts a ON b.BranchID = a.BranchID
GROUP BY b.BranchID, b.BranchName;

--Credit Score Category Analysis
--Shaxnoza Turabova
SELECT
  CASE
    WHEN CreditScore BETWEEN 300 AND 579 THEN 'Very Poor'
    WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
    WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
    WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
    WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
    ELSE 'Unknown'
  END AS CreditRatingCategory,
  COUNT(*) AS NumberOfCustomers,
  ROUND(AVG(CreditScore), 1) AS AverageScore
FROM CreditScores
GROUP BY
  CASE
    WHEN CreditScore BETWEEN 300 AND 579 THEN 'Very Poor'
    WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
    WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
    WHEN CreditScore BETWEEN 740 AND 799 THEN 'Very Good'
    WHEN CreditScore BETWEEN 800 AND 850 THEN 'Excellent'
    ELSE 'Unknown'
  END
ORDER BY AverageScore;


--Mobile Transactions by Type
--Shaxnoza Turabova
SELECT 
    TransactionType,
    COUNT(*) AS TransactionCount,
    SUM(Amount) AS TotalAmount,
    ROUND(AVG(Amount), 2) AS AvgAmount
FROM MobileBankingTransactions
GROUP BY TransactionType
ORDER BY TransactionCount DESC;

--NPL — Non-Performing Loans
--Shaxnoza Turabova
SELECT 
    COUNT(*) AS TotalLoans,
    COUNT(CASE WHEN Status = 'Closed' THEN 1 END) AS ClosedLoans,
    COUNT(CASE WHEN Status = 'Closed' AND RemainingBalance > 0 THEN 1 END) AS UnpaidClosedLoans,
    ROUND(100.0 * COUNT(CASE WHEN Status = 'Closed' AND RemainingBalance > 0 THEN 1 END) / COUNT(*), 2) AS NPL_Ratio_Percent
FROM Loans L
LEFT JOIN LoanPayments LP ON L.LoanID = LP.LoanID;

--Find the Top 3 Customers (whose names start with 'A') with the Highest Total Savings Balance
--Ozodbek Ochilov
SELECT TOP 3
    c.CustomerID,
    c.FullName,
    SUM(a.Balance) AS TotalBalance
FROM Accounts AS a
JOIN Customers AS c
ON a.CustomerID = c.CustomerID
WHERE a.AccountType = 'Savings'
  AND c.FullName LIKE 'A%'
GROUP BY c.CustomerID, c.FullName
ORDER BY TotalBalance DESC;

--Customers with High ATM Withdrawal Frequency in a Short Period
--Mirjalol Anorboyev

SELECT 
    c.CustomerID,
    c.FullName,
    CAST(t.Date AS DATE) AS WithdrawalDate,
    COUNT(*) AS WithdrawalCount
FROM Transactions AS t
JOIN Accounts AS a ON t.AccountID = a.AccountID
JOIN Customers AS c ON a.CustomerID = c.CustomerID
WHERE t.TransactionType = 'ATM Withdrawal'
GROUP BY 
    c.CustomerID,
    c.FullName,
    CAST(t.Date AS DATE)
HAVING COUNT(*) > 3 --filtering for customers who made more than 3 ATM withdrawals in a single day.
ORDER BY WithdrawalCount DESC;
