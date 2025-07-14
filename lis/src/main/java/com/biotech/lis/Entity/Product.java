package com.biotech.lis.Entity;

import java.util.Date;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    @Id
    @GeneratedValue
    private Integer product_id;
    private String product_ref_num;
    private String product_name;
    private Integer quantity;
    private double price;
    private Integer total_purchases;
    private Date acquisition_date;
    private String category; //tsaka na gawing arraylist
    private String supplier_ref_num;
    private String addedBy;
    private Date dateTimeAdded;
}

//I think there should be two separate products, one for the individual itself and one for the product display sa dashboard