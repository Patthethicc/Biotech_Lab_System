package com.biotech.lis.Repository;

import com.biotech.lis.Entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, String> {
    public PurchaseOrder findByPurchaseOrderCode(String code);
}
