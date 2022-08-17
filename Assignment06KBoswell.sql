--*************************************************************************--
-- Title: Assignment06
-- Author: KBoswell
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-08-15,KBoswell,Created File
-- 2022-08-16,KBoswell,Modified File
-- 2022-08-17,Kboswell,Completed File
-- Github repository link: 
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KBoswell')
	 Begin 
	  Alter Database [Assignment06DB_KBoswell] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KBoswell;
	 End
	Create Database Assignment06DB_KBoswell;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KBoswell;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--Creating the view without schemabinding
--Go
--Create View vCategories
--	As
--	Select CategoryID, CategoryName
--	From dbo.Categories
--Go
--Select * From vCategories

--Create the view for Categories with schemabinding
Go
Create or Alter View vCategories
	With SchemaBinding
	As
	Select CategoryID, CategoryName
	From dbo.Categories
Go

--Create the view for Products with schemabinding
Go
Create or Alter View vProducts
	With SchemaBinding
	As
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products
Go

--Create the view for Employees with schemabinding
Go
Create or Alter View vEmployees
	With SchemaBinding
	As
	Select 
		EmployeeID, 
		EmployeeFirstName, 
		EmployeeLastName, 
		ManagerID
	From dbo.Employees
Go

--Create the view for Inventories with schemabinding
Go
Create or Alter View vInventories
	With SchemaBinding
	As
	Select 
		InventoryID, 
		InventoryDate, 
		EmployeeID, 
		ProductID, 
		Count
	From dbo.Inventories
Go

--Check the views for All
--Select * From vCategories
--Select * From vProducts
--Select * From vEmployees
--Select * From vInventories
--Go

--********************************************************************************************
--Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
--from each table, but can select data from each view?

--Create Public versus Private Views for each table
Deny Select on Categories to Public;
Grant Select on vCategories to Public;
Go

Deny Select on Products to Public;
Grant Select on vProducts to Public;
Go

Deny Select on Employees to Public;
Grant Select on vEmployees to Public;
Go

Deny Select on Inventories to Public;
Grant Select on vInventories to Public;
Go


--********************************************************************************************
--Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
--and the price of each product?
--Order the result by the Category and Product!

--Idnetify the tables 
--Select * From Categories
--Select * From Products

--Identify the columns 
--Select CategoryName From Categories
--Select ProductName From Products
--Select UnitPrice From Products

--Identify the Join
--Select CategoryName, ProductName, UnitPrice
--From Products
--Join Categories on Products.CategoryID = Categories.CategoryID

--Wrap the Select Statement in a View and add the alias and namespace of the tables
--Go
--Create or Alter View vCategoryNameProductNameUnitPrice
--As
--Select CategoryName, ProductName, UnitPrice
--From dbo.Products as p
--Join dbo.Categories as c on p.CategoryID = c.CategoryID;
--Go

--Check the view
--Select * From vCategoryNameProductNameUnitPrice

--Order the Results
--Go
--Create or Alter View vCategoryNameProductNameUnitPrice
--As
--Select Top 100000 
--CategoryName, 
--ProductName, 
--UnitPrice
--From dbo.Products as p
--Join dbo.Categories as c on p.CategoryID = c.CategoryID;
--Order By CategoryName, ProductName;
--Go

--Add Schema Binding 
Go
Create or Alter View vCategoryNameProductNameUnitPrice
	With SchemaBinding
	As
Select Top 100000 
	CategoryName, 
	ProductName, 
	UnitPrice
From dbo.Products as p
	Join dbo.Categories as c
	on p.CategoryID = c.CategoryID
	Order By CategoryName, ProductName;
Go

--Add Permissions
Grant Select on vCategorynameProductNameUnitPrice to Public;
Go

--Check the View
--Select * From vCategoryNameProductNameUnitPrice
--Go

--*****************************************************************************
--Question 4 (10% pts): How can you create a view to show a list of Product names 
--and Inventory Counts on each Inventory Date?
--Order the results by the Product, Date, and Count!

--Identify the tables 
--Select * From Products
--Select * From Inventories

--Identify the columns 
--Select ProductName From Products
--Select Count, InventoryDate From Inventories

--Identify the Join
--Select ProductName, InventoryDate, Count
--From Products
--Join Inventories on Products.ProductID = Inventories.ProductID

--Wrap the Select Statement in a View and add the namespace and alias of the tables
--Go
--Create or Alter View vProductNameDateCount
--As
--Select ProductName, InventoryDate, Count
--From dbo.Products as p
--Join dbo.Inventories as i on p.ProductID = i.ProductID;
--Go

--Check the view
--Select * From vProductNameDateCount

--Order the Results
--Go
--Create or Alter View vProductNameDateCount
--As
--Select Top 100000
--ProductName, InventoryDate, Count
--From dbo.Products as p
--Join dbo.Inventories as i on p.ProductID = i.ProductID
--Order By ProductName, InventoryDate, Count;
--Go

--Add Schema Binding
Go
Create or Alter View vProductNameDateCount
	With SchemaBinding
	As
Select Top 100000
	ProductName, 
	InventoryDate, 
	Count
From dbo.Products as p
Join dbo.Inventories as i on p.ProductID = i.ProductID
	Order By 
	ProductName, 
	InventoryDate, 
	Count;
Go

--Add Permissions
Grant Select on vProductNameDateCount to Public;
Go

--Check the View
--Select * From vProductNameDateCount

--**********************************************************************************
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Identify the tables:
--Select * From Inventories;
--Select * From Employees;
--Go

--Identify the columns:
--Select InventoryDate From Inventories;
--Select EmployeeFirstName, EmployeeLastName From Employees;

--Identify the Join:
--Select Distinct
--InventoryDate, EmployeeFirstName, EmployeeLastName
--From Inventories
--Join Employees On Employees.EmployeeID = Inventories.EmployeeID

--Concatenate the Employee names:
--Select Distinct
--InventoryDate,
--EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
--From Inventories
--Join Employees On Employees.EmployeeID = Inventories.EmployeeID

--Wrap the Select Statement in a View and add the namespace and alias of the tables
--Go
--Create or Alter View vInventoryDatebyEmployee 
--As
--Select Distinct
--i.InventoryDate,
--e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
--From dbo.Inventories as i
--Join dbo.Employees as e On e.EmployeeID = i.EmployeeID;
--Go

--Check the view
--Select * From vInventoryDatebyEmployee

--Order the Results
--Go
--Create or Alter View vInventoryDatebyEmployee 
--As
--Select Distinct Top 100000	
--i.InventoryDate,
--e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
--From dbo.Inventories as i
--Join dbo.Employees as e On e.EmployeeID = i.EmployeeID
--Order By InventoryDate;
--Go

--Add Schema Binding
Go
Create or Alter View vInventoryDatebyEmployee 
	With SchemaBinding
	As
Select Distinct Top 100000	
	i.InventoryDate,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
From dbo.Inventories as i
Join dbo.Employees as e On e.EmployeeID = i.EmployeeID
Order By InventoryDate;
Go

--Grant Permissions
Grant Select on vInventoryDatebyEmployee to Public;
Go

--Check the view
--Select * From vInventoryDatebyEmployee

--***********************************************************************************
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Identify Tables:
--Select * From Categories
--Select * From Products
--Select * From Inventories
--Go

--Identify Columns:
--Select CategoryName from Categories
--Select ProductName from Products
--Select InventoryDate, Count from Inventories
--Go

--Identify the Join:
--Select CategoryName, ProductName, InventoryDate, Count
--From Products
--Join Categories on Categories.CategoryID = Products.CategoryID
--Join Inventories on Products.ProductID = Inventories.ProductID
--Go

--Wrap the Select Statement in a View and add the namespace and alias of the tables
--Go
--Create or Alter View vCategoryNameProductNameDateCount
--As
--Select 
--CategoryName, 
--ProductName, 
--InventoryDate, 
--Count
--From Products as p
--Join Categories as c on c.CategoryID = p.CategoryID
--Join Inventories as i on p.ProductID = i.ProductID
--Go

--Order the results:
--Go
--Create or Alter View vCategoryNameProductNameDateCount
--As
--Select Top 10000
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count
--From dbo.Products as p
--	Join dbo.Categories as c on c.CategoryID = p.CategoryID
--	Join dbo.Inventories as i on p.ProductID = i.ProductID
--Order By 
--	CategoryName, 
--	ProductName, 
--	InventoryDate, 
--	Count
--Go

--Add Schema Binding
Go
Create or Alter View vCategoryNameProductNameDateCount
	With SchemaBinding
	As
Select Top 10000
	CategoryName, 
	ProductName, 
	InventoryDate, 
	Count
From dbo.Products as p
	Join dbo.Categories as c on c.CategoryID = p.CategoryID
	Join dbo.Inventories as i on p.ProductID = i.ProductID
Order By 
	CategoryName, 
	ProductName, 
	InventoryDate, 
	Count
Go

--Grant Permissions
Grant Select on vCategoryNameProductNameDateCount to Public;
Go

--Check the View
--Select * From vCategoryNameProductNameDateCount


--****************************************************************************************
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Identify the Tables:
--Select * From Categories
--Select * From Products
--Select * From Inventories
--Select * From Employees
--Go

--Identify the Columns:
--Select CategoryName From Categories
--Select ProductName From Products
--Select InventoryDate, Count From Inventories
--Select EmployeeFirstName, EmployeeLastName From Employees
--Go

--List how the columns are connected
--Category.CategoryID = Products.CategoryID
--Products.ProductID = Inventories.ProductID
--Inventories.EmployeeID = Employees.EmployeeID

--Identify the Join:
--Select 
--	 CategoryName 
--	,ProductName 
--	,InventoryDate
--	,Count
--	,[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
--From Categories
--Inner Join Products on Categories.CategoryID = Products.CategoryID
--Inner Join Inventories on Products.ProductID = Inventories.ProductID
--Inner Join Employees on Inventories.EmployeeID = Employees.EmployeeID
--Go

--Wrap the Select Statement in a View and add the namespace and alias of the tables
--Go
--Create or Alter View vInventoryDateCategoryProductEmployee
--As
--Select 
--	CategoryName,
--	ProductName, 
--	InventoryDate,
--	Count,
--	e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
--From dbo.Categories as c
--Inner Join dbo.Products as p on c.CategoryID = p.CategoryID
--Inner Join dbo.Inventories as i on p.ProductID = i.ProductID
--Inner Join dbo.Employees  as e on i.EmployeeID = e.EmployeeID
--Go

--Order the Results and add Schema Binding
Go
Create or Alter View vInventoryDateCategoryProductEmployee
	With SchemaBinding	
	As
Select Top 100000
	CategoryName,
	ProductName, 
	InventoryDate,
	Count,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
From dbo.Categories as c
	Inner Join dbo.Products as p on c.CategoryID = p.CategoryID
	Inner Join dbo.Inventories as i on p.ProductID = i.ProductID
	Inner Join dbo.Employees  as e on i.EmployeeID = e.EmployeeID
Order By 
	InventoryDate,
	CategoryName,
	ProductName,
	EmployeeName
Go

--Grant Permissions
Grant Select on vInventoryDateCategoryProductEmployee to Public;
Go

--Test the View
--Select * From vInventoryDateCategoryProductEmployee

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

--Identify the Tables:
--Select * From Categories
--Select * From Products
--Select * From Inventories
--Select * From Employees
--Go

--Identify the Columns:
--Select CategoryName From Categories
--Select ProductName From Products
--Select InventoryDate, Count From Inventories
--Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName From Employees

--Identify the Join
--Select 
--CategoryName, 
--ProductName,
--InventoryDate,
--Count,
--Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName as EmployeeName
--From Categories
--Inner Join Products on Categories.CategoryID = Products.CategoryID
--Inner Join Inventories on Products.ProductID = Inventories.ProductID
--Inner Join Employees on Inventories.EmployeeID = Employees.EmployeeID
--Go

--Use a Subquery to get the ProductID based on the Product Names

--Select 
--Select 
--CategoryName, 
--ProductName,
--InventoryDate,
--Count,
--Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName as EmployeeName
--From Categories
--Inner Join Products on Categories.CategoryID = Products.CategoryID
--Inner Join Inventories on Products.ProductID = Inventories.ProductID
--Inner Join Employees on Inventories.EmployeeID = Employees.EmployeeID
--Where ProductName In 
--(Select ProductName 
--From Products 
--Where ProductID <=2)
--Go

--Wrap the Select Statement in a View and add the namespace and alias of the tables
--Go
--Create or Alter View vCategoryProductInventoryCountEmployee
--As
--Select 
--	CategoryName, 
--	ProductName,
--	InventoryDate,
--	Count,
--	e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
--From Categories as c
--Inner Join Products as p on c.CategoryID = p.CategoryID
--Inner Join Inventories as i on p.ProductID = i.ProductID
--Inner Join Employees as e on i.EmployeeID = e.EmployeeID
--Where ProductName In 
--		(Select ProductName 
--		From Products 
--		Where ProductID <=2)
--Go

--Order the Results and Add Schema Binding:
Go
Create or Alter View vCategoryProductInventoryCountEmployee
	With SchemaBinding
	As
Select Top 100000
	CategoryName, 
	ProductName,
	InventoryDate,
	Count,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as EmployeeName
From dbo.Categories as c
	Inner Join dbo.Products as p on c.CategoryID = p.CategoryID
	Inner Join dbo.Inventories as i on p.ProductID = i.ProductID
	Inner Join dbo.Employees as e on i.EmployeeID = e.EmployeeID
Where ProductName In 
	(Select ProductName 
	From dbo.Products 
	Where ProductID <=2)
Order By 
	InventoryDate, 
	CategoryName, 
	ProductName
Go

--Grant Permissions
Grant Select on vCategoryProductInventoryCountEmployee to Public;
Go

--Check the View
--Select * From vCategoryProductInventoryCountEmployee


--*************************************************************************************************************
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Identify the Tables:
--Select * From Employees

--Write an Alias for Employee and Manager:
--Select
--ManagerName] = EmployeeFirstName + ' ' + EmployeeLastName
--,[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
--From Employees

--Self Join to get the correct results
--Select 
--	  [ManagerName] = mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName
--	 ,[EmployeeName] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName
--From Employees as Emp Join Employees Mgr
--	On Emp.ManagerID = Mgr.EmployeeID

--Wrap the Select Statement in a View
--Go
--Create View vEmployeesManagers
--As 
--Select
--[Manager] = mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName,
--[Employee] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName
--From Employees as Emp Join Employees Mgr
--On Emp.ManagerID = Mgr.EmployeeID
--Go

--Order the Results
Go
Create or Alter View vEmployeesManagers
As 
Select Top 100000
	 [Manager] = mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName,
	 [Employee] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName
From Employees as Emp Join Employees as Mgr
	On Emp.ManagerID = Mgr.EmployeeID
Order By Manager, Employee
Go

--Grant Permissions
Grant Select on vEmployeesManagers to Public;
Go

--Check the View
--Select * From vEmployeesManagers
--Go

--**************************************************************************************
--Question 10 (20% pts): How can you create one view to show all the data from all four 
--BASIC Views? Also show the Employee's Manager Name and order the data by 
--Category, Product, InventoryID, and Employee.

--Identify the Tables and Columns
--Select CategoryID, CategoryName from Categories
--Select ProductID, ProductName, UnitPrice from Products
--Select InventoryID, InventoryDate, Count, EmployeeID from Inventories
--Select EmployeeName from Employees

--Identify the Joins and add Aliases
--Select
--c.CategoryID,
--c.CategoryName, 
--p.ProductID,
--p.ProductName,
--p.UnitPrice,
--i.InventoryID,
--i.InventoryDate,
--i.Count,
--i.EmployeeID,
--emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as EmployeeName,
--m.EmployeeFirstName + ' ' + m.EmployeeLastName as ManagerName
--From Categories as c
--Join Products as p 
--on c.CategoryID = p.CategoryID
--Join Inventories as i 
--on p.ProductID = i.ProductID
--Join Employees as emp 
--on i.EmployeeID = emp.EmployeeID
--Join Employees as m 
--on emp.ManagerID = m.EmployeeID
--Order By 
--CategoryName, 
--ProductID,
--InventoryID,
--EmployeeName
--Go

--Wrap the Select Statement in a View and Order the Results
Go
Create or Alter View vInventoriesByProductsByCategoriesByEmployees
	With SchemaBinding
	As
Select Top 100000
	c.CategoryID,
	c.CategoryName, 
	p.ProductID,
	p.ProductName,
	p.UnitPrice,
	i.InventoryID,
	i.InventoryDate,
	i.Count,
	i.EmployeeID,
	emp.EmployeeFirstName + ' ' + emp.EmployeeLastName as EmployeeName,
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as ManagerName
From dbo.Categories as c
	Join dbo.Products as p 
	on c.CategoryID = p.CategoryID
	Join dbo.Inventories as i 
	on p.ProductID = i.ProductID
	Join dbo.Employees as emp 
	on i.EmployeeID = emp.EmployeeID
	Join dbo.Employees as m 
	on emp.ManagerID = m.EmployeeID
Order By 
	CategoryName, 
	ProductID,
	InventoryID,
	EmployeeName
Go

--Check the View
--Select * From vInventoriesByProductsByCategoriesByEmployees
--Go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoryNameProductNameUnitPrice]
Select * From [dbo].[vProductNameDateCount]
Select * From [dbo].[vInventoryDatebyEmployee]
Select * From [dbo].[vCategoryNameProductNameDateCount]
Select * From [dbo].[vInventoryDateCategoryProductEmployee]
Select * From [dbo].[vCategoryProductInventoryCountEmployee]
Select * From [dbo].[vEmployeesManagers]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]


/***************************************************************************************/