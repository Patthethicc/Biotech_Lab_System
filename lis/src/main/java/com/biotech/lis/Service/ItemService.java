package com.biotech.lis.Service;

import com.biotech.lis.Entity.Item;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.ItemRepository;

import java.time.LocalDateTime;

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

    public Item addItem(Item item) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        item.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        item.setDateTimeAdded(cDateTime);
        return itemRepository.save(item);
    }
    
    public Item getItem(String itemCode) {
        return itemRepository.findItemByItemCode(itemCode);
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
