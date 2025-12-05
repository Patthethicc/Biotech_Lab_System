package com.biotech.lis.Entity;

import jakarta.persistence.*;

@Entity
@Table(name = "sold_items")
public class Sold {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "itemId")
    private String itemId;

    @Column(name = "lotNumber")
    private String lotNumber;

    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "unitRetailPrice")
    private Double unitRetailPrice;

    @Column(name = "brandName")
    private String brandName;

    @Column(name = "itemDescription")
    private String itemDescription;

    @Column(name = "location")
    private String location;

    @Column(name = "transaction_id")
    private Long transactionId;

    public Sold() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getLotNumber() {
        return lotNumber;
    }

    public void setLotNumber(String lotNumber) {
        this.lotNumber = lotNumber;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getUnitRetailPrice() {
        return unitRetailPrice;
    }

    public void setUnitRetailPrice(Double unitRetailPrice) {
        this.unitRetailPrice = unitRetailPrice;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getItemDescription() {
        return itemDescription;
    }

    public void setItemDescription(String itemDescription) {
        this.itemDescription = itemDescription;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }
}
