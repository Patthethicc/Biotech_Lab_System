package com.biotech.lis.Repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.StockLocator;

@Repository
public interface StockLocatorRepository extends JpaRepository<StockLocator, String> {
    
    @Query("SELECT s FROM StockLocator s WHERE s.brand = :brand AND s.productDescription = :productDescription")
    Optional<StockLocator> findByBrandAndProductDescription(@Param("brand") String brand, @Param("productDescription") String productDescription);
    
    @Query("SELECT CASE WHEN COUNT(s) > 0 THEN true ELSE false END FROM StockLocator s WHERE s.brand = :brand AND s.productDescription = :productDescription")
    boolean existsByBrandAndProductDescription(@Param("brand") String brand, @Param("productDescription") String productDescription);
}