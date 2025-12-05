package com.biotech.lis.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.biotech.lis.Entity.Inventory;

public interface InventoryRepository extends JpaRepository<Inventory, String> {
    List<Inventory> findByQuantityLessThanEqual(int quantity);
    //Optional<Inventory> findByItemCodeIgnoreCase(String itemCode);
    //Optional<Inventory> findByBrandAndProductDescription(String brandName, String itemDescription);
    void deleteByItemCode(String itemCode);
}
