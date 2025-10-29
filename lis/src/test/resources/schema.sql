CREATE TABLE `user` (
    userId BIGINT PRIMARY KEY AUTO_INCREMENT,
    firstName VARCHAR(45),
    lastName VARCHAR(45),
    email VARCHAR(45),
    password VARCHAR(255)
);

CREATE TABLE `brand` (
    brandId INT PRIMARY KEY AUTO_INCREMENT,
    brandName VARCHAR(255) UNIQUE,
    abbreviation VARCHAR(50),
    latestSequence INT
);

CREATE TABLE purchase_order (
    item_code VARCHAR(255) PRIMARY KEY,
    brand_id INT,
    product_description VARCHAR(255),
    pack_size DOUBLE,
    quantity INT,
    unit_cost DOUBLE,
    po_pireference VARCHAR(255),
    added_by INT,
    date_time_added TIMESTAMP
);

CREATE TABLE `inventory` (
    inventoryId INT PRIMARY KEY AUTO_INCREMENT,
    itemCode VARCHAR(64),
    brand VARCHAR(255),
    productDescription VARCHAR(255),
    lotSerialNumber VARCHAR(64),
    cost DOUBLE,
    expiryDate DATE,
    stocksManila INT,
    stocksCebu INT,
    quantityOnHand INT,
    addedBy VARCHAR(255),
    dateTimeAdded TIMESTAMP
);

CREATE TABLE transactionEntry (
    drSIReferenceNum VARCHAR(64) PRIMARY KEY,
    transactionDate DATE,
    brand VARCHAR(255),
    productDescription VARCHAR(255),
    lotSerialNumber VARCHAR(64),
    expiryDate DATE,
    cost DOUBLE,
    quantity INT,
    stockLocation VARCHAR(255),
    itemCode VARCHAR(64),
    addedBy VARCHAR(255),
    dateTimeAdded TIMESTAMP
);

CREATE TABLE stockLocator (
    itemCode VARCHAR(64) PRIMARY KEY,
    brand VARCHAR(255),
    productDescription VARCHAR(255),
    lazcanoRef1 INT,
    lazcanoRef2 INT,
    gandiaColdStorage INT,
    gandiaRef1 INT,
    gandiaRef2 INT,
    limbaga INT,
    cebu INT,
    addedBy VARCHAR(255),
    dateTimeAdded TIMESTAMP
);