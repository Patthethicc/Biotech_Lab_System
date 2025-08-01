package com.biotech.lis.Repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.biotech.lis.Entity.Inventory;

public interface InventoryRepository extends JpaRepository<Inventory, Integer> {
    List<Inventory> findByQuantityOnHandLessThan(int amount);
    Optional<Inventory> findByItemCodeIgnoreCase(String itemCode);
    Optional<Inventory> findByBrandAndProductDescription(String brandName, String productDescription);
}
