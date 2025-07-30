package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.TransactionEntryRepository;

@Service
public class TransactionEntryService {

    @Autowired
    TransactionEntryRepository transactionEntryRepository;

    @Autowired
    StockLocatorService stockLocatorService;

    @Autowired
    UserService userService;

    @Autowired
    InventoryService inventoryService;

    @Transactional // rolls back automatically if any exception occurs
    public TransactionEntry createTransactionEntry(TransactionEntry transactionEntry) {

        validateTransactionEntry(transactionEntry);
        validateTransactionId(transactionEntry.getDrSIReferenceNum());
        
        // transaction ID must be unique
        if (transactionEntryRepository.existsById(transactionEntry.getDrSIReferenceNum())) {
            throw new IllegalArgumentException("Transaction already exists with ID: " + transactionEntry.getDrSIReferenceNum());
        }

        User user = getCurrentUser();
        setAuditFields(transactionEntry, user);

        TransactionEntry savedEntry = transactionEntryRepository.save(transactionEntry);
        stockLocatorService.updateStockFromTransaction(savedEntry, true);
        
        inventoryService.addInventory(savedEntry);

        return savedEntry;
    }
 
    public Optional<TransactionEntry> getTransactionEntryById(String id) {   
        validateTransactionId(id);
        return transactionEntryRepository.findById(id);
    }

    public List<TransactionEntry> getAllTransactionEntries() {
        return transactionEntryRepository.findAll();
    }

    @Transactional
    public TransactionEntry updateTransactionEntry(TransactionEntry transactionEntry) {
        validateTransactionEntry(transactionEntry);
        validateTransactionId(transactionEntry.getDrSIReferenceNum());

        // transaction must exist (checks by ID)
        if (!transactionEntryRepository.existsById(transactionEntry.getDrSIReferenceNum())) {
            throw new IllegalArgumentException("Transaction not found with ID: " + transactionEntry.getDrSIReferenceNum());
        }

        Integer prevQty = getTransactionEntryById(transactionEntry.getDrSIReferenceNum()).get().getQuantity();

        User user = getCurrentUser();
        setAuditFields(transactionEntry, user);
        TransactionEntry updatedEntry = transactionEntryRepository.save(transactionEntry);
        if(prevQty > transactionEntry.getQuantity()) {
            stockLocatorService.updateStockFromTransaction(updatedEntry, true);
        } else {
            stockLocatorService.updateStockFromTransaction(updatedEntry, false);
        }

        inventoryService.updateInventoryTrns(updatedEntry);

        return updatedEntry;
    }
    
    @Transactional
    public void deleteTransactionEntry(String id) {
        validateTransactionId(id);
        
        // transaction must exist (checks by ID)
        if (!transactionEntryRepository.existsById(id)) {
            throw new IllegalArgumentException("Transaction not found with ID: " + id);
        }
        
        transactionEntryRepository.deleteById(id);
    }

    public boolean existsById(String id) {
        if (id == null || id.trim().isEmpty()) {
            return false;
        }
        return transactionEntryRepository.existsById(id);
    }


    // HELPER METHODS

    // transactionEntry cannot be null
    private void validateTransactionEntry(TransactionEntry transactionEntry) {
        if (transactionEntry == null) {
            throw new IllegalArgumentException("Transaction entry cannot be null");
        }
    }

    // transaction ID cannot be null or empty
    private void validateTransactionId(String id) {
        if (id == null || id.trim().isEmpty()) {
            throw new IllegalArgumentException("Transaction ID cannot be null or empty");
        }
    }

    // get the current authenticated user
    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new IllegalArgumentException("No authenticated user found");
        }

        try {
            User user = userService.getUserById(Long.parseLong(auth.getName()));
            if (user == null) {
                throw new IllegalArgumentException("User not found with ID: " + auth.getName());
            }
            return user;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid user ID format: " + auth.getName());
        }
    }
    
    private void setAuditFields(TransactionEntry transactionEntry, User user) {
        LocalDateTime currentDateTime = LocalDateTime.now();
        transactionEntry.setAddedBy(user.getFirstName() + " " + user.getLastName());
        transactionEntry.setDateTimeAdded(currentDateTime);
    }
}