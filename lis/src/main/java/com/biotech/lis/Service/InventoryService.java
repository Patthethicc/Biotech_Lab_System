package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.InventoryPayload;
import com.biotech.lis.Entity.ItemLoc;
import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.InventoryRepository;
import com.biotech.lis.Repository.ItemLocRepository;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import com.biotech.lis.Repository.TransactionEntryRepository;
import com.biotech.lis.Entity.PurchaseOrder;

import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;

@Service
public class InventoryService {
    @Autowired
    InventoryRepository inventoryRepository;

    @Autowired
    UserService userService;

    @Autowired
    BrandService brandService;

    @Autowired
    StockLocatorService stockLocatorService;

    @Autowired
    PurchaseOrderService purchaseOrderService;

    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    TransactionEntryRepository transactionEntryRepository;

    @Autowired
    private ItemLocRepository itemLocRepository;

    public List<InventoryPayload> getInventoriesWithLocations() {
        List<Inventory> inventories = inventoryRepository.findAll();
    
        return inventories.stream()
                .map(inv -> new InventoryPayload(inv, itemLocRepository.findByItemCode(inv.getItemCode())))
                .collect(Collectors.toList());
    }

    @Transactional
    public Inventory addInventory(InventoryPayload payload) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();

        //not from front end
        Inventory inventory = payload.getInventory();
        inventory.setAddedBy(user.getUserId());
        inventory.setDateTimeAdded(cDateTime);

        Inventory savedInv = inventoryRepository.save(inventory);

        //saving locations
        for (ItemLoc loc: payload.getLocations()){
            loc.setItemCode(savedInv.getItemCode()); //save itemcode to loc
            itemLocRepository.save(loc);
        }
        
        return inventoryRepository.save(savedInv);
    }

    public Inventory getInventoryByCode(String itemCode) {
        return inventoryRepository.getReferenceById(itemCode);
    }

    public List<Inventory> getInventories() {
        return inventoryRepository.findAll();
    }

    public List<Inventory> getHighestStock() {
        List<Inventory> inventories = getInventories();
        inventories.sort((o1, o2)
                  -> o2.getQuantity().compareTo(
                      o1.getQuantity()));
        return inventories;
    }

    public List<Inventory> getLowestStock() {
        List<Inventory> inventories = getInventories();
        inventories.sort((o1, o2)
                  -> o1.getQuantity().compareTo(
                      o2.getQuantity()));
        return inventories;
    }

    @Transactional
    public Inventory updateInventoryInv(Inventory inventory) {
        Inventory existingInventory = getInventoryByCode(inventory.getItemCode());

        if (existingInventory == null) {
            throw new IllegalArgumentException(
                "Inventory with code " + inventory.getItemCode() + " not found"
            );
        }

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();

        existingInventory.setPoPireference(inventory.getPoPireference());
        existingInventory.setInvoiceNum(inventory.getInvoiceNum());
        existingInventory.setItemDescription(inventory.getItemDescription());
        existingInventory.setBrandId(inventory.getBrandId());
        existingInventory.setLotNum(inventory.getLotNum());
        existingInventory.setExpiry(inventory.getExpiry());
        existingInventory.setPackSize(inventory.getPackSize());
        existingInventory.setQuantity(inventory.getQuantity());
        existingInventory.setCostOfSale(inventory.getCostOfSale());
        existingInventory.setNote(inventory.getNote());

        existingInventory.setAddedBy(user.getUserId());
        existingInventory.setDateTimeAdded(cDateTime);

        return inventoryRepository.save(existingInventory);
    }

    @Transactional
    public void deleteByInventoryId(String itemcode) {
        inventoryRepository.deleteById(itemcode);
    }

    // public List<Inventory> getStockAlerts(Integer amount) {
    //     return inventoryRepository.findByQuantityOnHandLessThan(amount);
    // }
    // 
    // public Integer inventoryExists(Inventory inventory) {
    //     String itemCode = inventory.getItemCode();
    //     if (itemCode == null || itemCode.trim().isEmpty()) {
    //         return 0;
    //     }
    // 
    //     Optional<Inventory> found = inventoryRepository.findByItemCodeIgnoreCase(itemCode);
    //     return found.map(inv -> inv.getInventoryId().intValue()).orElse(0);
    // }
}
