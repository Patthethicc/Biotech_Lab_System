
package com.biotech.lis.Entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import com.fasterxml.jackson.annotation.JsonProperty;

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

    public StockLocator(String itemCode, String brand, String productDescription) {
        this.itemCode = itemCode;
        this.brand = brand;
        this.productDescription = productDescription;
        this.lazcanoRef1 = 0;
        this.lazcanoRef2 = 0;
        this.gandiaColdStorage = 0;
        this.gandiaRef1 = 0;
        this.gandiaRef2 = 0;
        this.limbaga = 0;
        this.cebu = 0;
    }

    @JsonProperty("totalStock")
    public int getTotalStock() {
        return (lazcanoRef1 != null ? lazcanoRef1 : 0) +
               (lazcanoRef2 != null ? lazcanoRef2 : 0) +
               (gandiaColdStorage != null ? gandiaColdStorage : 0) +
               (gandiaRef1 != null ? gandiaRef1 : 0) +
               (gandiaRef2 != null ? gandiaRef2 : 0) +
               (limbaga != null ? limbaga : 0) +
               (cebu != null ? cebu : 0);
    }
}