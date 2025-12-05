package com.biotech.lis.Controller;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.ItemLoc;
import com.biotech.lis.Entity.Location;
import com.biotech.lis.Repository.InventoryRepository;
import com.biotech.lis.Repository.ItemLocRepository;
import com.biotech.lis.Repository.LocationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/items")
public class ItemsController {

    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private ItemLocRepository itemLocRepository;

    @Autowired
    private LocationRepository locationRepository;

    @GetMapping("/v1/{brandId}")
    public ResponseEntity<List<Map<String, Object>>> getItemsForBrand(@PathVariable Integer brandId) {
        List<Inventory> items = inventoryRepository.findAll().stream()
                .filter(i -> i.getBrandId() != null && i.getBrandId().equals(brandId))
                .collect(Collectors.toList());

        List<Map<String, Object>> response = items.stream().map(item -> {
            Map<String, Object> map = new HashMap<>();
            map.put("itemId", item.getItemCode());
            map.put("itemDescription", item.getItemDescription());
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/details/{itemId}")
    public ResponseEntity<Map<String, Object>> getItemDetails(@PathVariable String itemId) {
        Inventory item = inventoryRepository.findById(itemId).orElse(null);
        if (item == null) {
            return ResponseEntity.notFound().build();
        }

        Map<String, Object> response = new HashMap<>();
        response.put("itemId", item.getItemCode());
        response.put("itemDescription", item.getItemDescription());

        // Lots
        List<Map<String, Object>> lots = new ArrayList<>();
        Map<String, Object> lot = new HashMap<>();
        lot.put("lotNumber", item.getLotNum() != null ? item.getLotNum().toString() : "N/A");
        lot.put("expiryDate", item.getExpiry() != null ? item.getExpiry().toString() : "N/A");
        // Using costOfSale as unitRetailPrice since no retail price exists
        lot.put("unitRetailPrice", item.getCostOfSale() != null ? item.getCostOfSale() : 0.0);
        lots.add(lot);
        response.put("lots", lots);

        // Locations
        List<ItemLoc> itemLocs = itemLocRepository.findByItemCode(itemId);
        List<Map<String, Object>> locations = new ArrayList<>();
        
        // Pre-fetch all locations to map ID to Name
        Map<Integer, String> locIdToName = locationRepository.findAll().stream()
                .collect(Collectors.toMap(Location::getLocationId, Location::getLocationName));

        for (ItemLoc il : itemLocs) {
            Map<String, Object> locMap = new HashMap<>();
            String locName = locIdToName.get(il.getLocationId());
            locMap.put("locationName", locName != null ? locName : "Unknown ID: " + il.getLocationId());
            locMap.put("availableStock", il.getQuantity());
            locations.add(locMap);
        }
        response.put("locations", locations);

        return ResponseEntity.ok(response);
    }
}
