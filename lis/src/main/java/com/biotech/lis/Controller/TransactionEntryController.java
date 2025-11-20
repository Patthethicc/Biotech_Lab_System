package com.biotech.lis.Controller;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Service.TransactionEntryService;
import com.biotech.lis.DTO.DashboardStatsDTO;
import com.biotech.lis.Service.DashboardService;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/transaction")
public class TransactionEntryController {

    private final TransactionEntryService transactionEntryService;
    
    @Autowired
    private DashboardService dashboardService;
    
    @Autowired
    public TransactionEntryController(TransactionEntryService transactionEntryService) {
        this.transactionEntryService = transactionEntryService;
    }

    @PostMapping("/createTransactionEntry")
    public ResponseEntity<TransactionEntry> createTransactionEntry(@RequestBody TransactionEntry transactionEntry) {
        try {
            TransactionEntry newTransactionEntry = transactionEntryService.createTransactionEntry(transactionEntry);
            return ResponseEntity.ok(newTransactionEntry);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build(); // invalid input
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // database error or other issues
        }
    }

    @GetMapping("/getTransactionByID/{id}")
    public ResponseEntity<TransactionEntry> getTransactionEntryById(@PathVariable("id") String id) {
        try {
            Optional<TransactionEntry> transactionEntry = transactionEntryService.getTransactionEntryById(id);        
            return transactionEntry.map(ResponseEntity::ok) // transaction found
                                  .orElse(ResponseEntity.notFound().build()); // transaction not found
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build(); // invalid input
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // database error or other issues
        }
    }

    @PutMapping("/updateTransaction/{id}")
    public ResponseEntity<TransactionEntry> updateTransactionEntry(@PathVariable("id") String id,  @RequestBody TransactionEntry transactionEntry) {
        try {
            transactionEntry.setDrSIReferenceNum(id);
            TransactionEntry updatedTransactionEntry = transactionEntryService.updateTransactionEntry(transactionEntry);
            return ResponseEntity.ok(updatedTransactionEntry); // transaction updated successfully
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build(); // invalid input
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // database error or other issues
        }
    }

    @DeleteMapping("/deleteTransactionEntry/{id}")
    public ResponseEntity<Void> deleteTransactionEntry(@PathVariable String id) {
        try {
            transactionEntryService.deleteTransactionEntry(id);
            return ResponseEntity.noContent().build(); // successful deletion
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build(); // invalid input
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // database error or other issues
        }
    }

    // util method for updating transaction entry
    @GetMapping("/exists/{id}")
    public ResponseEntity<Boolean> transactionExists(@PathVariable("id") String id) {
        try {
            boolean exists = transactionEntryService.existsById(id);
            return ResponseEntity.ok(exists); // returns true/false
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // database error or other issues
        }
    }

    @GetMapping("/all") // gets all the transactions
    public ResponseEntity<Iterable<TransactionEntry>> getAllTransactions() {
        try {
            Iterable<TransactionEntry> allEntries = transactionEntryService.getAllTransactionEntries();
            return ResponseEntity.ok(allEntries); // returns all transaction entries
        } catch (Exception e) { 
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // database error or other issues
        }
    }

    // NEW DASHBOARD ENDPOINTS:
    
    @GetMapping("/dashboard/stats")
    public ResponseEntity<DashboardStatsDTO> getDashboardStats(
            @RequestParam String period,
            @RequestParam(required = false) String date) {
        try {
            DashboardStatsDTO stats = dashboardService.getDashboardStats(period, date);
            return ResponseEntity.ok(stats);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/dashboard/today")
    public ResponseEntity<DashboardStatsDTO> getTodayStats() {
        DashboardStatsDTO stats = dashboardService.getTodayStats();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/dashboard/current-month")
    public ResponseEntity<DashboardStatsDTO> getCurrentMonthStats() {
        DashboardStatsDTO stats = dashboardService.getCurrentMonthStats();
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/dashboard/current-year")
    public ResponseEntity<DashboardStatsDTO> getCurrentYearStats() {
        DashboardStatsDTO stats = dashboardService.getCurrentYearStats();
        return ResponseEntity.ok(stats);
    }
}