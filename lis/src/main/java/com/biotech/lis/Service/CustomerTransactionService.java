package com.biotech.lis.Service;

import com.biotech.lis.Entity.CustomerTransaction;
import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.ItemLoc;
import com.biotech.lis.Entity.Location;
import com.biotech.lis.Entity.Sold;
import com.biotech.lis.Repository.CustomerTransactionRepository;
import com.biotech.lis.Repository.InventoryRepository;
import com.biotech.lis.Repository.ItemLocRepository;
import com.biotech.lis.Repository.LocationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class CustomerTransactionService {

    private final CustomerTransactionRepository repository;
    private final ItemLocRepository itemLocRepository;
    private final InventoryRepository inventoryRepository;
    private final LocationRepository locationRepository;

    @Autowired
    public CustomerTransactionService(CustomerTransactionRepository repository,
                                      ItemLocRepository itemLocRepository,
                                      InventoryRepository inventoryRepository,
                                      LocationRepository locationRepository) {
        this.repository = repository;
        this.itemLocRepository = itemLocRepository;
        this.inventoryRepository = inventoryRepository;
        this.locationRepository = locationRepository;
    }

    @Transactional
    public CustomerTransaction createTransaction(CustomerTransaction transaction) {
        // Check for duplicate invoice reference
        if (repository.existsByInvoiceReference(transaction.getInvoiceReference())) {
            throw new IllegalArgumentException("Invoice reference already exists: " + transaction.getInvoiceReference());
        }

        // Deduct stock for each item
        if (transaction.getItems() != null) {
            for (Sold item : transaction.getItems()) {
                if (item.getLocation() != null && !item.getLocation().isEmpty()) {
                    deductStock(item);
                }
            }
        }
        return repository.save(transaction);
    }

    private void deductStock(Sold item) {
        // Find Location ID by Name
        Location location = locationRepository.findByLocationName(item.getLocation())
                .orElseThrow(() -> new IllegalArgumentException("Location not found: " + item.getLocation()));

      
        
        List<ItemLoc> itemLocs = itemLocRepository.findByItemCode(item.getItemId());
        ItemLoc targetLoc = itemLocs.stream()
                .filter(il -> il.getLocationId().equals(location.getLocationId()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Item " + item.getItemId() + " not found at location " + item.getLocation()));

        // Deduct Quantity
        if (targetLoc.getQuantity() < item.getQuantity()) {
            throw new IllegalArgumentException("Insufficient stock for item " + item.getItemDescription() + " at " + item.getLocation());
        }
        targetLoc.setQuantity(targetLoc.getQuantity() - item.getQuantity());
        itemLocRepository.save(targetLoc);

        // Update Inventory Total Quantity
        Inventory inventory = inventoryRepository.findById(item.getItemId())
                .orElseThrow(() -> new IllegalArgumentException("Inventory item not found: " + item.getItemId()));
        
        // Ensure inventory quantity is not null
        int currentTotal = inventory.getQuantity() != null ? inventory.getQuantity() : 0;
        inventory.setQuantity(currentTotal - item.getQuantity());
        inventoryRepository.save(inventory);
    }

    public List<CustomerTransaction> getAllTransactions() {
        return repository.findAll();
    }

    public void deleteTransaction(Long id) {
        repository.deleteById(id);
    }
}
