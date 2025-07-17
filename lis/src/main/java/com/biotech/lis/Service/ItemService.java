package com.biotech.lis.Service;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.Item;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.ItemRepository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class ItemService {

    @Autowired
    ItemRepository itemRepository;

    @Autowired
    UserService userService;

    @Autowired
    InventoryService inventoryService;

    private final Inventory inventoryPlcHldr = new Inventory();

    Integer totalQuantity;

    public Item addItem(Item item) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        item.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        item.setDateTimeAdded(cDateTime);

        inventoryPlcHldr.setItemCode(item.getItemCode());
        inventoryPlcHldr.setBrand(item.getBrand());
        totalQuantity = inventoryPlcHldr.getQuantityOnHand() + item.getStocksCebu() + item.getStocksManila();
        inventoryPlcHldr.setQuantityOnHand(totalQuantity);
        inventoryPlcHldr.setDateTimeAdded(item.getDateTimeAdded());
        inventoryPlcHldr.setAddedBy(item.getAddedBy());
        Integer id = inventoryService.inventoryExists(inventoryPlcHldr);
        if(id != -1) {
            inventoryPlcHldr.setInventoryId(id);
            inventoryService.updateInventory(inventoryPlcHldr);
        } else {
            inventoryService.addInventory(inventoryPlcHldr);
        }

        return itemRepository.save(item);
    }
    
    public Item getItem(String itemCode) {
        return itemRepository.findItemByItemCode(itemCode);
    }

    public List<Item> getItems() {
        return itemRepository.findAll();
    }

    public void deleteItem(String itemCode) {
        itemRepository.delete(itemRepository.findItemByItemCode(itemCode));
    }

    public Item updateItem(Item item) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        item.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        item.setDateTimeAdded(cDateTime);
        return itemRepository.save(item);
    }
}
