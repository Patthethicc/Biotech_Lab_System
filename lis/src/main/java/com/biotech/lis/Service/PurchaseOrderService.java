package com.biotech.lis.Service;


import com.biotech.lis.Entity.Brand;
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

@Service
public class PurchaseOrderService {
    @Autowired
    PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    UserService userService;

    @Autowired
    BrandService brandService;

    @Autowired
    TransactionEntryService transactionEntryService;

    @Autowired
    InventoryService inventoryService;

    @Transactional
    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        validatePurchaseOrder(purchaseOrder);
        validatePurchaseOrderCode(purchaseOrder.getItemCode());
        if (purchaseOrderRepository.existsById(purchaseOrder.getItemCode())) {
            throw new IllegalArgumentException("Purchase order already exists with item code:" + purchaseOrder.getItemCode());
        }

        Brand brand = brandService.getBrandbyName(purchaseOrder.getBrand());

        purchaseOrder.setItemCode(brand.getAbbreviation() + String.format("%04d", brand.getLatestSequence()));

        User user = getCurrentUser();
        setAuditFields(purchaseOrder, user);
        return purchaseOrderRepository.save(purchaseOrder);
    }

    public Optional<PurchaseOrder> getPurchaseOrderByCode(String code) {
        validatePurchaseOrderCode(code);
        return Optional.ofNullable(purchaseOrderRepository.findByItemCode(code));
    }

    public List<PurchaseOrder> getAllPurchaseOrders() {
        return purchaseOrderRepository.findAll();
    }

    @Transactional
    public PurchaseOrder updatePurchaseOrder(PurchaseOrder purchaseOrder) {
        validatePurchaseOrder(purchaseOrder);
        validatePurchaseOrderCode(purchaseOrder.getItemCode());

        if (!purchaseOrderRepository.existsById(purchaseOrder.getItemCode())) {
            throw new IllegalArgumentException("Purchase order not found with code: " + purchaseOrder.getItemCode());
        }

        PurchaseOrder existingPurchaseOrder = getPurchaseOrderByCode(purchaseOrder.getItemCode()).get();

        existingPurchaseOrder.setBrand(purchaseOrder.getBrand());
        existingPurchaseOrder.setProductDescription(purchaseOrder.getProductDescription());
        existingPurchaseOrder.setLotSerialNumber(purchaseOrder.getLotSerialNumber());
        existingPurchaseOrder.setPurchaseOrderFile(purchaseOrder.getPurchaseOrderFile());
        existingPurchaseOrder.setSuppliersPackingList(purchaseOrder.getSuppliersPackingList());
        existingPurchaseOrder.setInventoryOfDeliveredItems(purchaseOrder.getInventoryOfDeliveredItems());
        existingPurchaseOrder.setOrderDate(purchaseOrder.getOrderDate());
        existingPurchaseOrder.setDrSIReferenceNum(purchaseOrder.getDrSIReferenceNum());

        User user = getCurrentUser();
        setAuditFields(existingPurchaseOrder, user);

        return purchaseOrderRepository.save(existingPurchaseOrder);
    }

    @Transactional
    public void deletePurchaseOrder(String code) {
        validatePurchaseOrderCode(code);

        if (!purchaseOrderRepository.existsById(code)) {
            throw new IllegalArgumentException("Purchase order not found with code: " + code);
        }
        transactionEntryService.deleteTransactionEntryByCode(code);
        inventoryService.deleteByInventoryItemCode(code);
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


