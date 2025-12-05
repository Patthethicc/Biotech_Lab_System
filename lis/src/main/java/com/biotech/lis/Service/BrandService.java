package com.biotech.lis.Service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Repository.BrandRepository;

@Service
public class BrandService {
    @Autowired
    private BrandRepository brandRepository;

    public Brand addBrand(Brand brand) {
        String name = brand.getBrandName().trim();

        if (brandRepository.existsByBrandNameIgnoreCase(name)) {
            throw new IllegalArgumentException("Brand with name '" + name + "' already exists.");
        }

        String abbreviation = name.charAt(0) + "" + name.charAt(name.length() - 1);
        brand.setAbbreviation(abbreviation);
        brand.setLatestSequence(0);
        return brandRepository.save(brand);
    }

    public String generateItemCode(Brand brand) {
        brand.setLatestSequence(brand.getLatestSequence() + 1);
        brandRepository.save(brand);

        String itemCode = brand.getAbbreviation() + String.format("%04d", brand.getLatestSequence());

        return itemCode;
    }

    public Brand getBrandById(Integer id) {
        return brandRepository.getReferenceById(id);
    }

    public List<Brand> getBrands() {
        return brandRepository.findAll();
    }

    public Brand getBrandbyName(String brand) {
        Optional<Brand> optionalBrand = brandRepository.findByBrandName(brand);
        return optionalBrand.orElseThrow(
            () -> new RuntimeException("Location not found with name: " + brand)
        );
    }

    public Brand updateBrand(String name, Brand updatedBrand) {
        Brand brand = getBrandbyName(name);
        String newName = updatedBrand.getBrandName().trim();

        if (newName != null && !newName.isBlank() && !newName.equalsIgnoreCase(brand.getBrandName())) {
            if (brandRepository.existsByBrandNameIgnoreCase(newName)) {
                throw new IllegalArgumentException("Brand name '" + newName + "' already exists.");
            }

            brand.setBrandName(newName);
        }

        Brand savedBrand = brandRepository.save(brand);
        
        return savedBrand;
    }

    public void deleteBrand(Integer id) {
        brandRepository.deleteById(id);
    }
}
