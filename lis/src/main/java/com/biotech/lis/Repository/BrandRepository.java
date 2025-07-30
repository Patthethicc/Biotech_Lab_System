package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.biotech.lis.Entity.Brand;

public interface BrandRepository extends JpaRepository<Brand, Integer>{
    public Brand findByBrandName(String name);
}
