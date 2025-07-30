package com.biotech.lis.Service;


import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class PurchaseOrderService {
    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    UserService userService;

    @Transactional
    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        validatePurchaseOrder(purchaseOrder);
        validatePurchaseOrderCode(purchaseOrder.getPurchaseOrderCode());
        if (purchaseOrderRepository.existsById(purchaseOrder.getPurchaseOrderCode())) {
            throw new IllegalArgumentException("Purchase order already exists with code: " + purchaseOrder.getPurchaseOrderCode());
        }

        if (purchaseOrder.getItemCode() == null || purchaseOrder.getItemCode().trim().isEmpty()) {
            purchaseOrder.setItemCode(UUID.randomUUID().toString());
        }

        User user = getCurrentUser();
        setAuditFields(purchaseOrder, user);
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public Optional<PurchaseOrder> getPurchaseOrderByCode(String code) {
        validatePurchaseOrderCode(code);
        return Optional.ofNullable(purchaseOrderRepository.findByPurchaseOrderCode(code));
    }

    public List<PurchaseOrder> getAllPurchaseOrders() {
        return purchaseOrderRepository.findAll();
    }

    @Transactional
    public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder) {
        validatePurchaseOrder(purchaseOrder);
        validatePurchaseOrderCode(purchaseOrder.getPurchaseOrderCode());

        PurchaseOrder existingOrder = purchaseOrderRepository.findById(purchaseOrder.getPurchaseOrderCode())
                .orElseThrow(() -> new IllegalArgumentException("Purchase order not found with code: " + purchaseOrder.getPurchaseOrderCode()));

        User user = getCurrentUser();

        existingOrder.setPurchaseOrderFile(purchaseOrder.getPurchaseOrderFile());
        existingOrder.setSuppliersPackingList(purchaseOrder.getSuppliersPackingList());
        existingOrder.setQuantityPurchased(purchaseOrder.getQuantityPurchased());
        existingOrder.setOrderDate(purchaseOrder.getOrderDate());
        existingOrder.setExpectedDeliveryDate(purchaseOrder.getExpectedDeliveryDate());
        existingOrder.setCost(purchaseOrder.getCost());
        
        existingOrder.setAddedBy(user.getFirstName() + " " + user.getLastName());
        existingOrder.setDateTimeAdded(LocalDateTime.now());


        return purchaseOrderRepository.save(existingOrder);
    }

    @Transactional
    public void deletePurchaseOrder(String code) {
        validatePurchaseOrderCode(code);

        if (!purchaseOrderRepository.existsById(code)) {
            throw new IllegalArgumentException("Purchase order not found with code: " + code);
        }
        purchaseOrderRepository.deleteById(code);
    }

     private void validatePurchaseOrder(PurchaseOrder purchaseOrder) {
        if (purchaseOrder == null) {
            throw new IllegalArgumentException("Purchase order cannot be null");
        }
    }

    private void validatePurchaseOrderCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Purchase Order Code cannot be null or empty");
        }
    }

    private User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth.getName() == null) {
            throw new IllegalArgumentException("No authenticated user found");
        }

        try {
            // Assuming auth.getName() returns the user ID as a String
            User user = userService.getUserById(Long.parseLong(auth.getName()));
            if (user == null) {
                throw new IllegalArgumentException("User not found with ID: " + auth.getName());
            }
            return user;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid user ID format: " + auth.getName());
        }
    }

    private void setAuditFields(PurchaseOrder purchaseOrder, User user) {
        LocalDateTime currentDateTime = LocalDateTime.now();
        purchaseOrder.setAddedBy(user.getFirstName() + " " + user.getLastName());
        purchaseOrder.setDateTimeAdded(currentDateTime);
    }
}


