package com.biotech.lis.Entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "`inventory`")
public class Inventory {
    @Id
    private Integer inventoryId;
    private String itemCode;
    private String brand;
    private String productDescription;
    private String lotSerialNumber;
    private Double cost;
    private LocalDate expiryDate;
    private Integer stocksManila;
    private Integer stocksCebu;
    //note: do not display on frontend inventory table
    private Integer quantityOnHand;
    private String addedBy;
    private LocalDateTime dateTimeAdded;
}
