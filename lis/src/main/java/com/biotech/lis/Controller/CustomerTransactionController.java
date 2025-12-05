package com.biotech.lis.Controller;

import com.biotech.lis.Entity.CustomerTransaction;
import com.biotech.lis.Service.CustomerTransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/sales/v1")
public class CustomerTransactionController {

    private final CustomerTransactionService service;

    @Autowired
    public CustomerTransactionController(CustomerTransactionService service) {
        this.service = service;
    }

    @PostMapping("/createTransaction")
    public ResponseEntity<CustomerTransaction> createTransaction(@RequestBody CustomerTransaction transaction) {
        System.out.println("Received Transaction: " + transaction);
        System.out.println("Total Price: " + transaction.getTotalRetailPrice());
        if (transaction.getItems() != null) {
            System.out.println("Items count: " + transaction.getItems().size());
            transaction.getItems().forEach(item -> System.out.println("Item: " + item.getItemDescription() + ", Price: " + item.getUnitRetailPrice()));
        }
        return ResponseEntity.ok(service.createTransaction(transaction));
    }

    @GetMapping("/getTransactions")
    public ResponseEntity<List<CustomerTransaction>> getTransactions() {
        return ResponseEntity.ok(service.getAllTransactions());
    }

    @DeleteMapping("/deleteTransaction/{id}")
    public ResponseEntity<Void> deleteTransaction(@PathVariable Long id) {
        service.deleteTransaction(id);
        return ResponseEntity.ok().build();
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<String> handleIllegalArgumentException(IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    }
}
