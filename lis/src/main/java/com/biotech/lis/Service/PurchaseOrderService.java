package com.biotech.lis.Service;


import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class PurchaseOrderService {
    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    UserService userService;

    @Autowired
    BrandService brandService;

    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        
        Brand brand = brandService.getBrandbyName(purchaseOrder.getBrand());

        purchaseOrder.setItemCode(brand.getAbbreviation() + String.format("%04d", brand.getLatestSequence()));

        purchaseOrder.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        purchaseOrder.setDateTimeAdded(cDateTime);

        return purchaseOrderRepository.save(purchaseOrder);
    }

    public Optional<PurchaseOrder> getPurchaseOrderByCode(String code) {
        return Optional.ofNullable(purchaseOrderRepository.findByItemCode(code));
    }

    public List<PurchaseOrder> getAllPurchaseOrders() {
        return purchaseOrderRepository.findAll();
    }

    public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        purchaseOrder.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        purchaseOrder.setDateTimeAdded(cDateTime);

        return purchaseOrderRepository.save(purchaseOrder);
    }
    
    public void deletePurchaseOrder(String code) {
        purchaseOrderRepository.deleteById(code);
    }
}
