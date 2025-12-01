package com.biotech.lis.Controller;

import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Entity.CustomerTransaction;
import com.biotech.lis.Entity.Sold;
import com.biotech.lis.Repository.CustomerTransactionRepository;
import com.biotech.lis.DTO.DashboardStatsDTO;
import com.biotech.lis.Service.DashboardService;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/transaction")
public class TransactionEntryController {

    @Autowired
    private CustomerTransactionRepository customerTransactionRepository;

    @Autowired
    private com.biotech.lis.Repository.TransactionEntryRepository transactionEntryRepository;
    
    @Autowired
    private DashboardService dashboardService;
    
    // Deprecated: Use CustomerTransactionController for creation
    @PostMapping("/createTransactionEntry")
    public ResponseEntity<TransactionEntry> createTransactionEntry(@RequestBody TransactionEntry transactionEntry) {
        return ResponseEntity.status(HttpStatus.GONE).build();
    }

    // Deprecated: Use CustomerTransactionController
    @GetMapping("/getTransactionByID/{id}")
    public ResponseEntity<TransactionEntry> getTransactionEntryById(@PathVariable("id") String id) {
         return ResponseEntity.status(HttpStatus.GONE).build();
    }

    // Deprecated: Use CustomerTransactionController
    @PutMapping("/updateTransaction/{id}")
    public ResponseEntity<TransactionEntry> updateTransactionEntry(@PathVariable("id") String id,  @RequestBody TransactionEntry transactionEntry) {
        return ResponseEntity.status(HttpStatus.GONE).build();
    }

    // Deprecated: Use CustomerTransactionController
    @DeleteMapping("/deleteTransactionEntry/{id}")
    public ResponseEntity<Void> deleteTransactionEntry(@PathVariable String id) {
        return ResponseEntity.status(HttpStatus.GONE).build();
    }

    // util method for updating transaction entry
    @GetMapping("/exists/{id}")
    public ResponseEntity<Boolean> transactionExists(@PathVariable("id") String id) {
        // Not easily mappable as IDs are different now
        return ResponseEntity.ok(false);
    }

    @GetMapping("/all") // gets all the transactions mapped to old format for compatibility
    public ResponseEntity<Iterable<TransactionEntry>> getAllTransactions() {
        try {
            // 1. Fetch Legacy Transactions
            List<TransactionEntry> allEntries = new ArrayList<>();
            allEntries.addAll(transactionEntryRepository.findAll());

            // 2. Fetch New Transactions and Map
            List<CustomerTransaction> customerTransactions = customerTransactionRepository.findAll();

            for (CustomerTransaction ct : customerTransactions) {
                if (ct.getItems() != null) {
                    for (Sold item : ct.getItems()) {
                        TransactionEntry entry = new TransactionEntry();
                        entry.setDrSIReferenceNum(ct.getInvoiceReference() != null ? ct.getInvoiceReference() : "N/A");
                        entry.setTransactionDate(ct.getTransactionDate() != null ? ct.getTransactionDate().toLocalDate() : LocalDate.now());
                        entry.setBrand(item.getBrandName() != null ? item.getBrandName() : "N/A");
                        entry.setProductDescription(item.getItemDescription() != null ? item.getItemDescription() : "N/A");
                        entry.setLotSerialNumber(item.getLotNumber() != null ? item.getLotNumber() : "N/A");
                        // Expiry date is not in Sold item, default to today or handle gracefully
                        entry.setExpiryDate(LocalDate.now()); 
                        entry.setCost(item.getUnitRetailPrice() != null ? item.getUnitRetailPrice() : 0.0);
                        entry.setQuantity(item.getQuantity() != null ? item.getQuantity() : 0);
                        entry.setStockLocation(item.getLocation() != null ? item.getLocation() : "N/A");
                        entry.setItemCode(item.getItemId() != null ? item.getItemId() : "N/A");
                        entry.setAddedBy(null); 
                        entry.setDateTimeAdded(ct.getTransactionDate() != null ? ct.getTransactionDate() : java.time.LocalDateTime.now());
                        
                        allEntries.add(entry);
                    }
                }
            }

            // 3. Sort by Date (Descending)
            allEntries.sort((t1, t2) -> {
                if (t1.getTransactionDate() == null) return 1;
                if (t2.getTransactionDate() == null) return -1;
                return t2.getTransactionDate().compareTo(t1.getTransactionDate());
            });

            return ResponseEntity.ok(allEntries); 
        } catch (Exception e) { 
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); 
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