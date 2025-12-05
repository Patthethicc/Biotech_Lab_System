package com.biotech.lis.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.Brand;

@Repository
public interface BrandRepository extends JpaRepository<Brand, Integer>{
    Optional<Brand> findByBrandName(String brandName);
    boolean existsByBrandNameIgnoreCase(String brandName);
}
