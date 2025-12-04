package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;

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

    @GetMapping("/search")
    public ResponseEntity<Inventory> searchInventory(
            @RequestParam String brand,
            @RequestParam String description) {
        Inventory inventory = inventoryService.searchInventory(brand, description);
        if (inventory != null) {
            return ResponseEntity.ok(inventory);
        } else {
            return ResponseEntity.notFound().build();
        }
    }


    @PutMapping("/updateInv")
    public ResponseEntity<InventoryPayload> updateInventory(@RequestBody InventoryPayload payload) {
        InventoryPayload updatedPayload = inventoryService.updateInventory(payload);

        return ResponseEntity.ok(updatedPayload);
    }

    @DeleteMapping("/deleteInv/{itemCode}")
    public ResponseEntity<Inventory> deleteInv(@PathVariable("itemCode") String itemCode) {
        inventoryService.deleteByInventoryId(itemCode);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/stockAlert/{amt}")
    public ResponseEntity<List<InventoryPayload>> getStockAlerts(@PathVariable("amt") Integer amount) {
        final List<InventoryPayload> stockAlerts = inventoryService.getStockAlerts(amount);
        return ResponseEntity.ok(stockAlerts);
    }

    @GetMapping("/getTopStock")
    public ResponseEntity<List<InventoryPayload>> getTopStock() {
        List<InventoryPayload> topInv = inventoryService.getHighestStock();
        return ResponseEntity.ok(topInv);
    }

    @GetMapping("/getLowStock")
    public ResponseEntity<List<InventoryPayload>> getBottomStock() {
        List<InventoryPayload> lowInv = inventoryService.getLowestStock();
        return ResponseEntity.ok(lowInv);
    }

        // Exception handlers for proper HTTP status codes
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<String> handleHttpMessageNotReadable(HttpMessageNotReadableException ex) {
        return new ResponseEntity<>("Invalid request body", HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<String> handleMethodArgumentNotValid(MethodArgumentNotValidException ex) {
        return new ResponseEntity<>("Validation failed", HttpStatus.BAD_REQUEST);
    }
}
