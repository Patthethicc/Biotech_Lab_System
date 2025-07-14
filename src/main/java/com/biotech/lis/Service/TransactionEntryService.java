package com.biotech.lis.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Repository.TransactionEntryRepository;

@Service
public class TransactionEntryService {

    @Autowired
    TransactionEntryRepository transactionEntryRepository;

    @Autowired
    StockLocatorService stockLocatorService;

    public TransactionEntry createTransactionEntry(TransactionEntry transactionEntry) {

        TransactionEntry savedEntry = transactionEntryRepository.save(transactionEntry);
        
        stockLocatorService.updateStockFromTransaction(savedEntry, true); // automatically update stockLocator
        
        return savedEntry;        
    }
 
    public Optional<TransactionEntry> getTransactionEntryById(String id) {   
        return transactionEntryRepository.findById(id);
    }

    public List<TransactionEntry> getAllTransactionEntries() {
        return transactionEntryRepository.findAll();
    }

    public TransactionEntry updateTransactionEntry(TransactionEntry transactionEntry) {
        if (transactionEntryRepository.existsById(transactionEntry.getDrSIReferenceNum())) {
            return transactionEntryRepository.save(transactionEntry);
        } else {
            throw new RuntimeException("Transaction entry not found with ID: " + transactionEntry.getDrSIReferenceNum());
        }
    }

    public void deleteTransactionEntry(String id) {
        transactionEntryRepository.deleteById(id);
    }

    public boolean existsById(String id) {
        return transactionEntryRepository.existsById(id);
    }
}