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
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "`purchaseOrder`")
public class PurchaseOrder {
    @Id
    private String purchaseOrderCode;
    private String itemCode;
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

    @JsonProperty("hasPurchaseOrderFile")
    public boolean hasPurchaseOrderFile() {
        return this.purchaseOrderFile != null && this.purchaseOrderFile.length > 0;
    }

    @JsonProperty("hasSuppliersPackingList")
    public boolean hasSuppliersPackingList() {
        return this.suppliersPackingList != null && this.suppliersPackingList.length > 0;
    }
}
