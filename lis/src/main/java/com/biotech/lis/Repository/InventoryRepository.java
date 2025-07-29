package com.biotech.lis.Repository;

import java.util.Date;
import java.util.List;
import java.util.Optional;

import org.hibernate.cache.spi.support.AbstractReadWriteAccess.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.Inventory;

public interface InventoryRepository extends JpaRepository<Inventory, Integer> {
    List<Inventory> findByQuantityOnHandLessThan(int amount);
    Optional<Inventory> findByItemCodeIgnoreCase(String itemCode);
    Optional<Inventory> findByBrandAndProductDescription(String brandName, String productDescription);
    @Query("SELECT e FROM Item e WHERE e.expiryDate < :startDate OR e.expiryDate BETWEEN :startDate AND :endDate")
    public List<Inventory> findAllWithinDateRange(@Param("startDate") Date startDate,
                                          @Param("endDate") Date endDate);
}
