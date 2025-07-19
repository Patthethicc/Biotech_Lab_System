package com.biotech.lis.Controller;

import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Service.PurchaseOrderService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import java.util.List;
import org.springframework.web.bind.annotation.*;
import java.util.Optional;

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
        if (purchaseOrder == null){
            return ResponseEntity.badRequest().build(); // for null input
        }
        try {
            PurchaseOrder savedPurchaseOrder = purchaseOrderService.addPurchaseOrder(purchaseOrder);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedPurchaseOrder); // good
        } catch (Exception e) {
            System.err.println("Error adding purchase order: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // server error
        }
    }

    //get all purchase orders
    @GetMapping("/getPOs")
    public ResponseEntity<List<PurchaseOrder>> getAllPurchaseOrders() {
        try {
            List<PurchaseOrder> purchaseOrders = purchaseOrderService.getAllPurchaseOrders();
            return ResponseEntity.ok(purchaseOrders);
        } catch (Exception e) {
            System.err.println("Error fetching all purchase orders: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/getPO/{code}")
    public ResponseEntity<PurchaseOrder> getPurchaseOrderByCode(@PathVariable("code") String code) {
        if (code == null || code.trim().isEmpty()){
            return ResponseEntity.badRequest().build(); // null inputs
        }
        Optional<PurchaseOrder> purchaseOrder = purchaseOrderService.getPurchaseOrderByCode(code);
        return purchaseOrder.map(ResponseEntity::ok)
        .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/updatePO")
    public ResponseEntity<PurchaseOrder> updatePurchaseOrder(@RequestBody PurchaseOrder purchaseOrder) {
        if (purchaseOrder == null) {
            return ResponseEntity.badRequest().build(); // null
        }
        try {
            Optional<PurchaseOrder> existingOrder = purchaseOrderService.getPurchaseOrderByCode(purchaseOrder.getPurchaseOrderCode());
            if (existingOrder.isEmpty()) {
                return ResponseEntity.notFound().build(); // no entity
            }
            PurchaseOrder updatedPurchaseOrder = purchaseOrderService.updatePurchaseOrder(purchaseOrder);
            return ResponseEntity.ok(updatedPurchaseOrder); // good
        } catch (Exception e) {
            System.err.println("Error updating purchase order: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); // server error
        }
    }

    @DeleteMapping("/deletePO/{code}")
    public ResponseEntity<PurchaseOrder> deletePurchaseOrder(@PathVariable("code") String code) {
        if (code == null || code.trim().isEmpty()) {
            return ResponseEntity.badRequest().build(); // null
        }
        try {
            Optional<PurchaseOrder> existingOrder = purchaseOrderService.getPurchaseOrderByCode(code);
            if (existingOrder.isEmpty()) {
                return ResponseEntity.notFound().build(); // doesnt exist
            }
            purchaseOrderService.deletePurchaseOrder(code);
            return ResponseEntity.noContent().build(); // no content
        } catch (Exception e) {
            System.err.println("Error deleting purchase order: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build(); //server Error
        }
    }
}
