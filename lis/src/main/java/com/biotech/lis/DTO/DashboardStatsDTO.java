package com.biotech.lis.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
    private int totalTransactions;
    private int totalOrders;
    private double totalOrderValue;
    private int totalQuantityTransacted;
    private String period; // "daily", "monthly", "yearly"
    private String dateRange; // e.g., "2024-07-16" or "2024-07" or "2024"
} 