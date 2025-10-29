package com.biotech.lis.Entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "purchase_order")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseOrder {
    @Id
    @Column(name = "item_code")
    private String itemCode;
    
    @Column(name = "brand_id")
    private Integer brandId;
    
    @Column(name = "pack_size")
    private Double packSize;
    
    @Column(name = "quantity")
    private Integer quantity;
    
    @Column(name = "unit_cost")
    private Double unitCost;
    
    @Column(name = "po_pireference")
    private String poPireference;
    
    @Column(name = "added_by")
    private Integer addedBy;
    
    @Column(name = "date_time_added")
    private LocalDateTime dateTimeAdded;
    
    @Column(name = "product_description")
    private String productDescription;
}
