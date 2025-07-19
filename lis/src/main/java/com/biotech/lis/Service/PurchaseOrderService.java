package com.biotech.lis.Service;


import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class PurchaseOrderService {

    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public PurchaseOrder getPurchaseOrderByCode(String code) {
        return purchaseOrderRepository.findByPurchaseOrderCode(code);
    }

    public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder) {
        return purchaseOrderRepository.save(purchaseOrder);
    }
    public void deletePurchaseOrder(String code) {
        purchaseOrderRepository.deleteById(code);
    }


}
