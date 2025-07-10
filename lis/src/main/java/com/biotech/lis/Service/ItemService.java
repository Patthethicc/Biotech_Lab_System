package com.biotech.lis.Service;

import com.biotech.lis.Entity.Item;
import com.biotech.lis.Repository.ItemRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ItemService {

    @Autowired
    ItemRepository itemRepository;

    public Item addItem(Item item) {
        return itemRepository.save(item);
    }
    
    public Item getItem(String itemCode) {
        return itemRepository.findItemByItemCode(itemCode);
    }

    public void deleteItem(String itemCode) {
        itemRepository.delete(itemRepository.findItemByItemCode(itemCode));
    }

    public Item updateItem(Item item) {
        return itemRepository.save(item);
    }
}
