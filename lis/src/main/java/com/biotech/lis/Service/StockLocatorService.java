package com.biotech.lis.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.StockLocator;
import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.StockLocatorRepository;

@Service
public class StockLocatorService {

    @Autowired
    private StockLocatorRepository stockLocatorRepository;

    @Autowired
    UserService userService;

    public List<StockLocator> getAllStockLocations() {
        return stockLocatorRepository.findAll();
    }

    public Optional<StockLocator> getStockByBrandAndProduct(String brand, String productDescription) {
        return stockLocatorRepository.findByBrandAndProductDescription(brand, productDescription);
    }

    public void updateStockFromTransaction(TransactionEntry transactionEntry, boolean isAddition) {
        String brand = transactionEntry.getBrand();
        String productDescription = transactionEntry.getProductDescription();
        String stockLocation = transactionEntry.getStockLocation();
        Integer quantity = transactionEntry.getQuantity();

        Optional<StockLocator> existingStock = stockLocatorRepository.findByBrandAndProductDescription(brand, productDescription);
        StockLocator stockLocator;

        if (existingStock.isPresent()) {
            stockLocator = existingStock.get();
        } else {
            stockLocator = new StockLocator(brand, productDescription);
        }

        int quantityChange = isAddition ? quantity : -quantity;
        
        switch (stockLocation.toLowerCase()) {
            case "lazcano ref 1":
                stockLocator.setLazcanoRef1(Math.max(0, stockLocator.getLazcanoRef1() + quantityChange));
                break;
            case "lazcano ref 2":
                stockLocator.setLazcanoRef2(Math.max(0, stockLocator.getLazcanoRef2() + quantityChange));
                break;
            case "gandia cold storage":
                stockLocator.setGandiaColdStorage(Math.max(0, stockLocator.getGandiaColdStorage() + quantityChange));
                break;
            case "gandia ref 1":
                stockLocator.setGandiaRef1(Math.max(0, stockLocator.getGandiaRef1() + quantityChange));
                break;
            case "gandia ref 2":
                stockLocator.setGandiaRef2(Math.max(0, stockLocator.getGandiaRef2() + quantityChange));
                break;
            case "limbaga":
                stockLocator.setLimbaga(Math.max(0, stockLocator.getLimbaga() + quantityChange));
                break;
            case "cebu":
                stockLocator.setCebu(Math.max(0, stockLocator.getCebu() + quantityChange));
                break;
            default:
                throw new IllegalArgumentException("Invalid stock location: " + stockLocation);
        }
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        stockLocator.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        stockLocator.setDateTimeAdded(cDateTime);
        stockLocatorRepository.save(stockLocator);
    }

    public StockLocator updateStockLocator(StockLocator stockLocator) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = userService.getUserById(Long.parseLong(auth.getName()));
        LocalDateTime cDateTime = LocalDateTime.now();
        stockLocator.setAddedBy(user.getFirstName().concat(" " + user.getLastName()));
        stockLocator.setDateTimeAdded(cDateTime);
        return stockLocatorRepository.save(stockLocator);
    }

    public void deleteStockLocator(String id) {
        stockLocatorRepository.deleteById(id);
    }

    public boolean existsByBrandAndProduct(String brand, String productDescription) {
        return stockLocatorRepository.existsByBrandAndProductDescription(brand, productDescription);
    }
}