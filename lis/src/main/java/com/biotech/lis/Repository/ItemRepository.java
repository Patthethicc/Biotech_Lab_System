package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.biotech.lis.Entity.Item;

public interface ItemRepository extends JpaRepository<Item, Integer> {
    public Item findItemByItemCode(String item_code);
}
