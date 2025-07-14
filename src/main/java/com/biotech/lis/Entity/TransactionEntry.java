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
@Table(name = "transactionEntry")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionEntry {
    
    @Id
    @Column(name = "drSIReferenceNum")
    private String drSIReferenceNum;
    
    @Column(name = "transactionDate")
    private LocalDate transactionDate;
    
    @Column(name = "brand")
    private String brand;
    
    @Column(name = "productDescription")
    private String productDescription;
    
    @Column(name = "lotSerialNumber")
    private String lotSerialNumber;
    
    @Column(name = "expiryDate")
    private LocalDate expiryDate;
    
    @Column(name = "quantity")
    private Integer quantity;
    
    @Column(name = "stockLocation")
    private String stockLocation;
}
