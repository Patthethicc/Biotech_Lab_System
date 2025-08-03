package com.biotech.lis.Service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Repository.BrandRepository;

import jakarta.persistence.EntityNotFoundException;

@Service
public class BrandService {
    @Autowired
    private BrandRepository brandRepository;

    public Brand addBrand(Brand brand) {
        String name = brand.getBrandName().trim();
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
        if (brand == null || brand.trim().isEmpty()) {
            throw new EntityNotFoundException("Brand is supposed to be not null.");
        }
        return brandRepository.findByBrandName(brand.trim());
    }

    public Brand updateBrand(Brand currentBrand) {
        Brand check = brandRepository.findByBrandName(currentBrand.getBrandName());
        if(check != null && !check.getBrandId().equals(currentBrand.getBrandId())) {
            throw new IllegalArgumentException("Brand name already exists.");
        }
        Brand existingBrand = getBrandById(currentBrand.getBrandId());
        if (existingBrand == null) {
            throw new EntityNotFoundException("Brand not found.");
        }
        existingBrand.setBrandName(currentBrand.getBrandName());
        return brandRepository.save(existingBrand);
    }

    public void deleteBrand(Integer id) {
        Brand brand = getBrandById(id);
        brandRepository.delete(brand);
    }
}
