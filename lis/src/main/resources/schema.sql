CREATE TABLE Inventory (
    Inventory_ID VARCHAR(64) PRIMARY KEY,
    Item_Code VARCHAR(64),
    Quantity_on_Hand INT,
    Last_Updated DATETIME,
    FOREIGN KEY (Item_Code) REFERENCES Item_List(Item_Code)
);

CREATE TABLE Transaction_Entry (
    DR_SI_Reference_Num VARCHAR(64) PRIMARY KEY,
    Transaction_Date DATETIME,
    Brand VARCHAR(255),
    Product_Description VARCHAR(255),
    Lot_Serial_Number VARCHAR(64),
    Expiry_Date DATE,
    Quantity INT,
    Stock_Location VARCHAR(255)
);

CREATE TABLE Purchase_Order (
    Purchase_Order_Code VARCHAR(64) PRIMARY KEY,
    Purchase_Order_File BLOB,
    Suppliers_Packing_List BLOB,
    Quantity_Purchased INT,
    Order_Date DATE,
    Expected_Delivery_Date DATE,
    -- Items_Purchased VARCHAR(255),  (i feel like this column is not needed bcs we have Item_Purchased table)
    Cost DECIMAL(20,2)
);


CREATE TABLE Item_Purchased (
    Purchase_Order_Code VARCHAR(64),
    Item_Code VARCHAR(64),
    PRIMARY KEY (Purchase_Order_Code, Item_Code),
    FOREIGN KEY (Purchase_Order_Code) REFERENCES Purchase_Order(Purchase_Order_Code),
    FOREIGN KEY (Item_Code) REFERENCES Item_List(Item_Code)
);

CREATE TABLE Item_Code_Details (
    Item_Code VARCHAR(64) PRIMARY KEY,
    Brand VARCHAR(255),
    Product_Description VARCHAR(255),
    Lot_Serial_Number VARCHAR(64),
    Purchase_Order_Ref VARCHAR(64),
    Suppliers_Packing_List BLOB,
    DR_SI_Reference_Num VARCHAR(64),
    FOREIGN KEY (DR_SI_Reference_Num) REFERENCES Transaction_Entry(DR_SI_Reference_Num)
);

CREATE TABLE Item_List (
    Item_Code VARCHAR(64) PRIMARY KEY,
    Brand VARCHAR(255),
    Product_Description VARCHAR(255),
    Lot_Serial_Number VARCHAR(64),
    Expiry_Date DATE,
    Stocks_Manila VARCHAR(64),
    Stocks_Cebu VARCHAR(64)
); 

CREATE TABLE Stock_Locator (
    Item_Code VARCHAR(64),
    Brand VARCHAR(255),
    Product_Description VARCHAR(255),
    Lazcano_Ref1 VARCHAR(64),
    Lazcano_Ref2 VARCHAR(64),
    Gandia_ColdStorage VARCHAR(64),
    Gandia_Ref1 VARCHAR(64),
    Gandia_Ref2 VARCHAR(64),
    Limbaga VARCHAR(64),
    Cebu VARCHAR(64),
    PRIMARY KEY (Item_Code),
    FOREIGN KEY (Item_Code) REFERENCES Item_List(Item_Code)
);

CREATE TABLE Sales_Order (
    Sales_Order_Code VARCHAR(64) PRIMARY KEY,
    Quantity_on_Sales_Order INT,
    Order_Date DATE,
    Expected_Delivery_Date DATE,
    -- Item_Purchased VARCHAR(255),  same comment as the one in purchase order
    Cost DECIMAL(20,2),
    Status ENUM('Pending', 'Shipped', 'Delivered') NOT NULL
);