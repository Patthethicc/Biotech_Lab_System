package com.biotech.lis.Service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.DTO.DashboardStatsDTO;
import com.biotech.lis.Repository.TransactionEntryRepository;
import com.biotech.lis.Entity.TransactionEntry;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class DashboardService {
    
    @Autowired
    private TransactionEntryRepository transactionRepository;
    
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
        List<TransactionEntry> allTransactions = transactionRepository.findAll();
        
        // Count transactions in date range
        int totalTransactions = (int) allTransactions.stream()
            .filter(t -> t.getTransactionDate() != null)
            .filter(t -> !t.getTransactionDate().isBefore(startDate) && !t.getTransactionDate().isAfter(endDate))
            .count();
            
        // Sum quantities in date range
        int totalQuantityTransacted = allTransactions.stream()
            .filter(t -> t.getTransactionDate() != null)
            .filter(t -> !t.getTransactionDate().isBefore(startDate) && !t.getTransactionDate().isAfter(endDate))
            .mapToInt(t -> t.getQuantity() != null ? t.getQuantity() : 0)
            .sum();
            
        // Sum order values in date range
        double totalTransactionValue = allTransactions.stream()
            .filter(t -> t.getTransactionDate() != null)
            .filter(t -> !t.getTransactionDate().isBefore(startDate) && !t.getTransactionDate().isAfter(endDate))
            .mapToDouble(t -> t.getCost())
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