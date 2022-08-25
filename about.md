Layout: About
Title: "About"
permalink: https://wizardoboz.github.io/DBFoundations/about/

### Name: Katie Boswell
### Date: August 17, 2022
### Course: IT FDN 130 A Su 22: Foundations of Databases & SQL Programming
### GitHub Repository Link: wizardoboz/DBFoundations-Module07 (github.com)

# Assignment 7: SQL Functions

## Introduction
In this paper, I will briefly explain when to use a SQL User-Defined Function (UDF). I will also explain the differences between Scalar, Inline, and Multi-Statement Functions.

## UDFs
User-Defined Functions (UDFs) are useful when you need to create a function that is not already built in SQL Server’s built-in functions. The types of useful functions are discussed below, but there are also some limitations on functions to be aware of. Of the limitations related to what we’ve learned so far, UDFs cannot be used to modify the database itself, they can’t return multiple result sets, they can’t call a stored procedure (although they can call an extended stored procedure), they can’t use temporary tables, and they don’t support error handling (such as with try and catch statements).

## Scalar Functions
UDFs can be used to create scalar (single-value) functions, which is very useful if you need to pass in a parameter to the function. In other words, the function would take an input value and return a scalar value. If I designed a parameter as an integer, for instance, I could then evaluate an integer into the function, and it will return only those rows in that column that have a matching integer. For example, in the code below (Code Example 1), @KPI int is the parameter, and I could use the listed Select * From statements and pass in an integer to the function. I would only get results that match that integer. 
```
Go
Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
Returns Table
As
Return
	(Select 
		 ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount 
		,CountVsPreviousCountKPI
	From
		vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = @KPI);
Go
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Go
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Go
Code Example 1
```
## Inline Functions
An inline table-valued function (iTVF) is a function that returns a table that as an output. Our Code Example 1 (see above) is a good example of a function that returns tabled values. It is easy to see from the code, which actually says “Returns Table” that the result will be a table format. The inline function can contain only one select statement, and the structure of the table is defined by the select statement in the function body. You do not specify the structure of the return table, and you do not use BEGIN/END syntax.


## Multi-Statement Table-Valued Functions
A Multi-Statement Table-Valued function (MSTVF) also returns a table as an output, but the table is defined by the user. Unlike inline functions, you have to declare the return table structure in a variable. You also have to use a begin/end block, and you must use the return operator. The function body can use more than one statement as well.

## Summary
This paper has discussed UDFs, as well as the differences between Scalar, Inline, and Multi-Statement Table-Valued functions.

  
