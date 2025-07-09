package com.biotech.lis.Entity;

import java.time.LocalDate;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "purchase_order")
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
}
