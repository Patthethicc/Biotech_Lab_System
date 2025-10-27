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
    public Inventory addInventory(Inventory inventory) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();

        //Data from purchase order
        inventory.setPoPireference(inventory.getPoPireference());
        inventory.setItemCode(inventory.getItemCode());
        inventory.setBrandId(inventory.getBrandId());
        inventory.setItemDescription(inventory.getItemDescription());
        inventory.setPackSize(inventory.getPackSize());
        
        //Manual
        inventory.setCostOfSale(inventory.getCostOfSale());
        inventory.setQuantity(inventory.getQuantity());
        inventory.setInvoiceNum(inventory.getInvoiceNum());
        inventory.setLotNum(inventory.getLotNum());
        inventory.setExpiry(inventory.getExpiry());

        inventory.setNote(inventory.getNote());

        //not for front end
        inventory.setAddedBy(user.getUserId());
        inventory.setDateTimeAdded(cDateTime);

        //Check that itemCode is not null
        if (inventory.getItemCode() == null || inventory.getItemCode().isBlank()) {
            throw new IllegalArgumentException("Item code must be provided.");
        }
        return inventoryRepository.save(inventory);
    }

    public Inventory getInventoryByCode(String itemCode) {
        return inventoryRepository.getReferenceById(itemCode);
    }

    public List<Inventory> getInventories() {
        return inventoryRepository.findAll();
    }

    // public Optional<Inventory> getInventoryByBrandAndProdDesc(String brand, String prodDesc) {
    //     return inventoryRepository.findByBrandAndProductDescription(brand, prodDesc);
    // }

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

    // public Inventory updateInventoryTrns(TransactionEntry transactionEntry) {
    //     Optional<Inventory> invOpt = getInventoryByBrandAndProdDesc(transactionEntry.getBrand(), 
    //         transactionEntry.getProductDescription());
    //     if (invOpt == null) {
    //         throw new EntityNotFoundException();
    //     }
    //     Inventory existingInventory = invOpt.get();
    // 
    //     Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    //     User user = userService.getUserById(Long.parseLong(auth.getName()));
    //     LocalDateTime cDateTime = LocalDateTime.now();
    //     Brand brand = brandService.getBrandbyName(transactionEntry.getBrand());
    //     if (brand == null) {
    //         throw new EntityNotFoundException();
    //     }
    // 
    //     existingInventory.setBrand(transactionEntry.getBrand());
    //     existingInventory.setProductDescription(transactionEntry.getProductDescription());
    //     existingInventory.setLotSerialNumber(transactionEntry.getLotSerialNumber());
    //     existingInventory.setCost(transactionEntry.getCost());
    //     existingInventory.setExpiryDate(transactionEntry.getExpiryDate());
    // 
    //     String brandName = transactionEntry.getBrand();
    //     String prodDesc = transactionEntry.getProductDescription();
    // 
    //     existingInventory.setStocksManila(stockLocatorService.getManilaStock(brandName, prodDesc));
    //     existingInventory.setStocksCebu(stockLocatorService.getCebuStock(brandName, prodDesc));
    //     existingInventory.setQuantityOnHand(existingInventory.getStocksManila() + existingInventory.getStocksCebu());
    //     existingInventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
    //     existingInventory.setDateTimeAdded(cDateTime);
    // 
    //     PurchaseOrder purchaseOrder = purchaseOrderRepository.findByItemCode(transactionEntry.getItemCode());
    //     
    //     purchaseOrder.setBrand(brandName);
    //     purchaseOrder.setProductDescription(prodDesc);
    //     // purchaseOrder.setLotSerialNumber(transactionEntry.getLotSerialNumber());
    //     // purchaseOrder.setOrderDate(transactionEntry.getDateTimeAdded().toLocalDate());
    //     // purchaseOrder.setDrSIReferenceNum(transactionEntry.getDrSIReferenceNum());
    //     // purchaseOrder.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
    //     // purchaseOrder.setDateTimeAdded(cDateTime);
    // 
    //     purchaseOrderRepository.save(purchaseOrder);
    // 
    //     return inventoryRepository.save(existingInventory);
    // }

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
