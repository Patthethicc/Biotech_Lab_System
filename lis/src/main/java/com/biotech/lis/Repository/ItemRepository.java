package com.biotech.lis.Repository;

import java.util.Date;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.biotech.lis.Entity.Item;

public interface ItemRepository extends JpaRepository<Item, Integer> {
    public Item findItemByItemCode(String item_code);

    @Query("SELECT e FROM Item e WHERE e.expiryDate < :startDate OR e.expiryDate BETWEEN :startDate AND :endDate")
    public List<Item> findAllWithinDateRange(@Param("startDate") Date startDate,
                                          @Param("endDate") Date endDate);
}
