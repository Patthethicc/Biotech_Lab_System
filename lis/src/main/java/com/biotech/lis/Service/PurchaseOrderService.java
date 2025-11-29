package com.biotech.lis.Service;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.InventoryRepository;
import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import com.biotech.lis.Repository.TransactionEntryRepository;

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
    TransactionEntryRepository transactionEntryRepository;

    @Autowired
    InventoryRepository inventoryRepository;

    @Autowired
    StockLocatorService stockLocatorService;

    @Transactional
    public PurchaseOrder addPurchaseOrder(PurchaseOrder purchaseOrder) {
        validatePurchaseOrder(purchaseOrder);
        Brand brand = brandService.getBrandById(purchaseOrder.getBrandId());


        String lastItemCode = purchaseOrderRepository.findTopByBrandIdOrderByItemCodeDesc(brand.getBrandId()).map(PurchaseOrder::getItemCode).orElse(null);

        int nextSequence = 0;

        if (lastItemCode != null) {
            String numberPart = lastItemCode.substring(brand.getAbbreviation().length());
            try {
                nextSequence = Integer.parseInt(numberPart) + 1;
            } catch (NumberFormatException e) {
                nextSequence = brand.getLatestSequence(); // fallback
            }
        }
        
        purchaseOrder.setItemCode(brand.getAbbreviation() + String.format("%04d", nextSequence));

        User user = getCurrentUser();
        setAuditFields(purchaseOrder, user);
        PurchaseOrder savedPO = purchaseOrderRepository.save(purchaseOrder);

        // Create and save a corresponding TransactionEntry
        TransactionEntry transactionEntry = new TransactionEntry();
        transactionEntry.setDrSIReferenceNum(savedPO.getPoPireference()); // Or another unique reference
        transactionEntry.setItemCode(savedPO.getItemCode());
        transactionEntry.setBrand(brand.getBrandName());
        transactionEntry.setProductDescription(savedPO.getProductDescription());
        transactionEntry.setQuantity(savedPO.getQuantity());
        transactionEntry.setCost(savedPO.getUnitCost() * savedPO.getQuantity());
        transactionEntry.setStockLocation("limbaga"); // Default location, can be changed
        transactionEntryRepository.save(transactionEntry);

        return savedPO;
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
        
        existingPurchaseOrder.setBrandId(purchaseOrder.getBrandId());
        existingPurchaseOrder.setPackSize(purchaseOrder.getPackSize());
        existingPurchaseOrder.setQuantity(purchaseOrder.getQuantity());
        existingPurchaseOrder.setUnitCost(purchaseOrder.getUnitCost());
        existingPurchaseOrder.setPoPireference(purchaseOrder.getPoPireference());
        existingPurchaseOrder.setProductDescription(purchaseOrder.getProductDescription());

        // existingPurchaseOrder.setPurchaseOrderFile(purchaseOrder.getPurchaseOrderFile());
        // existingPurchaseOrder.setSuppliersPackingList(purchaseOrder.getSuppliersPackingList());
        // existingPurchaseOrder.setInventoryOfDeliveredItems(purchaseOrder.getInventoryOfDeliveredItems());
        // existingPurchaseOrder.setOrderDate(purchaseOrder.getOrderDate());
        // existingPurchaseOrder.setDrSIReferenceNum(purchaseOrder.getDrSIReferenceNum());
        // existingPurchaseOrder.setLotSerialNumber(purchaseOrder.getLotSerialNumber());

        User user = getCurrentUser();
        setAuditFields(existingPurchaseOrder, user);

        // Inventory inventory = inventoryRepository.findByItemCodeIgnoreCase(existingPurchaseOrder.getItemCode()).get();
        // inventory.setBrand(existingPurchaseOrder.getBrand());
        // inventory.setProductDescription(existingPurchaseOrder.getProductDescription());

        // inventory.setLotSerialNumber(existingPurchaseOrder.getLotSerialNumber());

        // inventoryRepository.save(inventory);

        // TransactionEntry transactionEntry = transactionEntryRepository.findByItemCode(existingPurchaseOrder.getItemCode()).get();
        // transactionEntry.setBrand(existingPurchaseOrder.getBrand());
        // transactionEntry.setProductDescription(existingPurchaseOrder.getProductDescription());
        
        // transactionEntry.setLotSerialNumber(existingPurchaseOrder.getLotSerialNumber());
        // transactionEntry.setTransactionDate(existingPurchaseOrder.getOrderDate());

        // transactionEntryRepository.save(transactionEntry);

        return purchaseOrderRepository.save(existingPurchaseOrder);
    }

    @Transactional
    public void deletePurchaseOrder(String code) {
        validatePurchaseOrderCode(code);

        if (!purchaseOrderRepository.existsById(code)) {
            throw new IllegalArgumentException("Purchase order not found with code: " + code);
        }
        // stockLocatorService.updateStockFromTransaction(transactionEntryRepository.findByItemCode(code).get(), false);

        // transactionEntryRepository.deleteByItemCode(code);
        // inventoryRepository.deleteByItemCode(code);

        purchaseOrderRepository.deleteById(code);
    }

     private void validatePurchaseOrder(PurchaseOrder purchaseOrder) {
        if (purchaseOrder == null) {
            throw new IllegalArgumentException("Purchase order cannot be null");
        }
    }

    private void validatePurchaseOrderCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            throw new IllegalArgumentException("Item Code cannot be null or empty");
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
        purchaseOrder.setAddedBy(user.getUserId().intValue());
        purchaseOrder.setDateTimeAdded(currentDateTime);
    }
}
