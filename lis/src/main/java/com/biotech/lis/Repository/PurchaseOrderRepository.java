package com.biotech.lis.Repository;

import com.biotech.lis.Entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, String> {
    @Query("SELECT po FROM PurchaseOrder po WHERE NOT EXISTS (SELECT 1 FROM Inventory i WHERE i.itemCode = po.itemCode)")
    List<PurchaseOrder> findAvailablePurchaseOrders();
    public PurchaseOrder findByItemCode(String code);
    void deleteByItemCode(String itemCode);
    Optional<PurchaseOrder> findTopByBrandIdOrderByItemCodeDesc(Integer brandId);
}
