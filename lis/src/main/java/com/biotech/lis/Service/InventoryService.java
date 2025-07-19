package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.InventoryRepository;

import jakarta.transaction.Transactional;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.Authentication;

@Service
public class InventoryService {
    @Autowired
    InventoryRepository inventoryRepository;

    @Autowired
    UserService userService;

    @Transactional
    public Inventory addInventory(Inventory inventory) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        inventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        inventory.setDateTimeAdded(cDateTime);
        return inventoryRepository.save(inventory);
    }

    public Inventory getInventoryById(Integer inventoryId) {
        return inventoryRepository.getReferenceById(inventoryId);
    }

    public List<Inventory> getInventories() {
        return inventoryRepository.findAll();
    }

    @Transactional
    public Inventory updateInventory(Inventory inventory) {
        Inventory existingInventory = getInventoryById(inventory.getInventoryId());
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        existingInventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        existingInventory.setDateTimeAdded(cDateTime);

        existingInventory.setQuantityOnHand(inventory.getQuantityOnHand());
        return inventoryRepository.save(existingInventory);
    }

    public void deleteByInventoryId(Integer inventoryId) {
        inventoryRepository.deleteById(inventoryId);
    }

    public List<Inventory> getStockAlerts(Integer amount) {
        return inventoryRepository.findByQuantityOnHandLessThan(amount);
    }

    public Integer inventoryExists(Inventory inventory) {
        String itemCode = inventory.getItemCode();
        if (itemCode == null || itemCode.trim().isEmpty()) {
            System.out.println("hello there im a bug");
            return 0;
        }

        Optional<Inventory> found = inventoryRepository.findByItemCodeIgnoreCase(itemCode);
        return found.map(inv -> inv.getInventoryId().intValue()).orElse(0);
    }
}
