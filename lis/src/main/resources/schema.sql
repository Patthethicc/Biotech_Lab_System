CREATE TABLE user(
    userId INT PRIMARY KEY AUTO_INCREMENT,
    firstName VARCHAR(45) ,
    lastName VARCHAR(45) ,
    email VARCHAR(45) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE brand (
	brandId INT PRIMARY KEY AUTO_INCREMENT, 
    abbreviation VARCHAR(120) ,
    brandName VARCHAR(120) UNIQUE NOT NULL, 
    latestSequence INT ,
    products VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE customerData (
	customerId INTEGER PRIMARY KEY AUTO_INCREMENT,
    customerName VARCHAR(120) NOT NULL,
    address TEXT,
    salesRep VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE location (
	locationId INT PRIMARY KEY AUTO_INCREMENT,
    locationName VARCHAR(120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE purchaseOrder (
    itemCode VARCHAR(45) PRIMARY KEY,
    brandId INT,
    packSize INT,
    quantity INT,
    unitCost DOUBLE,
    poPiReference VARCHAR(80),
    addedBy INT,
    dateTimeAdded DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (brandId) REFERENCES brand(brandId),
    FOREIGN KEY (addedBy) REFERENCES user(userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE inventory (
    poPiReference VARCHAR(100),
    invoiceNum VARCHAR(80),
    itemCode VARCHAR(64) PRIMARY KEY,
    itemDescription TEXT,
    brandId INT,
    packSize INT,
    lotNum INT,
    expiry DATE,
    quantity INT,
    costOfSale DOUBLE,
    locationId INT,
    note TEXT,
    addedBy INT,
    dateTimeAdded DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (itemCode) REFERENCES purchaseOrder(itemCode),
    FOREIGN KEY (brandId) REFERENCES brand(brandId),
    FOREIGN KEY (locationId) REFERENCES location(locationId),
    FOREIGN KEY (addedBy) REFERENCES user(userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE itemLoc (
	itemLocId INT PRIMARY KEY AUTO_INCREMENT,
    itemCode VARCHAR(45),
    brandId INT,
    productDescription TEXT,
    locationId INT,
    quantity INT,
    addedBy INT,
    dateTimeAdded DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (itemCode) REFERENCES inventory(itemCode),
    FOREIGN KEY (brandId) REFERENCES brand(brandId),
    FOREIGN KEY (locationId) REFERENCES location(locationId),
    FOREIGN KEY (addedBy) REFERENCES user(userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE transactionEntry (
	transactionId INT PRIMARY KEY AUTO_INCREMENT,
    drSIReference VARCHAR(45),
    brandId INT,
    itemDescription TEXT,
    lotNum INT,
    expirationDate DATE,
    customerName VARCHAR(45),
    quantity INT,
    totalSRP DOUBLE,
    locationId INT,
    addedBy INT,
    dateTimeAdded DATETIME DEFAULT CURRENT_TIMESTAMP,
   
	FOREIGN KEY (brandId) REFERENCES brand(brandId),
    FOREIGN KEY (locationId) REFERENCES itemLoc(itemLocId),
    FOREIGN KEY (addedBy) REFERENCES user(userId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;