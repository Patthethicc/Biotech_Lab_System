package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.InventoryPayload;
import com.biotech.lis.Entity.ItemLoc;
import com.biotech.lis.Service.InventoryService;

@RestController
@RequestMapping("/inv/v1")
public class InventoryController {
    
    private final InventoryService inventoryService;

    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    //For future reference

    @PostMapping("/addInv")
    public ResponseEntity<InventoryPayload> addInventory(@RequestBody InventoryPayload payload) {
        Inventory savedInventory = inventoryService.addInventory(payload);

        InventoryPayload response = new InventoryPayload();
        response.setInventory(savedInventory);
        response.setLocations(payload.getLocations());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/getInv/{itemCode}")
    public ResponseEntity<Inventory> getInvById(@PathVariable("itemCode") String itemCode) {
        final Inventory invById = inventoryService.getInventoryByCode(itemCode);
        return ResponseEntity.ok(invById);
    }

    @GetMapping("/getInv")
    public ResponseEntity<List<InventoryPayload>> getInv() {
        final List<InventoryPayload> inventories = inventoryService.getInventoriesWithLocations();
        return ResponseEntity.ok(inventories);
    }


    @PutMapping("/updateInv")
    public ResponseEntity<InventoryPayload> updateInventory(@RequestBody InventoryPayload payload) {
        Inventory updatedInventory = inventoryService.updateInventoryInv(payload.getInventory());

        InventoryPayload response = new InventoryPayload();
        response.setInventory(updatedInventory);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/deleteInv/{itemCode}")
    public ResponseEntity<Inventory> deleteInv(@PathVariable("itemCode") String itemCode) {
        inventoryService.deleteByInventoryId(itemCode);
        return ResponseEntity.ok().build();
    }

    // @GetMapping("/stockAlert/{amt}")
    // public ResponseEntity<List<Inventory>> getStockAlerts(@PathVariable("amt") Integer amount) {
    //     final List<Inventory> stockAlerts = inventoryService.getStockAlerts(amount);
    //     return ResponseEntity.ok(stockAlerts);
    // }

    @GetMapping("/getTopStock")
    public ResponseEntity<List<Inventory>> getTopStock() {
        List<Inventory> topInv = inventoryService.getHighestStock();
        return ResponseEntity.ok(topInv);
    }

    @GetMapping("/getLowStock")
    public ResponseEntity<List<Inventory>> getBottomStock() {
        List<Inventory> lowInv = inventoryService.getLowestStock();
        return ResponseEntity.ok(lowInv);
    }
}
