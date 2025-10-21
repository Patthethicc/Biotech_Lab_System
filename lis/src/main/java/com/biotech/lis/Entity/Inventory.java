package com.biotech.lis.Entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "inventory_id")
    private Integer inventoryId;

    @Column(name = "po_PIreference")
    private String poPIreference;

    @Column(name = "invoice_num")
    private String invoiceNum;

    @Column(name = "item_code")
    private String itemCode;

    @Column(name = "item_description")
    private String itemDescription;

    @Column(name = "brand")
    private String brand;

    @Column(name = "lot_number")
    private String lotNumber;

    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    @Column(name = "pack_size")
    private Double packSize;

    @Column(name = "quantity")
    private Integer quantity;

    @Column(name = "cost_of_sale")
    private Double costOfSale;

    @Column(name = "locations")
    private String locations;

    @Column(name = "note")
    private String note;

    //note: do not display on frontend inventory table
    @Column(name = "added_by")
    private String addedBy;

    @Column(name = "date_time_added")
    private LocalDateTime dateTimeAdded;
}
