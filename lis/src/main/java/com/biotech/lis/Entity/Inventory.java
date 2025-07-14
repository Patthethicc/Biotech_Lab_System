package com.biotech.lis.Entity;

import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;
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
    @GeneratedValue
    private Integer inventoryId;
    private String itemCode;
    private Integer quantityOnHand;
    private Date lastUpdated;
    private String addedBy;
    private Date dateTimeAdded;
    //@ManyToOne
    //@JoinColumn(name = "itemCode")
    //private List<itemList> itemList = new ArrayList<>();
    
}
