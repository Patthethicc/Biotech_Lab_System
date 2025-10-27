package com.biotech.lis.Repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.biotech.lis.Entity.ItemLoc;

public interface ItemLocRepository extends JpaRepository<ItemLoc, Integer> {
    List<ItemLoc> findByItemCode(String itemCode);
}



