package com.biotech.lis.Entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "`purchaseOrder`")
public class PurchaseOrder {
    @Id
    private String itemCode;
    private String brand;
    private String productDescription;
    private Double packSize;
    private Integer quantity;
    private Double unitCost;
    private Double totalCost;
    private String poPIreference;

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
