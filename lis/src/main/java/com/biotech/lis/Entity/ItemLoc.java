package com.biotech.lis.Entity;

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
@Table(name = "itemLoc")
public class ItemLoc {
    @Id
    private Integer locationId;
    private String itemCode;
    private Integer quantity;
}
