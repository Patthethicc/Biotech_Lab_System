package com.biotech.lis.Service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Repository.PurchaseOrderRepository;

@Service
public class PurchaseOrderService {

    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public PurchaseOrder getPurchaseOrderById(String purchaseOrderCode) {
        return purchaseOrderRepository.getReferenceById(purchaseOrderCode);
    }

    public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder) {
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public void deleteByPurchaseOrderCode(String purchaseOrderCode) {
        purchaseOrderRepository.deleteById(purchaseOrderCode);
    }


}
