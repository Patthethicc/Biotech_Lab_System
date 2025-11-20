package com.biotech.lis.Repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.StockLocator;

@Repository
public interface StockLocatorRepository extends JpaRepository<StockLocator, String> {
    
    @Query("SELECT s FROM StockLocator s WHERE LOWER(s.brand) = LOWER(:brand) AND LOWER(s.productDescription) = LOWER(:productDescription)")
    Optional<StockLocator> findByBrandAndProductDescription(@Param("brand") String brand, @Param("productDescription") String productDescription);

    @Query("SELECT CASE WHEN COUNT(s) > 0 THEN true ELSE false END FROM StockLocator s WHERE LOWER(s.brand) = LOWER(:brand) AND LOWER(s.productDescription) = LOWER(:productDescription)")
    boolean existsByBrandAndProductDescription(@Param("brand") String brand, @Param("productDescription") String productDescription); 

    List<StockLocator> findByBrandIgnoreCase(String brand);

    List<StockLocator> findByProductDescriptionContainingIgnoreCase(String query);

    List<StockLocator> findByBrandIgnoreCaseAndProductDescriptionContainingIgnoreCase(String brand, String query);

    @Query("SELECT DISTINCT s.productDescription FROM StockLocator s WHERE (:brand IS NULL OR LOWER(s.brand) = LOWER(:brand)) ORDER BY s.productDescription ASC")
    List<String> findDistinctProductDescriptions(@Param("brand") String brand);
}