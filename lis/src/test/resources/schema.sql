CREATE TABLE purchase_order (
    item_code VARCHAR(255) PRIMARY KEY,
    brand VARCHAR(255),
    product_description VARCHAR(255),
    pack_size DOUBLE,
    quantity INT,
    unit_cost DOUBLE,
    total_cost DOUBLE,
    po_PIreference VARCHAR(255)
);