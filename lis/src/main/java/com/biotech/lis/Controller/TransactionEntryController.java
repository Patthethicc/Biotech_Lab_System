package com.biotech.lis.Controller;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Service.TransactionEntryService;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/transaction")
public class TransactionEntryController {

    private final TransactionEntryService transactionEntryService;
    @Autowired
    public TransactionEntryController(TransactionEntryService transactionEntryService) {
        this.transactionEntryService = transactionEntryService;
    }

    @PostMapping("/createTransactionEntry")
    public ResponseEntity<TransactionEntry> createTransactionEntry(@RequestBody TransactionEntry transactionEntry) {
        TransactionEntry newTransactionEntry = transactionEntryService.createTransactionEntry(transactionEntry);
        return ResponseEntity.ok(newTransactionEntry);
    }

    @GetMapping("/getTransactionByID/{id}")
    public ResponseEntity<TransactionEntry> getTransactionEntryById(@PathVariable("id") String id) {
        Optional<TransactionEntry> transactionEntry = transactionEntryService.getTransactionEntryById(id);        
        if (transactionEntry.isPresent()) {
            return ResponseEntity.ok(transactionEntry.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PutMapping("/updateTransaction/{id}")
    public ResponseEntity<TransactionEntry> updateTransactionEntry(@PathVariable("id") String id,  @RequestBody TransactionEntry transactionEntry) {
        try {
            transactionEntry.setDrSIReferenceNum(id);
            
            TransactionEntry updatedTransactionEntry = transactionEntryService.updateTransactionEntry(transactionEntry);
            return ResponseEntity.ok(updatedTransactionEntry);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @DeleteMapping("/deleteTransaction/{id}")
    public ResponseEntity<TransactionEntry> deleteTransactionEntry(@PathVariable("id") String id) {
        transactionEntryService.deleteTransactionEntry(id);
        return ResponseEntity.ok().build(); 
    }



    // util method for updating transaction entry
    @GetMapping("/exists/{id}")
    public ResponseEntity<Boolean> transactionExists(@PathVariable("id") String id) {
        boolean exists = transactionEntryService.existsById(id);
        return ResponseEntity.ok(exists);
    }

    @GetMapping("/all") // gets all the transactions
    public ResponseEntity<Iterable<TransactionEntry>> getAllTransactions() {
        Iterable<TransactionEntry> allEntries = transactionEntryService.getAllTransactionEntries();
        return ResponseEntity.ok(allEntries);
    }

}