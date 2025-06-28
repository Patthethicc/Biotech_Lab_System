package com.biotech.lis.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Repository.TransactionEntryRepository;

@Service
public class TransactionEntryService {

    @Autowired
    TransactionEntryRepository transactionEntryRepository;

    public TransactionEntry saveTransactionEntry(TransactionEntry transactionEntry) {
        return transactionEntryRepository.save(transactionEntry);
    }
/* 
    public  TransactionEntry getTransactionEntryById(String id) {   
        transactionEntryRepository.find
    }
*/
}