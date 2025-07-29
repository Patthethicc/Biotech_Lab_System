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

import jakarta.persistence.EntityNotFoundException;
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

    @Autowired
    BrandService brandService;

    @Autowired
    StockLocatorService stockLocatorService;

    @Transactional
    public Inventory addInventory(TransactionEntry transactionEntry) {
        Inventory inventory = new Inventory();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        Brand brand = brandService.getBrandbyName(transactionEntry.getBrand());
        if (brand == null) {
            throw new EntityNotFoundException();
        }

        inventory.setItemCode(brandService.generateItemCode(brand));
        inventory.setBrand(transactionEntry.getBrand());
        inventory.setProductDescription(transactionEntry.getProductDescription());
        inventory.setLotSerialNumber(transactionEntry.getLotSerialNumber());
        inventory.setCost(transactionEntry.getQuantity() * transactionEntry.getCost());
        inventory.setExpiryDate(transactionEntry.getExpiryDate());

        String brandName = inventory.getBrand();
        String prodDesc = inventory.getProductDescription();

        inventory.setStocksManila(stockLocatorService.getManilaStock(brandName, prodDesc));
        inventory.setStocksCebu(stockLocatorService.getCebuStock(brandName, prodDesc));
        inventory.setQuantityOnHand(inventory.getStocksManila() + inventory.getStocksCebu());
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

    public Optional<Inventory> getInventoryByBrandAndProdDesc(String brand, String prodDesc) {
        return inventoryRepository.findByBrandAndProductDescription(brand, prodDesc);
    }

    public List<Inventory> getHighestStock() {
        List<Inventory> inventories = getInventories();
        inventories.sort((o1, o2)
                  -> o2.getQuantityOnHand().compareTo(
                      o1.getQuantityOnHand()));
        return inventories;
    }

    public List<Inventory> getLowestStock() {
        List<Inventory> inventories = getInventories();
        inventories.sort((o1, o2)
                  -> o1.getQuantityOnHand().compareTo(
                      o2.getQuantityOnHand()));
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

        existingInventory.setBrand(inventory.getBrand());
        existingInventory.setProductDescription(inventory.getProductDescription());
        existingInventory.setLotSerialNumber(inventory.getLotSerialNumber());
        existingInventory.setCost(inventory.getCost());
        existingInventory.setExpiryDate(inventory.getExpiryDate());

        String brandName = inventory.getBrand();
        String prodDesc = inventory.getProductDescription();

        existingInventory.setStocksManila(stockLocatorService.getManilaStock(brandName, prodDesc));
        existingInventory.setStocksCebu(stockLocatorService.getCebuStock(brandName, prodDesc));
        existingInventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        existingInventory.setDateTimeAdded(cDateTime);

        return inventoryRepository.save(existingInventory);
    }

    public Inventory updateInventoryTrns(TransactionEntry transactionEntry) {
        Optional<Inventory> invOpt = getInventoryByBrandAndProdDesc(transactionEntry.getBrand(), 
            transactionEntry.getProductDescription());
        if (invOpt == null) {
            throw new EntityNotFoundException();
        }
        Inventory existingInventory = invOpt.get();

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        Brand brand = brandService.getBrandbyName(transactionEntry.getBrand());
        if (brand == null) {
            throw new EntityNotFoundException();
        }

        existingInventory.setBrand(transactionEntry.getBrand());
        existingInventory.setProductDescription(transactionEntry.getProductDescription());
        existingInventory.setLotSerialNumber(transactionEntry.getLotSerialNumber());
        existingInventory.setCost(transactionEntry.getCost());
        existingInventory.setExpiryDate(transactionEntry.getExpiryDate());

        String brandName = transactionEntry.getBrand();
        String prodDesc = transactionEntry.getProductDescription();

        existingInventory.setStocksManila(stockLocatorService.getManilaStock(brandName, prodDesc));
        existingInventory.setStocksCebu(stockLocatorService.getCebuStock(brandName, prodDesc));
        existingInventory.setQuantityOnHand(existingInventory.getStocksManila() + existingInventory.getStocksCebu());
        existingInventory.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        existingInventory.setDateTimeAdded(cDateTime);

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
            return 0;
        }

        Optional<Inventory> found = inventoryRepository.findByItemCodeIgnoreCase(itemCode);
        return found.map(inv -> inv.getInventoryId().intValue()).orElse(0);
    }
}
