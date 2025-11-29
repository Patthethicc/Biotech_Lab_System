CREATE TABLE user(
    userId INT PRIMARY KEY ,
    firstName VARCHAR(45) ,
    lastName VARCHAR(45) ,
    email VARCHAR(45) ,
    password VARCHAR(20) 
    -- i dont think position and department are needed because admin lang naman mag access eh
);

CREATE TABLE inventory (
    inventoryId INT PRIMARY KEY,
    itemCode VARCHAR(64),
    brand VARCHAR(255),
    cost DECIMAL(20,2),
    quantityOnHand INT,
    lastUpdated DATETIME,
    FOREIGN KEY (itemCode) REFERENCES itemList(itemCode)
);

CREATE TABLE transactionEntry (
    drSIReferenceNum VARCHAR(64) PRIMARY KEY,
    transactionDate DATETIME,
    brand VARCHAR(255),
    productDescription VARCHAR(255),
    lotSerialNumber VARCHAR(64),
    expiryDate DATE,
    quantity INT,
    stockLocation VARCHAR(255)
);

CREATE TABLE purchaseOrder (
    purchaseOrderCode VARCHAR(64) PRIMARY KEY,
    purchaseOrderFile BLOB,
    suppliersPackingList BLOB,
    quantityPurchased INT,
    orderDate DATE,
    expectedDeliveryDate DATE,
    -- Items_Purchased VARCHAR(255),  (i feel like this column is not needed bcs we have itemPurchased table)
    cost DECIMAL(20,2),
    addedBy INT,
    timeAdded DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (addedBy) REFERENCES user(user_id)
);

CREATE TABLE itemPurchased (
    purchaseOrderCode VARCHAR(64),
    itemCode VARCHAR(64),
    PRIMARY KEY (purchaseOrderCode, itemCode),
    FOREIGN KEY (purchaseOrderCode) REFERENCES purchaseOrder(purchaseOrderCode),
    FOREIGN KEY (itemCode) REFERENCES itemList(itemCode)
);

CREATE TABLE itemList (
    itemCode VARCHAR(64) PRIMARY KEY,
    brand VARCHAR(255),
    productDescription VARCHAR(255),
    lotSerialNumber VARCHAR(64),
    cost DECIMAL(20,2),
    expiryDate DATE,
    stocksManila INT,
    stocksCebu INT,
    purchaseOrderRef VARCHAR(64),
    suppliersPackingList BLOB,
    drSIReferenceNum VARCHAR(64),
    FOREIGN KEY (drSIReferenceNum) REFERENCES transactionEntry(drSIReferenceNum)
); 

CREATE TABLE stockLocator (
    itemCode VARCHAR(64),
    brand VARCHAR(255),
    productDescription VARCHAR(255),
    lazcanoRef1 INT,
    lazcanoRef2 INT,
    gandiaColdStorage INT,
    gandiaRef1 INT,
    gandiaRef2 INT,
    limbaga INT,
    cebu INT,
    PRIMARY KEY (itemCode),
    FOREIGN KEY (itemCode) REFERENCES itemList(itemCode)
);
