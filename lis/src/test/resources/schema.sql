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

CREATE TABLE `Location` (
    locationId INT PRIMARY KEY AUTO_INCREMENT,
    locationName VARCHAR(255)
);

CREATE TABLE purchaseOrder (
    itemCode VARCHAR(255) PRIMARY KEY,
    brandId INT,
    productDescription VARCHAR(255),
    packSize DOUBLE,
    quantity INT,
    unitCost DOUBLE,
    poPireference VARCHAR(255),
    addedBy INT,
    dateTimeAdded TIMESTAMP
);

CREATE TABLE `inventory` (
    itemCode VARCHAR(255) PRIMARY KEY,
    poPireference VARCHAR(255),
    invoiceNum VARCHAR(255),
    itemDescription VARCHAR(255),
    brandId INT,
    lotNum INT,
    expiry DATE,
    packSize INT,
    quantity INT,
    costOfSale DOUBLE,
    note TEXT,
    addedBy BIGINT,
    dateTimeAdded TIMESTAMP
);

CREATE TABLE itemLoc (
    locationId INT PRIMARY KEY,
    itemCode VARCHAR(255),
    quantity INT
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