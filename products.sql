CREATE DATABASE dblabsys;

USE dblabsys;

CREATE TABLE users(
    user_id INT PRIMARY KEY ,
    firstname VARCHAR(45) ,
    lastname VARCHAR(45) ,
    password VARCHAR(20) ,
    -- i dont think position and department are needed because admin lang naman mag access eh
);

CREATE TABLE supplier(
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(45) UNIQUE
    --additional details if requested by company
);

CREATE TABLE supplier_lookup(
    ref_num CHAR(15) PRIMARY KEY,
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE products(
    product_id INT,
    product_ref_num CHAR(15) PRIMARY KEY, --depending on how long the reference number is
    productname VARCHAR(45),
    quantity INT,
    price FLOAT,
    total_purchases INT,
    acquisition_date DATE, -- must be put individually nalang
    category VARCHAR(45), --tsaka na natin lagyan ng enum
    FOREIGN KEY (supplier_ref_num) REFERENCES supplier_lookup(ref_num)
);