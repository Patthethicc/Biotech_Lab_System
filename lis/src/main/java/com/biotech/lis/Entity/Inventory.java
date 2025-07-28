package com.biotech.lis.Entity;

import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.CascadeType;
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
    @GeneratedValue
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
