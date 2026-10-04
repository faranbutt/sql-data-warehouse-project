/*

======================================================================
Create Database and Schemas
======================================================================

Purpose:
	The script creates a new database "DataWareHouse".
	If the database exists, active connections are terminated, it is dropped, and then recreated.
	Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

*/


\c postgres;

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'datawarehouse'
 AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS DataWareHouse;

CREATE DATABASE DataWareHouse;

\c DataWareHouse;

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
