package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.Inventory;

public interface InventoryRepository extends JpaRepository<Inventory, Integer> {
    
}
