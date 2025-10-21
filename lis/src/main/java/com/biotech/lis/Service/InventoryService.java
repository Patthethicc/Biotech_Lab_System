package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.InventoryRepository;
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

    @Transactional
    public Inventory addInventory(Inventory inventory) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();

        //Data from purchase order
        inventory.setPoPIreference(inventory.getPoPIreference());
        inventory.setItemCode(inventory.getItemCode());
        inventory.setBrand(inventory.getBrand());
        inventory.setItemDescription(inventory.getItemDescription());
        inventory.setPackSize(inventory.getPackSize());

        //Manual
        inventory.setCostOfSale(inventory.getCostOfSale());
        inventory.setQuantity(inventory.getQuantity());
        inventory.setInvoiceNum(inventory.getInvoiceNum());
        inventory.setLotNumber(inventory.getLotNumber());
        inventory.setExpiryDate(inventory.getExpiryDate());
        inventory.setLocations(inventory.getLocations());
        inventory.setNote(inventory.getNote());

        //not for front end
        inventory.setAddedBy(user.getFirstName() + " " + user.getLastName());
        inventory.setDateTimeAdded(cDateTime);

        return inventoryRepository.save(inventory);
    }

    public Inventory getInventoryById(Integer inventoryId) {
        return inventoryRepository.getReferenceById(inventoryId);
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
        Inventory existingInventory = getInventoryById(inventory.getInventoryId());
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        Brand brand = brandService.getBrandbyName(inventory.getBrand());
        if (brand == null) {
            throw new EntityNotFoundException();
        }

        existingInventory.setPoPIreference(inventory.getPoPIreference());
        existingInventory.setInvoiceNum(inventory.getInvoiceNum());
        existingInventory.setItemCode(inventory.getItemCode());
        existingInventory.setItemDescription(inventory.getItemDescription());
        existingInventory.setBrand(inventory.getBrand());
        existingInventory.setLotNumber(inventory.getLotNumber());
        existingInventory.setExpiryDate(inventory.getExpiryDate());
        existingInventory.setPackSize(inventory.getPackSize());
        existingInventory.setQuantity(inventory.getQuantity());
        existingInventory.setCostOfSale(inventory.getCostOfSale());
        existingInventory.setLocations(inventory.getLocations());
        existingInventory.setNote(inventory.getNote());

        existingInventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
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
    public void deleteByInventoryId(Integer inventoryId) {
        inventoryRepository.deleteById(inventoryId);
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
