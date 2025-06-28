package com.biotech.lis.Entity;

import java.time.LocalDate;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "Transaction_Entry")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionEntry {
    
    @Id
    @Column(name = "DR_SI_Reference_Num")
    private String drSiReferenceNum;
    
    @Column(name = "Transaction_Date")
    private LocalDate transactionDate;
    
    @Column(name = "Brand")
    private String brand;
    
    @Column(name = "Product_Description")
    private String productDescription;
    
    @Column(name = "Lot_Serial_Number")
    private String lotSerialNumber;
    
    @Column(name = "Expiry_Date")
    private LocalDate expiryDate;
    
    @Column(name = "Quantity")
    private Integer quantity;
    
    @Column(name = "Stock_Location")
    private String stockLocation;
}
