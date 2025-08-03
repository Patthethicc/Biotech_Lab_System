
package com.biotech.lis.Entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "stockLocator")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StockLocator {
    
    @Id 
    @Column(name = "itemCode")
    private String itemCode; 
    
    @Column(name = "brand")
    private String brand;
    
    @Column(name = "productDescription")
    private String productDescription;
    
    @Column(name = "lazcanoRef1")
    private Integer lazcanoRef1;
    
    @Column(name = "lazcanoRef2")
    private Integer lazcanoRef2;
    
    @Column(name = "gandiaColdStorage")
    private Integer gandiaColdStorage;
    
    @Column(name = "gandiaRef1")
    private Integer gandiaRef1;
    
    @Column(name = "gandiaRef2")
    private Integer gandiaRef2;
    
    @Column(name = "limbaga")
    private Integer limbaga;
    
    @Column(name = "cebu")
    private Integer cebu;

    @Column(name = "addedBy")
    private String addedBy;

    @Column(name = "dateTimeAdded")
    private LocalDateTime dateTimeAdded;

    public StockLocator(String brand, String productDescription) {
        this.brand = brand;
        this.productDescription = productDescription;
        this.itemCode = "placeholder"; // replace 
        this.lazcanoRef1 = 0;
        this.lazcanoRef2 = 0;
        this.gandiaColdStorage = 0;
        this.gandiaRef1 = 0;
        this.gandiaRef2 = 0;
        this.limbaga = 0;
        this.cebu = 0;
    }   
    
    
}