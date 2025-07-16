package com.biotech.lis.Controller;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.biotech.lis.Entity.StockLocator;
import com.biotech.lis.Service.StockLocatorService;

@RestController
@RequestMapping("/stock-locator")
public class StockLocatorController {

    private final StockLocatorService stockLocatorService;

    @Autowired
    public StockLocatorController(StockLocatorService stockLocatorService) {
        this.stockLocatorService = stockLocatorService;
    }

    @GetMapping("/all")
    public ResponseEntity<List<StockLocator>> getAllStockLocations() {
        List<StockLocator> stockLocations = stockLocatorService.getAllStockLocations();
        return ResponseEntity.ok(stockLocations);
    }

    @GetMapping("/search")
    public ResponseEntity<StockLocator> getStockByBrandAndProduct(
            @RequestParam String brand, 
            @RequestParam String productDescription) {
        Optional<StockLocator> stockLocator = stockLocatorService.getStockByBrandAndProduct(brand, productDescription);
        if (stockLocator.isPresent()) {
            return ResponseEntity.ok(stockLocator.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PutMapping("/update")
    public ResponseEntity<StockLocator> updateStockLocator(@RequestBody StockLocator stockLocator) {
        try {
            StockLocator updatedStock = stockLocatorService.updateStockLocator(stockLocator);
            return ResponseEntity.ok(updatedStock);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> deleteStockLocator(@PathVariable String id) {
        try {
            stockLocatorService.deleteStockLocator(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @GetMapping("/exists")
    public ResponseEntity<Boolean> stockExists(
            @RequestParam String brand, 
            @RequestParam String productDescription) {
        boolean exists = stockLocatorService.existsByBrandAndProduct(brand, productDescription);
        return ResponseEntity.ok(exists);
    }
}