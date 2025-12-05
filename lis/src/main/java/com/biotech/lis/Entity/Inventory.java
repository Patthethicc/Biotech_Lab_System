package com.biotech.lis.Entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

import jakarta.persistence.Entity;
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
    private String itemCode;

    private String poPireference;
    private String invoiceNum;
    private String itemDescription;
    private Integer brandId;
    private Integer lotNum;
    private LocalDate expiry;
    private Integer packSize;
    private Integer quantity;
    private Double costOfSale;
    private String note;

    //note: do not display on frontend inventory tabl
    private Long addedBy;
    private LocalDateTime dateTimeAdded;
}
