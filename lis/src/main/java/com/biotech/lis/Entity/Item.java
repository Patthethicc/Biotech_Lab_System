package com.biotech.lis.Entity;

import java.time.LocalDateTime;
import java.util.Date;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "`itemList`")
public class Item {
    @Id
    private String itemCode;
    private String brand;
    private String productDescription;
    private String lotSerialNumber;
    private Date expiryDate;
    private Integer StocksManila;
    private Integer StocksCebu;
    private String purchaseOrderReferenceNumber;
    private String supplierPackingList;
    private String drsiReferenceNumber;
    private String addedBy;
    private LocalDateTime dateTimeAdded;

    @ManyToOne
    @JoinColumn(name = "inventoryId")
    private Inventory inventory;
}
