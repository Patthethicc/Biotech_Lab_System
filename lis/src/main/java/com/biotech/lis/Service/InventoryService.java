package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.InventoryRepository;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.Authentication;

@Service
public class InventoryService {
    @Autowired
    InventoryRepository inventoryRepository;

    @Autowired
    UserService userService;

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

    public Inventory updateInventory(Inventory inventory) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        inventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        inventory.setDateTimeAdded(cDateTime);
        return inventoryRepository.save(inventory);
    }

    public void deleteByInventoryId(Integer inventoryId) {
        inventoryRepository.deleteById(inventoryId);
    }

    public List<Inventory> getStockAlerts(Integer amount) {
        return inventoryRepository.findByQuantityOnHandLessThan(amount);
    }
}
