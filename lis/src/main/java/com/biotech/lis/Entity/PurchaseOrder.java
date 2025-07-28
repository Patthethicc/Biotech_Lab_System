package com.biotech.lis.Entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "`purchaseOrder`")
public class PurchaseOrder {
    @Id
    private String purchaseOrderCode;
    @Lob
    private byte[] purchaseOrderFile;
    @Lob
    private byte[] suppliersPackingList;
    private int quantityPurchased;
    private LocalDate orderDate;
    private LocalDate expectedDeliveryDate;
    private double cost;
    private String addedBy;
    private LocalDateTime dateTimeAdded;
}
