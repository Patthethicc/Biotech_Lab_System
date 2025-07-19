package com.biotech.lis.Controller;

import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Service.PurchaseOrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/PO/v1")
public class PurchaseOrderController {

    private final PurchaseOrderService purchaseOrderService;
    @Autowired
    public PurchaseOrderController(PurchaseOrderService purchaseOrderService) {
        this.purchaseOrderService = purchaseOrderService;
    }

    @PostMapping("/addPO")
    public ResponseEntity<PurchaseOrder> addPurchaseOrder(@RequestBody PurchaseOrder purchaseOrder) {
        PurchaseOrder savedPurchaseOrder = purchaseOrderService.addPurchaseOrder(purchaseOrder);
        return ResponseEntity.ok(savedPurchaseOrder);
    }

    @GetMapping("/getPO/{code}")
    public ResponseEntity<PurchaseOrder> getPurchaseOrderByCode(@PathVariable("code") String code) {
        final PurchaseOrder PurchaseOrderByCode = purchaseOrderService.getPurchaseOrderByCode(code);
        return ResponseEntity.ok(PurchaseOrderByCode);
    }

    @PutMapping("/updatePO")
    public ResponseEntity<PurchaseOrder> updatePurchaseOrder(@RequestBody PurchaseOrder purchaseOrder) {
        PurchaseOrder savedPurchaseOrder = purchaseOrderService.updatePurchaseOrder(purchaseOrder);
        return ResponseEntity.ok(savedPurchaseOrder);
    }

    @DeleteMapping("/deletePO/{code}")
    public ResponseEntity<PurchaseOrder> deletePurchaseOrder(@PathVariable("code") String code) {
        purchaseOrderService.deletePurchaseOrder(code);
        return ResponseEntity.ok().build();
    }
}
