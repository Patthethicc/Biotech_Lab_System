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
import com.biotech.lis.Entity.Location;
import com.biotech.lis.Repository.InventoryRepository;
import com.biotech.lis.Repository.ItemLocRepository;
import com.biotech.lis.Repository.LocationRepository;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import com.biotech.lis.Repository.TransactionEntryRepository;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;

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

    @Autowired
    private LocationRepository locationRepository;

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
        
        Inventory finalSavedInv = inventoryRepository.save(savedInv);
        
        // Sync to Stock Locator
        syncToStockLocator(finalSavedInv, payload.getLocations());
        
        return finalSavedInv;
    }

    public Inventory getInventoryByCode(String itemCode) {
        return inventoryRepository.getReferenceById(itemCode);
    }

    public List<Inventory> getInventories() {
        return inventoryRepository.findAll();
    }

public List<InventoryPayload> getHighestStock() {
        List<Inventory> inventories = inventoryRepository.findAll();
        inventories.sort((o1, o2) -> o2.getQuantity().compareTo(o1.getQuantity()));
        
        return inventories.stream()
            .map(inv -> new InventoryPayload(inv, itemLocRepository.findByItemCode(inv.getItemCode())))
            .collect(Collectors.toList());
    }

    public List<InventoryPayload> getLowestStock() {
        List<Inventory> inventories = inventoryRepository.findAll();
        inventories.sort((o1, o2) -> o1.getQuantity().compareTo(o2.getQuantity()));

        return inventories.stream()
            .map(inv -> new InventoryPayload(inv, itemLocRepository.findByItemCode(inv.getItemCode())))
            .collect(Collectors.toList());
    }

    @Transactional
    public InventoryPayload updateInventory(InventoryPayload payload) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();


        Inventory inventory = payload.getInventory();
        List<ItemLoc> newLocations = payload.getLocations();

        Inventory existingInventory = getInventoryByCode(inventory.getItemCode());

        if (existingInventory == null) {
            throw new IllegalArgumentException(
                "Inventory with code " + inventory.getItemCode() + " not found"
            );
        }

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

        Inventory savedInventory = inventoryRepository.save(existingInventory);

        itemLocRepository.deleteByItemCode(savedInventory.getItemCode());
        for (ItemLoc loc : newLocations) {
            loc.setItemCode(savedInventory.getItemCode());
            itemLocRepository.save(loc);
        }

        List<ItemLoc> savedLocations = itemLocRepository.findByItemCode(savedInventory.getItemCode());

        // Sync to Stock Locator
        syncToStockLocator(savedInventory, savedLocations);

        InventoryPayload newPayload = new InventoryPayload(savedInventory, savedLocations);

        return newPayload;
    }

    @Transactional
    public void deleteByInventoryId(String itemcode) {
        itemLocRepository.deleteByItemCode(itemcode);
        inventoryRepository.deleteById(itemcode);
        // Also delete from StockLocator
        try {
            stockLocatorService.deleteStockLocator(itemcode);
        } catch (Exception e) {
            System.err.println("Failed to delete from StockLocator: " + e.getMessage());
        }
    }

    public List<InventoryPayload> getStockAlerts(Integer amount) {
        List<Inventory> inventories = inventoryRepository.findByQuantityLessThanEqual(amount);
        return inventories.stream()
                .map(inv -> new InventoryPayload(inv, itemLocRepository.findByItemCode(inv.getItemCode())))
                .collect(Collectors.toList());
    }

    public void syncAllInventoryToStockLocator() {
        List<InventoryPayload> payloads = getInventoriesWithLocations();
        for (InventoryPayload payload : payloads) {
            syncToStockLocator(payload.getInventory(), payload.getLocations());
        }
    }

    private void syncToStockLocator(Inventory inventory, List<ItemLoc> locations) {
        try {
            Brand brand = brandService.getBrandById(inventory.getBrandId());
            String brandName = brand != null ? brand.getBrandName() : "Unknown";
            
            java.util.Map<Integer, String> locIdToName = locationRepository.findAll().stream()
                .collect(Collectors.toMap(Location::getLocationId, Location::getLocationName));
            
            java.util.Map<String, Integer> locQuantities = new java.util.HashMap<>();
            for (ItemLoc loc : locations) {
                String name = locIdToName.get(loc.getLocationId());
                if (name != null) {
                    locQuantities.put(name, loc.getQuantity());
                }
            }
            
            stockLocatorService.updateStockFromInventory(
                inventory.getItemCode(), 
                brandName, 
                inventory.getItemDescription(), 
                locQuantities
            );
        } catch (Exception e) {
            System.err.println("ERROR: Failed to sync to StockLocator: " + e.getMessage());
            e.printStackTrace();
        }
    }
    public Inventory searchInventory(String brandName, String description) {
        try {
            Brand brand = brandService.getBrandbyName(brandName);
            if (brand == null) return null;
            
            List<Inventory> allInventory = inventoryRepository.findAll();
            return allInventory.stream()
                .filter(i -> i.getBrandId() != null && i.getBrandId().equals(brand.getBrandId()) && 
                             i.getItemDescription() != null && i.getItemDescription().equalsIgnoreCase(description))
                .findFirst()
                .orElse(null);
        } catch (Exception e) {
            System.err.println("Error searching inventory: " + e.getMessage());
            return null;
        }
    }
}
