package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.PurchaseOrderRepository;

@Service
public class PurchaseOrderService {

    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    UserService userService;

    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        purchaseOrder.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        purchaseOrder.setDateTimeAdded(cDateTime);
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public PurchaseOrder getPurchaseOrderById(String purchaseOrderCode) {
        return purchaseOrderRepository.getReferenceById(purchaseOrderCode);
    }

    public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        purchaseOrder.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        purchaseOrder.setDateTimeAdded(cDateTime);
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public void deleteByPurchaseOrderCode(String purchaseOrderCode) {
        purchaseOrderRepository.deleteById(purchaseOrderCode);
    }


}
