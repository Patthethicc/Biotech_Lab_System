package com.biotech.lis.Service;

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

    public TransactionEntry createTransactionEntry(TransactionEntry transactionEntry) {
        return transactionEntryRepository.save(transactionEntry);
    }
 
    public Optional<TransactionEntry> getTransactionEntryById(String id) {   
        return transactionEntryRepository.findById(id);
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

    // util method for updating transaction entry
    public boolean existsById(String id) {
        return transactionEntryRepository.existsById(id);
    }
}