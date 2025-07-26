package com.biotech.lis.Controller;

import com.biotech.lis.Entity.Item;
import com.biotech.lis.Service.ItemService;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/item/v1")
public class ItemController {
    private final ItemService itemService;

    @Autowired
    public ItemController(ItemService itemService){
        this.itemService = itemService;
    }

    @PostMapping("/addItem")
    public ResponseEntity<Item> addItem(@RequestBody Item item) {
        Item savedItem = itemService.addItem(item);
        return ResponseEntity.ok(savedItem);
    }

    @PostMapping("/getItem/{itemCode}")
    public ResponseEntity<Item> getItem(@PathVariable("itemCode") String itemCode) {
        Item itemByName = itemService.getItem(itemCode);
        return ResponseEntity.ok(itemByName);
    }

    @GetMapping("/getItems")
    public ResponseEntity<List<Item>> getItems() {
        List<Item> items = itemService.getItems();
        return ResponseEntity.ok(items);
    }

    @DeleteMapping("/deleteItem/{itemCode}")
    public ResponseEntity<Item> deleteItem(@PathVariable("itemCode") String itemCode) {
        itemService.deleteItem(itemCode);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/updateItem")
    public ResponseEntity<Item> updateItem(@RequestBody Item item) {
        Item savedItem = itemService.updateItem(item);
        return ResponseEntity.ok(savedItem);
    }

    @GetMapping("/getExpiringItems/{days}")
    public ResponseEntity<List<Item>> getExpiringItems(@PathVariable("days") int days) {
        List<Item> expiringItems = itemService.getAllItemsExpiringItems(days);
        return ResponseEntity.ok(expiringItems);
    }
}
