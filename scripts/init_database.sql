/*
=========================================================
Create Database and schemas
=========================================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
  within the database: Bronze, Silver and Gold

WARNING:
  Running this script will drop whole database 'DataWarehouse' if it exists.
  All data init will be deleted permamently. Proceed with caution
  and ensure your have proper backups before running this script
*/



USE master;
GO

-- If DataBase already exist , drop it and recreate
if exists (select 1 from sys.databases where name = 'DataWarehouse') 
Begin 
  Alter DATABASE DataWarehouse set Single_User with rollback immediate;
  Drop DATABASE DataWarehouse;
End;
GO

-- Create DataBase
CREATE DATABASE DataWarehouse;
GO


USE DataWarehouse;
GO


-- Create Schemas
CREATE SCHEMA Bronze;
GO
  
CREATE SCHEMA Silver;
GO
  
CREATE SCHEMA Gold;
GO

