-- ecommerce_db.sql
-- E-commerce database schema
-- Run in MySQL Workbench (MySQL 8+ recommended)

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Drop tables if they exist (safe to re-run)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS ProductCategory;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS ProductLines;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Addresses;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Suppliers;
SET FOREIGN_KEY_CHECKS = 1;

-- Customers: each customer can have multiple addresses and orders
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(80) NOT NULL,
    LastName VARCHAR(80) NOT NULL,
    Email VARCHAR(150) NOT NULL UNIQUE,
    Phone VARCHAR(30),
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Addresses: one-to-many (Customer -> Addresses)
CREATE TABLE Addresses (
    AddressID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AddressLine1 VARCHAR(200) NOT NULL,
    AddressLine2 VARCHAR(200),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(80) NOT NULL,
    IsDefault BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Suppliers: vendor/supplier info
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(150) NOT NULL,
    ContactName VARCHAR(100),
    Email VARCHAR(150),
    Phone VARCHAR(30),
    UNIQUE (SupplierName)
) ENGINE=InnoDB;

-- ProductLines: category-like grouping (one-to-many)
CREATE TABLE ProductLines (
    ProductLineID INT AUTO_INCREMENT PRIMARY KEY,
    ProductLineName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT
) ENGINE=InnoDB;

-- Products: product catalog (many products may belong to one product line)
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    SupplierID INT,
    ProductLineID INT,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    UnitsInStock INT DEFAULT 0 CHECK (UnitsInStock >= 0),
    SKU VARCHAR(80) UNIQUE,
    Active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE SET NULL,
    FOREIGN KEY (ProductLineID) REFERENCES ProductLines(ProductLineID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ProductCategory: optional additional many-to-many between products and categories (if desired)
CREATE TABLE ProductCategory (
    ProductID INT NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    PRIMARY KEY (ProductID, CategoryName),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Orders: one order per customer; one-to-many Customers -> Orders
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    ShippedDate DATETIME,
    ShipAddressID INT,          -- optional FK to Addresses
    Status ENUM('PENDING','PROCESSING','SHIPPED','DELIVERED','CANCELLED') DEFAULT 'PENDING',
    TotalAmount DECIMAL(12,2) DEFAULT 0 CHECK (TotalAmount >= 0),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (ShipAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Payments: one-to-one or one-to-many relationship with Orders (supporting multiple payment attempts)
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(12,2) NOT NULL CHECK (Amount >= 0),
    PaymentMethod ENUM('CARD','PAYPAL','BANK_TRANSFER','CASH') DEFAULT 'CARD',
    TransactionRef VARCHAR(200),
    Status ENUM('SUCCESS','FAILED','PENDING') DEFAULT 'PENDING',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- OrderItems: join table for Orders <-> Products (many-to-many)
-- Composite PK ensures uniqueness of (OrderID, ProductID)
CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Sample indexes for common queries
CREATE INDEX idx_products_sku ON Products (SKU);
CREATE INDEX idx_orders_customer ON Orders (CustomerID);
CREATE INDEX idx_payments_order ON Payments (OrderID);

-- Optional: view that calculates order totals (useful for testing)
DROP VIEW IF EXISTS OrderTotals;
CREATE VIEW OrderTotals AS
SELECT o.OrderID, o.CustomerID, SUM(oi.Quantity * oi.UnitPrice) AS CalculatedTotal
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.CustomerID;
