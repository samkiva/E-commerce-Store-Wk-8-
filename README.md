# Final Project — E-commerce DB (Week 8)

## Selected Question
Question 1: Build a Complete Database Management System

## Summary
This repository contains a MySQL schema for an e-commerce database (`ecommerce_db`). The schema includes customers, addresses, suppliers, product lines, products, orders, payments, and order items with proper constraints and relationships.

## Files
- `ecommerce_db.sql` — Complete SQL script including CREATE DATABASE, CREATE TABLE statements, constraints, and a helpful view.

## How to run
1. Open MySQL Workbench (or another MySQL client).
2. Create a new SQL tab and load `ecommerce_db.sql`.
3. Execute the script. It will create the database and the schema.
4. Verify tables with `SHOW TABLES;` and check `SELECT * FROM Customers LIMIT 1;` etc.

## Notes
- Engine: InnoDB to ensure referential integrity.
- Tested on MySQL 8.0+ (JSON functions are not required for this schema).
- This submission is for the Week 8 final project (Question 1).
