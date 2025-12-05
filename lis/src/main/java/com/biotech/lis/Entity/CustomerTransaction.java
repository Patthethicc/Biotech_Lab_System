package com.biotech.lis.Entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "customer_transaction")
public class CustomerTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long transactionId;

    @Column(name = "invoiceReference")
    private String invoiceReference;

    @Column(name = "transactionDate")
    @com.fasterxml.jackson.annotation.JsonFormat(shape = com.fasterxml.jackson.annotation.JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
    private LocalDateTime transactionDate;

    @Column(name = "customerId")
    private String customerId;

    @Column(name = "customerName")
    private String customerName;

    @Column(name = "totalRetailPrice")
    private Double totalRetailPrice;

    @OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "transaction_id")
    private List<Sold> items;

    public CustomerTransaction() {}

    public Long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Long transactionId) {
        this.transactionId = transactionId;
    }

    public String getInvoiceReference() {
        return invoiceReference;
    }

    public void setInvoiceReference(String invoiceReference) {
        this.invoiceReference = invoiceReference;
    }

    public LocalDateTime getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDateTime transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public Double getTotalRetailPrice() {
        return totalRetailPrice;
    }

    public void setTotalRetailPrice(Double totalRetailPrice) {
        this.totalRetailPrice = totalRetailPrice;
    }

    public List<Sold> getItems() {
        return items;
    }

    public void setItems(List<Sold> items) {
        this.items = items;
    }
}
