package com.biotech.lis.Repository;

import com.biotech.lis.Entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, String> {
    public PurchaseOrder findByItemCode(String code);
}
