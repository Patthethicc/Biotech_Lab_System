package com.biotech.lis.Entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import lombok.Data;

@Data
public class CombinedTrnPO {
    private String drSIReferenceNum;
    private LocalDate transactionDate;
    private String itemCode;
    private String brand;
    private String productDescription;
    private String lotSerialNumber;
    private LocalDate expiryDate;
    private Double cost;
    private Double packSize;
    private Integer quantity;
    private Double unitCost;
    private Double totalCost;
    private String poPIreference;
    private String stockLocation;


    private String purchaseOrderFileName;
    private String suppliersPackingListName;
    private String inventoryOfDeliveredItemsName;
    private byte[] purchaseOrderFile;
    private byte[] suppliersPackingList;
    private byte[] inventoryOfDeliveredItems;

    public TransactionEntry toTransactionEntry() {
        TransactionEntry transactionEntry = new TransactionEntry();
        transactionEntry.setDrSIReferenceNum(drSIReferenceNum);
        transactionEntry.setTransactionDate(transactionDate);
        transactionEntry.setBrand(brand);
        transactionEntry.setProductDescription(productDescription);
        transactionEntry.setLotSerialNumber(lotSerialNumber);
        transactionEntry.setExpiryDate(expiryDate);
        transactionEntry.setCost(cost);
        transactionEntry.setQuantity(quantity);
        transactionEntry.setStockLocation(stockLocation);
        transactionEntry.setItemCode("error");
        transactionEntry.setAddedBy("error");
        transactionEntry.setDateTimeAdded(LocalDateTime.now());
        
        return transactionEntry;
    }

    public PurchaseOrder toPurchaseOrder() {
        PurchaseOrder purchaseOrder = new PurchaseOrder();
        purchaseOrder.setItemCode("error");
        purchaseOrder.setBrand(brand);
        purchaseOrder.setProductDescription(productDescription);
        purchaseOrder.setPackSize(packSize);
        purchaseOrder.setQuantity(quantity);
        purchaseOrder.setUnitCost(unitCost);
        purchaseOrder.setTotalCost(totalCost);
        purchaseOrder.setPoPIreference(poPIreference);

        // purchaseOrder.setLotSerialNumber(lotSerialNumber);
        // purchaseOrder.setPurchaseOrderFileName(purchaseOrderFileName);
        // purchaseOrder.setPurchaseOrderFile(purchaseOrderFile);
        // purchaseOrder.setSuppliersPackingListName(suppliersPackingListName);
        // purchaseOrder.setSuppliersPackingList(suppliersPackingList);
        // purchaseOrder.setInventoryOfDeliveredItemsName(inventoryOfDeliveredItemsName);
        // purchaseOrder.setInventoryOfDeliveredItems(inventoryOfDeliveredItems);
        // purchaseOrder.setOrderDate(transactionDate);
        // purchaseOrder.setDrSIReferenceNum(drSIReferenceNum);
        // purchaseOrder.setAddedBy("error");
        // purchaseOrder.setDateTimeAdded(LocalDateTime.now());
        
        return purchaseOrder;
    }
}
