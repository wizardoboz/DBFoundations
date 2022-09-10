```
--**********************************************************************************************--
-- Title: ITFnd130Final
-- Author: KBoswell
-- Desc: This file demonstrates how to design and create 
--       tables, views, and stored procedures
-- Change Log: When,Who,What
-- 2022-09-01, KBoswell, Created File
-- 2022-09-01 - 2022-09-09, KBoswell, Modified File
-- 2022-09-09, KBoswell, Completed File
--***********************************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'ITFnd130FinalDB_KBoswell')
	 Begin 
	  Alter Database [ITFnd130FinalDB_KBoswell] set Single_user With Rollback Immediate;
	  Drop Database ITFnd130FinalDB_KBoswell;
	 End
	Create Database ITFnd130FinalDB_KBoswell;
End Try
Begin Catch
	Print Error_Number();
End Catch
Go

Use ITFnd130FinalDB_KBoswell;

-- Create Tables-- 
Create Table Courses
	([CourseID] int NOT NULL Identity(1,1)
	,[CourseName] nvarchar(100) NOT NULL
	,[StartDate] date NOT NULL
	,[EndDate] date NOT NULL
	,[MeetingPattern] nvarchar(100) NOT NULL
	,[StartTime] time NOT NULL
	,[EndTime] time NOT NULL
	,[CurrentUSDPrice] money NULL
	);
Go

Create Table Students
	([StudentID] int NOT NULL Identity(1,1)
	,[DisplayID] nvarchar(20) NOT NULL
	,[LastName] nvarchar(100) NOT NULL
	,[FirstName] nvarchar(100) NOT NULL
	,[Email] nvarchar(100) NOT NULL
	,[Phone] nchar(10) NOT NULL
	,[StreetAddress] nvarchar(100) NOT NULL
	,[City] nvarchar(100) NOT NULL
	,[State] nchar(2) NOT NULL
	,[Zip] nchar(10) NOT NULL
	);
Go

Create Table Registrations
	([RegID] int NOT NULL Identity(1,1)
	,[CourseID] int NOT NULL
	,[StudentID] int NOT NULL
	,[RegDate] date NOT NULL
	,[CourseDiscount] money NULL
	,[CourseUSDPayment] money NULL
	);
Go
	

--ADD CONSTRAINTS TO COURSES TABLE 
--Add Primary Key 
Alter Table dbo.Courses
	Add Constraint PKCourses 
	Primary Key Clustered (CourseID);
Go
--Create Function for GetStartDate so that a constraint can be added to make sure
--end date is always greater than or equal to start date.
Create Function dbo.fGetCourseStartDate (@CourseID int)
Returns DateTime
As
Begin
	Return	(Select Courses.StartDate
			From Courses
			Where Courses.CourseID = @CourseID);
	End
Go
--Test the Function
--Select dbo.fGetCourseStartDate(1);
--Select IIF(Cast('1/1/2020 07:00:00' as datetime) < dbo.fGetCourseStartDate(1), 
--'True', 'False'), 'Before Start';
--Select IIF(Cast('1/1/2020 11:00:00' as datetime) < dbo.fGetCourseStartDate(1), 
--'True', 'False'), 'After Start';
--Go

--Add check constraint that makes sure end date is greater than or equal to start date
Alter Table Courses
	Add Constraint ckEndDateGreaterthanEqualtoStartDate
	Check(EndDate >= dbo.fGetCourseStartDate(CourseID));
Go
--Add check constraint to ensure unique CourseName
Alter Table dbo.Courses 
	Add Constraint uCourseName 
	Unique NonClustered (CourseName);
Go
--Add Constraint to CurrentUSDPrice so that price cannot be below zero.
Alter Table dbo.Courses
	Add Constraint ckCurrentUSDPrice 
	Check([CurrentUSDPrice] >= 0);
Go


--ADD CONSTRAINTS TO STUDENTS TABLE
--Add Primary Key
Alter Table dbo.Students
	Add Constraint PKStudentID 
	Primary Key Clustered (StudentID);
Go
--Add Unique DisplayID
Alter Table dbo.Students 
	Add Constraint uDisplayID 
	Unique NonClustered (DisplayID);
Go
--Add Check Constraint for Unique Email Address
Alter Table dbo.Students
	Add Constraint uEmailAddress
	Unique NonClustered (Email);
Go
--Add Check Constraint for Valid Email Address 
Alter Table dbo.Students
	Add Constraint ckValidEmail 
	Check(Email like '%_@_%._%');
Go



--ADD CONSTRAINTS TO REGISTRATIONS TABLE
--Add Primary Key
Alter Table dbo.Registrations
	Add Constraint PKRegistrations 
	Primary Key Clustered (RegID);
Go
--Add Foreign Key CourseID that References Courses Table
Alter Table dbo.Registrations
	Add Constraint fkCourseRegistrations
	Foreign Key (CourseID)
	References dbo.Courses (CourseID);
Go
--Add Foreign Key of Student ID that references Students Table
Alter Table dbo.Registrations
	Add Constraint fkStudentRegistrations
	Foreign Key (StudentID)
	References dbo.Students (StudentID);
Go
--Add Default Constraint to Registration Date to Return Default of Today When Registering
Alter Table dbo.Registrations
	Add Constraint dfRegDate 
	Default getdate()
	For RegDate;
Go
--Add Check Constraint to Make Sure Discounts Are Entered as Deductions Against Charges
Alter Table dbo.Registrations
	Add Constraint ckDiscountsShowSubtract 
	Check([CourseDiscount] <0);
Go

--Add Check Constraint to Make Sure Payments are Entered as Deductions Against Charges
Alter Table dbo.Registrations
	Add Constraint ckPaymentsShowSubtract 
	Check([CourseUSDPayment] <0);
Go

--Add Constraint that Stops a Student from Registering For a Course that Started Yesterday
Alter Table Registrations
	Add Constraint ckNoRegIfCourseStartedYesterday
	Check(RegDate <= dbo.fGetCourseStartDate(CourseID));
Go



-- Add Views-- 
Create View vCourses With SchemaBinding
As
Select 
	 [CourseID]
	,[CourseName]
	,[StartDate]
	,[EndDate]
	,[MeetingPattern]
	,[StartTime]
	,[EndTime]
	,[CurrentUSDPrice]
From dbo.Courses;
Go

Create View vStudents With SchemaBinding
As
Select
	 [StudentID]
	,[DisplayID]
	,[LastName]
	,[FirstName]
	,[Email]
	,[Phone]
	,[StreetAddress]
	,[City]
	,[State]
	,[Zip]
From dbo.Students;
Go

Create View vRegistrations with SchemaBinding
As
Select
	 [RegId]
	,[CourseID]
	,[StudentID]
	,[RegDate]
	,[CourseDiscount]
	,[CourseUSDPayment]
From dbo.Registrations 
Go

Create View vAllCoursesStudentsRegistrations
as
Select Top 10000
	 c.[CourseID]
	,c.[CourseName]
	,c.[StartDate]
	,c.[EndDate]
	,c.[MeetingPattern]
	,c.[StartTime]
	,c.[EndTime]
	,c.[CurrentUSDPrice]
	,s.[StudentID]
	,s.[DisplayID]
	,s.[LastName]
	,s.[FirstName]
	,s.[Email]
	,s.[Phone]
	,s.[StreetAddress]
	,s.[City]
	,s.[State]
	,s.[Zip]
	,r.[RegID]
	,r.[RegDate]
	,r.[CourseDiscount]
	,r.[CourseUSDPayment]
From vRegistrations as r
	Inner Join vStudents as s
	on r.StudentID = s.StudentID
	Inner Join vCourses as c
	on r.CourseID = c.CourseID
Order By 1,2,3;
Go
	
--< Test Tables by adding Sample Data >--  
Insert Into Courses
	([CourseName]
	,[StartDate]
	,[EndDate]
	,[MeetingPattern]
	,[StartTime]
	,[EndTime]
	,[CurrentUSDPrice])
Values
	('SQL1-Winter 2017'
	,'2017-01-10'
	,'2017-01-24'
	,'T'
	,'18:00'
	,'20:50'
	,399
	)
	,('SQL2-Winter 2017'
	,'2017-01-31'
	,'2017-02-14'
	,'T'
	,'18:00'
	,'20:50'
	,399
	);
Go

Insert into Students
	([DisplayID]
	,[LastName]
	,[FirstName]
	,[Email]
	,[Phone]
	,[StreetAddress]
	,[City]
	,[State]
	,[Zip])
Values
	('B-Smith-071'
	,'Smith'
	,'Bob'
	,'bsmith@hipmail.com'
	,'2061112222'
	,'123 Main St.'
	,'Seattle'
	,'WA'
	,'98001'
	)
	,('S-Jones-003'
	,'Jones'
	,'Sue'
	,'suejones@yayou.com'
	,'2062314321'
	,'333 1st Ave.'
	,'Seattle'
	,'WA'
	,'98001'
	);
Go

Insert into Registrations
	([CourseID]
	,[StudentID]
	,[RegDate]
	,[CourseDiscount]
	,[CourseUSDPayment]
	)
Values
	(1
	,1
	,'2017-01-03'
	,Null
	,-399
	)
	,(2
	,1
	,'2017-01-12'
	,Null
	,-399
	)
	,(1
	,2
	,'2016-12-14'
	,-50
	,-349
	)
	,(2
	,2
	,'2016-12-14'
	,-50
	,-349
	);
Go	
--Test Constraints That Have Functions (Note to Self: can only be done
--after data is inserted due to FK constraints)
--Insert Into Registrations
--	(CourseID
--	,StudentID
--	,RegDate)
--Values
--	(2
--	,1
--	,'2023-02-15')
--Go
--The above statement failed, which was to be expected. Enter RegDate prior to start date
--and the function works:
--TEST THE DATABASE SO FAR:
--select * from vcourses;
--select * from vstudents;
--select * from vregistrations;
--select * from vAllCoursesStudentsRegistrations;



--*****************************************************************************************************
-- Add Stored Procedures--

--************************************************
--Sprocs for Courses
--************************************************
--Create Sproc for Inserting Data into Courses
go
Create or Alter Procedure pInsCourses
	(@CourseName nvarchar(100)
	,@StartDate date
	,@EndDate date
	,@MeetingPattern nvarchar(100)
	,@StartTime time
	,@EndTime time
	,@CurrentUSDPrice money
	)
 -- Author: KBoswell
 -- Desc: Processes inserts into Courses
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Courses
	 ([CourseName]
	 ,[StartDate]
	 ,[EndDate]
	 ,[MeetingPattern]
	 ,[StartTime]
	 ,[EndTime]
	 ,[CurrentUSDPrice])
	Values
	 (@CourseName
	 ,@StartDate
	 ,@EndDate
	 ,@MeetingPattern
	 ,@StartTime
	 ,@EndTime
	 ,@CurrentUSDPrice)
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Sproc for Updating Courses
Create or Alter Procedure pUpdCourses
	(@CourseID int
	,@CourseName nvarchar(100)
	,@StartDate date
	,@EndDate date
	,@MeetingPattern nvarchar(100)
	,@StartTime time
	,@EndTime time
	,@CurrentUSDPrice money
	)
 -- Author: KBoswell
 -- Desc: Processes updates into Courses
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare 
	@RC int = 0;
  Begin Try
   Begin Transaction 
		Update Courses
		Set 
		 [CourseName] = @CourseName
		,[StartDate] = @StartDate
		,[EndDate] = @EndDate
		,[MeetingPattern] = @MeetingPattern
		,[StartTime] = @StartTime 
		,[EndTime] = @EndTime
		,[CurrentUSDPrice] = @CurrentUSDPrice 
		Where [CourseID] = @CourseID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Sproc for deleting courses
Create or Alter Procedure pDelCourses
 (@CourseID int)
 -- Author: KBoswell
 -- Desc: Processes deletes into Courses
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare 
	@Status int = 0;
  Begin Try
   Begin Transaction 
		Delete From Courses
		Where [CourseID] = @CourseID
   Commit Transaction
   Set @Status = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @Status = -1
  End Catch
  Return @Status;
 End
go
--*********************************************
--Sprocs for Students
--*********************************************
--Create Sproc for Inserting Data into Students
Create or Alter Procedure pInsStudents
	(@DisplayID nvarchar(20)
	,@LastName nvarchar(100)
	,@FirstName nvarchar(100)
	,@Email nvarchar(100)
	,@Phone nchar(10)
	,@StreetAddress nvarchar(100)
	,@City nvarchar(100)
	,@State nchar(2)
	,@Zip nchar(10)
	)
 -- Author: KBoswell
 -- Desc: Processes inserts into Students
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Students
	 ([DisplayID]
	 ,[LastName]
	 ,[FirstName]
	 ,[Email]
	 ,[Phone]
	 ,[StreetAddress]
	 ,[City]
	 ,[State]
	 ,[Zip]
	 )
	Values
	 (@DisplayID
	 ,@LastName
	 ,@FirstName
	 ,@Email
	 ,@Phone
	 ,@StreetAddress
	 ,@City
	 ,@State
	 ,@Zip
	 )
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Sproc for Updating Students
Create or Alter Procedure pUpdStudents
	 (@StudentID int
	 ,@DisplayID nvarchar(100)
	 ,@LastName nvarchar(100)
	 ,@FirstName nvarchar(100)
	 ,@Email nvarchar(100)
	 ,@Phone nchar(10)
	 ,@StreetAddress nvarchar(100)
	 ,@City nvarchar(100)
	 ,@State nchar(2)
	 ,@Zip nchar(10)
	)
 -- Author: KBoswell
 -- Desc: Processes updates into Students
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare 
	@RC int = 0;
  Begin Try
   Begin Transaction 
		Update Students
		Set 
		 [DisplayID] = @DisplayID
		,[LastName] = @LastName
		,[FirstName] = @FirstName
		,[Email] = @Email
		,[Phone] = @Phone
		,[StreetAddress] = @StreetAddress
		,[City] = @City
		,[State] = @State
		,[Zip] = @Zip
		Where [StudentID] = @StudentID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Sproc for deleting Students
Create or Alter Procedure pDelStudents
 (@StudentID int)
 -- Author: KBoswell
 -- Desc: Processes deletes into Students
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare 
	@Status int = 0;
  Begin Try
   Begin Transaction 
		Delete From Students
		Where StudentID = @StudentID
   Commit Transaction
   Set @Status = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @Status = -1
  End Catch
  Return @Status;
 End
go


--*********************************************
--Sprocs for Registrations
--*********************************************
--Create Sproc for Inserting Data into Registrations
Create or Alter Procedure pInsRegistrations
	(@CourseID int
	,@StudentID int
	,@RegDate date
	,@CourseDiscount money
	,@CourseUSDPayment money
	)
 -- Author: KBoswell
 -- Desc: Processes inserts into Registrations
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare @RC int = 0;
  Begin Try
   Begin Transaction 
	Insert Into Registrations
	 ([CourseID]
	 ,[StudentID]
	 ,[RegDate]
	 ,[CourseDiscount]
	 ,[CourseUSDPayment]
	 )
	Values
	 (@CourseID
	 ,@StudentID
	 ,@RegDate
	 ,@CourseDiscount
	 ,@CourseUSDPayment
	 )
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Sproc for Updating Registrations
Create or Alter Procedure pUpdRegistrations
	 (@RegID int
	 ,@CourseID int
	 ,@StudentID int
	 ,@RegDate date
	 ,@CourseDiscount money
	 ,@CourseUSDPayment money
	)
 -- Author: KBoswell
 -- Desc: Processes updates into Registrations
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare 
	@RC int = 0;
  Begin Try
   Begin Transaction 
		Update Registrations
		Set 
		 [CourseID] = @CourseID
		,[StudentID] = @StudentID
		,[RegDate] = @RegDate
		,[CourseDiscount] = @CourseDiscount
		,[CourseUSDPayment] = @CourseUSDPayment
		Where [RegID] = @RegID
   Commit Transaction
   Set @RC = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
 End
go

--Create Sproc for deleting Registrations
Create or Alter Procedure pDelRegistrations
 (@RegID int)
 -- Author: KBoswell
 -- Desc: Processes deletes into Registrations
 -- Change Log: When,Who,What
 -- 2022-09-08, KBoswell, Created Sproc.
 -- 2022-09-09, KBoswell, Completed Sproc.
AS
 Begin
  Declare 
	@Status int = 0;
  Begin Try
   Begin Transaction 
		Delete From Registrations
		Where [RegID] = @RegID
   Commit Transaction
   Set @Status = +1
  End Try
  Begin Catch
   Rollback Transaction
   Print Error_Message()
   Set @Status = -1
  End Catch
  Return @Status;
 End
go

-- Set Permissions --

Deny Select on Courses to Public;
Grant Select on vCourses to Public;
Go

Deny Select on Students to Public;
Grant Select on vStudents to Public;
Go

Deny Select on Registrations to Public;
Grant Select on vRegistrations to Public;
Go

--***********************************
--Test Insert Sprocs
--***********************************

-- Test [dbo].[pInsCourses]
Declare @Status int;
Exec @Status =	pInsCourses
				 @CourseName = 'TestCourseInsertSproc'
				,@StartDate = '2018-01-10'
				,@EndDate = '2018-01-24'
				,@MeetingPattern = 'T'
				,@StartTime = '12:00'
				,@EndTime = '13:00'
				,@CurrentUSDPrice = 399
				Select Case @Status
  When +1 Then 'Courses Insert was successful!'
  When -1 Then 'Courses Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vCourses;
go

-- Test [dbo].[pInsStudents]
Declare @Status int;
Exec @Status =	pInsStudents
				@DisplayID = 'TestStudentInsertSproc'
				,@LastName = 'Student'
				,@FirstName = 'Test'
				,@Email = 'teststudent@hipmail.com'
				,@Phone = '5091112222'
				,@StreetAddress = '456 Main Street'
				,@City = 'Seattle'
				,@State = 'WA'
				,@Zip = '98001'
Select Case @Status
  When +1 Then 'Students Insert was successful!'
  When -1 Then 'Students Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vStudents;
go

-- Test [dbo].[pInsRegistrations] 
Declare @Status int;
Exec @Status =	pInsRegistrations
				 @CourseID = 3
				,@StudentID = 3
				,@RegDate = '2018-01-03'
				,@CourseDiscount = Null
				,@CourseUSDPayment = -399
Select Case @Status
  When +1 Then 'Registrations Insert was successful!'
  When -1 Then 'Registrations Insert failed! Common Issues: Duplicate Data'
  End as [Status];
Select * From vRegistrations;
go

--****************************************
--Test Update Sprocs
--****************************************
-- Test [dbo].[pUpdCourses]
Declare @Status int;
Exec @Status =	pUpdCourses
				 @CourseID = 3
				,@CourseName = 'TestCourseUpdateSproc'
				,@StartDate = '2018-01-10'
				,@EndDate = '2018-01-24'
				,@MeetingPattern = 'T'
				,@StartTime = '12:00'
				,@EndTime = '13:00'
				,@CurrentUSDPrice = 399
				Select Case @Status
  When +1 Then 'Courses Update was successful!'
  When -1 Then 'Courses Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select * From vCourses;
go

-- Test [dbo].[pUpdStudents]
Declare @Status int;
Exec @Status =	pUpdStudents
				 @StudentID = 3
				,@DisplayID = 'TestStudentUpdSproc'
				,@LastName = 'Student'
				,@FirstName = 'Test'
				,@Email = 'teststudent@hipmail.com'
				,@Phone = '5091112222'
				,@StreetAddress = '456 Main Street'
				,@City = 'Seattle'
				,@State = 'WA'
				,@Zip = '98001'
Select Case @Status
  When +1 Then 'Students Update was successful!'
  When -1 Then 'Students Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select * From vStudents;
go

-- Test [dbo].[pUpdRegistrations] 
Declare @Status int;
Exec @Status =	pUpdRegistrations
				 @regID = 5
				,@CourseID = 3
				,@StudentID = 3
				,@RegDate = '2018-01-01'
				,@CourseDiscount = Null
				,@CourseUSDPayment = -399
Select Case @Status
  When +1 Then 'Registrations Update was successful!'
  When -1 Then 'Registrations Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  End as [Status];
Select * From vRegistrations;
go

--*********************************
--Test Delete Sprocs
--*********************************
-- Test [dbo].[pDelRegistrations]
Declare @Status int;
Exec @Status =	pDelRegistrations
				@RegID = 5
Select Case @Status
  When +1 Then 'Registrations Delete was successful!'
  When -1 Then 'Registrations Delete failed! Common Issues: Foreign Key Violation'
  End as [Status];
Select * From vRegistrations;
go

-- Test [dbo].[pDelStudents]
Declare @Status int;
Exec @Status =	pDelStudents
				@StudentID = 3
Select Case @Status
  When +1 Then 'Students Delete was successful!'
  When -1 Then 'Students Delete failed! Common Issues: Foreign Key Violation'
  End as [Status];
Select * From vStudents;
go

--Test [dbo].[pDelCourses]
Declare @Status int;
Exec @Status =	pDelCourses
				@CourseID = 3
Select Case @Status
  When +1 Then 'Courses Delete was successful!'
  When -1 Then 'Courses Delete failed! Common Issues: Foreign Key Violation'
  End as [Status];
Select * From vCourses;
go

```
