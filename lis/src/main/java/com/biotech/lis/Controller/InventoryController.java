package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Service.InventoryService;

@RestController
@RequestMapping("/inv/v1")
public class InventoryController {
    
    private final InventoryService inventoryService;

    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @PostMapping("/addInv")
    public ResponseEntity<Inventory> addInventory(@RequestBody Inventory inventory) {
        Inventory savedInventory = inventoryService.addInventory(inventory);
        return ResponseEntity.ok(savedInventory);
    }

    @GetMapping("/getInv/{id}")
    public ResponseEntity<Inventory> getInvById(@PathVariable("id") Integer invId) {
        final Inventory invById = inventoryService.getInventoryById(invId);
        return ResponseEntity.ok(invById);
    }

    @PutMapping("/updateInv")
    public ResponseEntity<Inventory> updateInventory(@RequestBody Inventory inventory) {
        Inventory updatedInv = inventoryService.updateInventory(inventory);
        return ResponseEntity.ok(updatedInv);
    }

    @DeleteMapping("deleteInv/{id}")
    public ResponseEntity<Inventory> deleteInv(@PathVariable("id") Integer id) {
        inventoryService.deleteByInventoryId(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("stockAlert/{amt}")
    public ResponseEntity<List<Inventory>> getStockAlerts(@PathVariable("amt") Integer amount) {
        final List<Inventory> stockAlerts = inventoryService.getStockAlerts(amount);
        return ResponseEntity.ok(stockAlerts);
    }
}
