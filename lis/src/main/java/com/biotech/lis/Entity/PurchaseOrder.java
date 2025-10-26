package com.biotech.lis.Entity;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOrder {
    @Id
    private String itemCode;
    private Integer brandId;
    private Integer packSize;
    private Integer quantity;
    private Double unitCost;
    private String poPireference;
    private Integer addedBy;
    private LocalDateTime dateTimeAdded;
    private String productDescription;

    // private String lotSerialNumber;
    // private String purchaseOrderFileName;
    // @Lob
    // private byte[] purchaseOrderFile;
    // private String suppliersPackingListName;
    // @Lob
    // private byte[] suppliersPackingList;
    // private String inventoryOfDeliveredItemsName;
    // @Lob
    // private byte[] inventoryOfDeliveredItems;
    // private LocalDate orderDate;
    // private String addedBy;
    // private LocalDateTime dateTimeAdded;
    // private String drSIReferenceNum;
}
