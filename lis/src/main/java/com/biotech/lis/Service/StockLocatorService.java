package com.biotech.lis.Service;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.StockLocator;
import com.biotech.lis.Entity.TransactionEntry;
import com.biotech.lis.Repository.StockLocatorRepository;

@Service
public class StockLocatorService {

    @Autowired
    private StockLocatorRepository stockLocatorRepository;

    public List<StockLocator> getAllStockLocations() {
        return stockLocatorRepository.findAll();
    }

    public List<StockLocator> searchStockLocators(String brand, String query) {
        boolean hasBrand = brand != null && !brand.trim().isEmpty();
        boolean hasQuery = query != null && !query.trim().isEmpty();

        if (hasBrand && hasQuery) {
            return stockLocatorRepository.findByBrandIgnoreCaseAndProductDescriptionContainingIgnoreCase(brand, query);
        } else if (hasBrand) {
            return stockLocatorRepository.findByBrandIgnoreCase(brand);
        } else if (hasQuery) {
            return stockLocatorRepository.findByProductDescriptionContainingIgnoreCase(query);
        }
        return stockLocatorRepository.findAll();
    }

    public Optional<StockLocator> getStocksByBrandAndProduct(String brand, String productDescription) {
        return stockLocatorRepository.findByBrandAndProductDescription(brand, productDescription);
    }

    public Integer getManilaStock(String brand, String productDescription) {
        Optional<StockLocator> stockLocatorOpt = getStocksByBrandAndProduct(brand, productDescription);
        StockLocator stockLocator = stockLocatorOpt.get();

        return stockLocator.getLazcanoRef1() + stockLocator.getLazcanoRef2() +
        stockLocator.getLimbaga() + stockLocator.getGandiaColdStorage() + stockLocator.getGandiaRef1()
        + stockLocator.getGandiaRef2();
    }

    public Integer getCebuStock(String brand, String productDescription) {
        Optional<StockLocator> stockLocatorOpt = getStocksByBrandAndProduct(brand, productDescription);
        StockLocator stockLocator = stockLocatorOpt.get();

        return stockLocator.getCebu();
    }

    public void updateStockFromTransaction(TransactionEntry transactionEntry, boolean isAddition) {
        String brand = transactionEntry.getBrand();
        String itemCode = transactionEntry.getItemCode();
        String productDescription = transactionEntry.getProductDescription();
        String stockLocation = transactionEntry.getStockLocation().toLowerCase();
        Integer quantity = transactionEntry.getQuantity();

        Optional<StockLocator> existingStock = stockLocatorRepository.findByBrandAndProductDescription(brand, productDescription);
        StockLocator stockLocator;

        if (existingStock.isPresent()) {
            stockLocator = existingStock.get();
        } else {
            if (!isAddition){
                throw new RuntimeException("Stock not found for Brand: " + brand + ", Product: " + productDescription + " to deduct from.");
            }
            stockLocator = new StockLocator(itemCode, brand, productDescription);
        }

        int quantityChange = isAddition ? quantity : -quantity;
        
        switch (stockLocation) {
            case "lazcano (ref 1)":
                int newLazcanoRef1 = stockLocator.getLazcanoRef1() + quantityChange;
                if (!isAddition && newLazcanoRef1 < 0) { 
                    throw new RuntimeException("Insufficient stock at Lazcano Ref 1. Available: " + stockLocator.getLazcanoRef1() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setLazcanoRef1(newLazcanoRef1);
                break;
            case "lazcano (ref 2)":
                int newLazcanoRef2 = stockLocator.getLazcanoRef2() + quantityChange;
                if (!isAddition && newLazcanoRef2 < 0) {
                    throw new RuntimeException("Insufficient stock at Lazcano Ref 2. Available: " + stockLocator.getLazcanoRef2() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setLazcanoRef2(newLazcanoRef2);
                break;
            case "gandia (cold storage)":
                int newGandiaColdStorage = stockLocator.getGandiaColdStorage() + quantityChange;
                if (!isAddition && newGandiaColdStorage < 0) {
                    throw new RuntimeException("Insufficient stock at Gandia Cold Storage. Available: " + stockLocator.getGandiaColdStorage() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setGandiaColdStorage(newGandiaColdStorage);
                break;
            case "gandia (ref 1)":
                int newGandiaRef1 = stockLocator.getGandiaRef1() + quantityChange;
                if (!isAddition && newGandiaRef1 < 0) {
                    throw new RuntimeException("Insufficient stock at Gandia Ref 1. Available: " + stockLocator.getGandiaRef1() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setGandiaRef1(newGandiaRef1);
                break;
            case "gandia (ref 2)":
                int newGandiaRef2 = stockLocator.getGandiaRef2() + quantityChange;
                if (!isAddition && newGandiaRef2 < 0) {
                    throw new RuntimeException("Insufficient stock at Gandia Ref 2. Available: " + stockLocator.getGandiaRef2() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setGandiaRef2(newGandiaRef2);
                break;
            case "limbaga":
                int newLimbaga = stockLocator.getLimbaga() + quantityChange;
                if (!isAddition && newLimbaga < 0) {
                    throw new RuntimeException("Insufficient stock at Limbaga. Available: " + stockLocator.getLimbaga() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setLimbaga(newLimbaga);
                break;
            case "cebu":
                int newCebu = stockLocator.getCebu() + quantityChange;
                if (!isAddition && newCebu < 0) {
                    throw new RuntimeException("Insufficient stock at Cebu. Available: " + stockLocator.getCebu() + ", Requested Deduction: " + quantity + " for " + productDescription);
                }
                stockLocator.setCebu(newCebu);
                break;
            default:
                throw new IllegalArgumentException("Invalid stock location specified in transaction: " + stockLocation);
        }

        stockLocatorRepository.save(stockLocator);
    }

    public StockLocator updateStockLocator(StockLocator stockLocator) {
        return stockLocatorRepository.save(stockLocator);
    }

    public void deleteStockLocator(String id) {
        stockLocatorRepository.deleteById(id);
    }

    public boolean existsByBrandAndProduct(String brand, String productDescription) {
        return stockLocatorRepository.existsByBrandAndProductDescription(brand, productDescription);
    }

    public List<String> getProductDescriptions(String brand) {
        return stockLocatorRepository.findDistinctProductDescriptions(brand);
    }

    public void updateStockFromInventory(String itemCode, String brand, String description, java.util.Map<String, Integer> locationQuantities) {
        StockLocator stockLocator = stockLocatorRepository.findById(itemCode)
            .orElse(new StockLocator(itemCode, brand, description));
        
        stockLocator.setBrand(brand);
        stockLocator.setProductDescription(description);
        
        // Reset all to 0 before applying new quantities
        stockLocator.setLazcanoRef1(0);
        stockLocator.setLazcanoRef2(0);
        stockLocator.setGandiaColdStorage(0);
        stockLocator.setGandiaRef1(0);
        stockLocator.setGandiaRef2(0);
        stockLocator.setLimbaga(0);
        stockLocator.setCebu(0);

        for (java.util.Map.Entry<String, Integer> entry : locationQuantities.entrySet()) {
            String rawLocName = entry.getKey();
            String normalizedLoc = normalizeLocationName(rawLocName);
            Integer qty = entry.getValue();
            
            // Mapping logic for various location name formats
            if (normalizedLoc.contains("lazcano") && normalizedLoc.contains("ref1")) {
                stockLocator.setLazcanoRef1(qty);
            } else if (normalizedLoc.contains("lazcano") && normalizedLoc.contains("ref2")) {
                stockLocator.setLazcanoRef2(qty);
            } else if (normalizedLoc.contains("gandia") && normalizedLoc.contains("cold")) {
                stockLocator.setGandiaColdStorage(qty);
            } else if (normalizedLoc.contains("gandia") && normalizedLoc.contains("ref1")) {
                stockLocator.setGandiaRef1(qty);
            } else if (normalizedLoc.contains("gandia") && normalizedLoc.contains("ref2")) {
                stockLocator.setGandiaRef2(qty);
            } else if (normalizedLoc.contains("limbaga")) {
                stockLocator.setLimbaga(qty);
            } else if (normalizedLoc.contains("cebu")) {
                stockLocator.setCebu(qty);
            } 
            // Fallback mappings for generic names found in DB (e.g., "Ref 1", "Fridge 1")
            else if (normalizedLoc.equals("ref1")) {
                stockLocator.setLazcanoRef1(qty); // Assuming Ref 1 is Lazcano Ref 1
            } else if (normalizedLoc.equals("ref2")) {
                stockLocator.setLazcanoRef2(qty); // Assuming Ref 2 is Lazcano Ref 2
            } else if (normalizedLoc.contains("fridge") || normalizedLoc.contains("cold")) {
                stockLocator.setGandiaColdStorage(qty); // Assuming Fridge/Cold is Gandia Cold Storage
            } else if (normalizedLoc.equals("ref3")) {
                 // No specific column for Ref 3, adding to Gandia Ref 1 as fallback or ignore
                 stockLocator.setGandiaRef1(qty); 
            } else if (normalizedLoc.equals("ref4")) {
                 // No specific column for Ref 4, adding to Gandia Ref 2 as fallback or ignore
                 stockLocator.setGandiaRef2(qty);
            }
        }
        stockLocatorRepository.save(stockLocator);
        stockLocatorRepository.flush(); // Force write to DB
    }

    private String normalizeLocationName(String locationName) {
        if (locationName == null) return "";
        return locationName.toLowerCase().replaceAll("[^a-z0-9]", "");
    }
}