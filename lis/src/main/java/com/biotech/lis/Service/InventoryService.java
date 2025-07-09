package com.biotech.lis.Service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Repository.InventoryRepository;

@Service
public class InventoryService {
    @Autowired
    InventoryRepository inventoryRepository;

    public Inventory addInventory(Inventory inventory) {
        return inventoryRepository.save(inventory);
    }

    public Inventory getInventoryById(Integer inventoryId) {
        return inventoryRepository.getReferenceById(inventoryId);
    }

    public Inventory updateInventory(Inventory inventory) {
        return inventoryRepository.save(inventory);
    }

    public void deleteByInventoryId(Integer inventoryId) {
        inventoryRepository.deleteById(inventoryId);
    }

    public List<Inventory> getStockAlerts(Integer amount) {
        return inventoryRepository.findByQuantityOnHandLessThan(amount);
    }
}
