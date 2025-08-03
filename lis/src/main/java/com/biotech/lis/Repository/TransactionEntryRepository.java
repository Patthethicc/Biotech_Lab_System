package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.TransactionEntry;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionEntryRepository extends JpaRepository<TransactionEntry, String> {
    
    // Count transactions by date range
    @Query("SELECT COUNT(t) FROM TransactionEntry t WHERE t.transactionDate BETWEEN :startDate AND :endDate")
    int countTransactionsByDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    // Sum quantities by date range
    @Query("SELECT COALESCE(SUM(t.quantity), 0) FROM TransactionEntry t WHERE t.transactionDate BETWEEN :startDate AND :endDate")
    int sumQuantitiesByDateRange(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    
    // Get transactions by date range
    List<TransactionEntry> findByTransactionDateBetween(LocalDate startDate, LocalDate endDate);
    
    // Count transactions for a specific date
    int countByTransactionDate(LocalDate date);
    
    // Count transactions for current day
    @Query("SELECT COUNT(t) FROM TransactionEntry t WHERE DATE(t.transactionDate) = CURRENT_DATE")
    int countTodaysTransactions();
    
    // Count transactions for current month
    @Query("SELECT COUNT(t) FROM TransactionEntry t WHERE YEAR(t.transactionDate) = YEAR(CURRENT_DATE) AND MONTH(t.transactionDate) = MONTH(CURRENT_DATE)")
    int countCurrentMonthTransactions();
    
    // Count transactions for current year
    @Query("SELECT COUNT(t) FROM TransactionEntry t WHERE YEAR(t.transactionDate) = YEAR(CURRENT_DATE)")
    int countCurrentYearTransactions();

    List<TransactionEntry> findByTransactionDateBetween(Date startDate, Date endDate);

    void deleteByItemCode(String itemCode);

    Optional<TransactionEntry> findByItemCode(String itemCode);
}