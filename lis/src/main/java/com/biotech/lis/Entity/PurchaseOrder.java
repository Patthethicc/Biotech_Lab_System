package com.biotech.lis.Entity;

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
    @Column(name = "item_code")
    private String itemCode;
    
    @Column(name = "brand")
    private String brand;
    
    @Column(name = "product_description")
    private String productDescription;
    
    @Column(name = "pack_size")
    private Double packSize;
    
    @Column(name = "quantity")
    private Integer quantity;
    
    @Column(name = "unit_cost")
    private Double unitCost;
    
    @Column(name = "total_cost")
    private Double totalCost;
    
    @Column(name = "po_PIreference")
    private String poPIreference;
}
