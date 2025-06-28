package com.biotech.lis.Controller;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Service.TransactionEntryService;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
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

    @PostMapping("/addTransactionEntry")
    public ResponseEntity<TransactionEntry> saveTransactionEntry(@RequestBody TransactionEntry transactionEntry) {
        TransactionEntry savedTransactionEntry = transactionEntryService.saveTransactionEntry(transactionEntry);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedTransactionEntry);
    }

  /*   @GetMapping("/getTransactionByID")
    public ResponseEntity<TransactionEntry> getTransactionEntryById(@RequestParam("id") String id) {
        TransactionEntry transactionEntry = transactionEntryService.getTransactionEntryById(id);
    }
*/
}