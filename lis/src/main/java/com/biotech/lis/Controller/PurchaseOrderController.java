package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Service.PurchaseOrderService;

@RestController
@RequestMapping("/po/v1")
public class PurchaseOrderController {

    private final PurchaseOrderService purchaseOrderService;

    public PurchaseOrderController(PurchaseOrderService purchaseOrderService) {
        this.purchaseOrderService = purchaseOrderService;
    }

    @PostMapping("/addPO")
    public ResponseEntity<PurchaseOrder> addPurchaseOrder(@RequestBody PurchaseOrder purchaseOrder) {
        PurchaseOrder savedPurchaseOrder = purchaseOrderService.addPurchaseOrder(purchaseOrder);
        return ResponseEntity.ok(savedPurchaseOrder);
    }

    @GetMapping("/getPO/{purchaseOrderCode}")
    public ResponseEntity<PurchaseOrder> getPurchaseOrderById(@PathVariable String purchaseOrderCode) {
        PurchaseOrder purchaseOrder = purchaseOrderService.getPurchaseOrderById(purchaseOrderCode);
        return ResponseEntity.ok(purchaseOrder);
    }

    @PutMapping("/updatePO")
    public ResponseEntity<PurchaseOrder> updatePurchaseOrder(@RequestBody PurchaseOrder purchaseOrder) {
        PurchaseOrder updatedPurchaseOrder = purchaseOrderService.updatePurchaseOrder(purchaseOrder);
        return ResponseEntity.ok(updatedPurchaseOrder);
    }

    @DeleteMapping("/deletePO/{purchaseOrderCode}")
    public ResponseEntity<Void> deletePurchaseOrder(@PathVariable String purchaseOrderCode) {
        purchaseOrderService.deleteByPurchaseOrderCode(purchaseOrderCode);
        return ResponseEntity.noContent().build();
    }
}
