package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Service.BrandService;

@RestController
@RequestMapping("/brand/v1")
public class BrandController {

    private final BrandService brandService;

    public BrandController(BrandService brandService) {
        this.brandService = brandService;
    }

    @PostMapping("/addBrand")
    public ResponseEntity<?> addBrand(@RequestBody Brand brand) {
        try {
            Brand savedBrand = brandService.addBrand(brand);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedBrand);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        }
    }

    @GetMapping("/getBrandById/{id}")
    public ResponseEntity<Brand> getBrandById(@PathVariable("id") Integer brndId) {
        final Brand brndById = brandService.getBrandById(brndId);
        return ResponseEntity.ok(brndById);
    }

    @GetMapping("/getBrand")
    public ResponseEntity<List<Brand>> getBrand() {
        final List<Brand> brand = brandService.getBrands();
        return ResponseEntity.ok(brand);
    }

    @PutMapping("/updateBrand/{name}")
    public ResponseEntity<?> updateBrand(@PathVariable("name") String name, @RequestBody Brand brand) {
        try {
            return ResponseEntity.ok(brandService.updateBrand(name, brand));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMessage());
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
    }

    @DeleteMapping("deleteBrand/{id}")
    public ResponseEntity<Brand> deleteBrand(@PathVariable("id") Integer id) {
        brandService.deleteBrand(id);
        return ResponseEntity.noContent().build();
    }
}
