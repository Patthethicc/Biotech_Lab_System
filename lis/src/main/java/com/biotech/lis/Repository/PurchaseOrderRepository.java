package com.biotech.lis.Repository;

import com.biotech.lis.Entity.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, String> {
    public PurchaseOrder findByItemCode(String code);
    void deleteByItemCode(String itemCode);
    Optional<PurchaseOrder> findTopByBrandIdOrderByItemCodeDesc(Integer brandId);
}
