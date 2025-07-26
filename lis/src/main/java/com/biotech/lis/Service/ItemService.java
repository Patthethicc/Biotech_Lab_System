package com.biotech.lis.Service;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.Item;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.ItemRepository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.List;
import java.util.Optional;
import java.util.Date; 

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ItemService {

    @Autowired
    ItemRepository itemRepository;

    @Autowired
    UserService userService;

    @Autowired
    InventoryService inventoryService;
    
    public List<Item> getAllItemsExpiringItems(int daysTillExpiry) {
            // Use LocalDate for date arithmetic
        LocalDate todayLocal = LocalDate.now();
        LocalDate expiryLocal = todayLocal.plusDays(daysTillExpiry);

        // Convert to java.util.Date
        Date today = Date.from(todayLocal.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Date expiDate = Date.from(expiryLocal.atStartOfDay(ZoneId.systemDefault()).toInstant());
        return itemRepository.findAllWithinDateRange(today, expiDate);
    }

    public Item addItem(Item item) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();

        item.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        item.setDateTimeAdded(cDateTime);

        Inventory inventoryPlcHldr = new Inventory();
        Integer totalQuantity;

        inventoryPlcHldr.setItemCode(item.getItemCode());
        inventoryPlcHldr.setBrand(item.getBrand());
        totalQuantity = item.getStocksCebu() + item.getStocksManila();
        inventoryPlcHldr.setQuantityOnHand(totalQuantity);
        inventoryPlcHldr.setDateTimeAdded(item.getDateTimeAdded());
        inventoryPlcHldr.setAddedBy(item.getAddedBy());

        Integer id = inventoryService.inventoryExists(inventoryPlcHldr);
        if(id == 0) {
            inventoryService.addInventory(inventoryPlcHldr);
        } else {
            inventoryPlcHldr.setInventoryId(id);
            totalQuantity += inventoryPlcHldr.getQuantityOnHand();
            inventoryPlcHldr.setQuantityOnHand(totalQuantity);
            inventoryService.updateInventory(inventoryPlcHldr);
        }

        return itemRepository.save(item);
    }

    public Item getItem(String itemCode) {
        return Optional.ofNullable(itemRepository.findItemByItemCode(itemCode))
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Item not found with code: " + itemCode
                ));
    }

    public List<Item> getItems() {
        return itemRepository.findAll();
    }

    public void deleteItem(String itemCode) {
        Item itemToDelete = Optional.ofNullable(itemRepository.findItemByItemCode(itemCode))
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Item not found with code: " + itemCode + " for deletion."
                ));

        itemRepository.delete(itemToDelete);
    }

    public Item updateItem(Item item) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();

        Item existingItem = Optional.ofNullable(itemRepository.findItemByItemCode(item.getItemCode()))
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Item not found for update with code: " + item.getItemCode()
                ));

        existingItem.setBrand(item.getBrand());
        existingItem.setProductDescription(item.getProductDescription());
        existingItem.setLotSerialNumber(item.getLotSerialNumber());
        existingItem.setExpiryDate(item.getExpiryDate());
        existingItem.setStocksManila(item.getStocksManila());
        existingItem.setStocksCebu(item.getStocksCebu());
        existingItem.setPurchaseOrderReferenceNumber(item.getPurchaseOrderReferenceNumber());
        existingItem.setSupplierPackingList(item.getSupplierPackingList());
        existingItem.setDrsiReferenceNumber(item.getDrsiReferenceNumber());

        existingItem.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        existingItem.setDateTimeAdded(cDateTime);

        return itemRepository.save(existingItem);
    }
}