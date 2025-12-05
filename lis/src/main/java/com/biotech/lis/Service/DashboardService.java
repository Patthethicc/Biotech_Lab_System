package com.biotech.lis.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.DTO.DashboardStatsDTO;
import com.biotech.lis.Repository.CustomerTransactionRepository;
import com.biotech.lis.Entity.CustomerTransaction;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class DashboardService {
    
    @Autowired
    private CustomerTransactionRepository transactionRepository;
    
    public DashboardStatsDTO getDashboardStats(String period, String date) {
        LocalDate startDate;
        LocalDate endDate;
        String dateRange;
        
        switch (period.toLowerCase()) {
            case "daily":
                if (date != null && !date.isEmpty()) {
                    startDate = LocalDate.parse(date);
                    endDate = startDate;
                    dateRange = startDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
                } else {
                    startDate = LocalDate.now();
                    endDate = startDate;
                    dateRange = startDate.format(DateTimeFormatter.ISO_LOCAL_DATE);
                }
                break;
                
            case "monthly":
                if (date != null && !date.isEmpty()) {
                    YearMonth yearMonth = YearMonth.parse(date);
                    startDate = yearMonth.atDay(1);
                    endDate = yearMonth.atEndOfMonth();
                    dateRange = yearMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));
                } else {
                    YearMonth currentMonth = YearMonth.now();
                    startDate = currentMonth.atDay(1);
                    endDate = currentMonth.atEndOfMonth();
                    dateRange = currentMonth.format(DateTimeFormatter.ofPattern("yyyy-MM"));
                }
                break;
                
            case "yearly":
                int year;
                if (date != null && !date.isEmpty()) {
                    year = Integer.parseInt(date);
                } else {
                    year = LocalDate.now().getYear();
                }
                startDate = LocalDate.of(year, 1, 1);
                endDate = LocalDate.of(year, 12, 31);
                dateRange = String.valueOf(year);
                break;
                
            default:
                throw new IllegalArgumentException("Invalid period. Use 'daily', 'monthly', or 'yearly'");
        }
        
        // Get all data and filter manually (simpler approach)
        List<CustomerTransaction> allTransactions = transactionRepository.findAll();
        
        // Filter transactions in date range
        List<CustomerTransaction> filteredTransactions = allTransactions.stream()
            .filter(t -> t.getTransactionDate() != null)
            .filter(t -> {
                LocalDate txDate = t.getTransactionDate().toLocalDate();
                return !txDate.isBefore(startDate) && !txDate.isAfter(endDate);
            })
            .toList();

        // Count transactions
        int totalTransactions = filteredTransactions.size();
            
        // Sum quantities in date range (sum of all items in all filtered transactions)
        int totalQuantityTransacted = filteredTransactions.stream()
            .flatMap(t -> t.getItems().stream())
            .mapToInt(item -> item.getQuantity() != null ? item.getQuantity() : 0)
            .sum();
            
        // Sum order values in date range
        double totalTransactionValue = filteredTransactions.stream()
            .mapToDouble(t -> t.getTotalRetailPrice() != null ? t.getTotalRetailPrice() : 0.0)
            .sum();
        
        return new DashboardStatsDTO(
            totalTransactions,
            totalTransactionValue,
            totalQuantityTransacted,
            period,
            dateRange
        );
    }
    
    // Quick methods for current period stats
    public DashboardStatsDTO getTodayStats() {
        return getDashboardStats("daily", null);
    }
    
    public DashboardStatsDTO getCurrentMonthStats() {
        return getDashboardStats("monthly", null);
    }
    
    public DashboardStatsDTO getCurrentYearStats() {
        return getDashboardStats("yearly", null);
    }
}