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
    
    @Query("SELECT s FROM StockLocator s WHERE LOWER(s.brand) = LOWER(:brand) AND LOWER(s.productDescription) = LOWER(:productDescription)") // not case sensitive
    Optional<StockLocator> findByBrandAndProductDescription(@Param("brand") String brand, @Param("productDescription") String productDescription);

    @Query("SELECT s FROM StockLocator s WHERE " +
           "(:brand IS NULL OR LOWER(s.brand) = LOWER(:brand)) AND " +
           "(:query IS NULL OR " +
           "    LOWER(s.itemCode) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "    LOWER(s.brand) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "    LOWER(s.productDescription) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<StockLocator> search(@Param("brand") String brand, @Param("query") String query);

    @Query("SELECT CASE WHEN COUNT(s) > 0 THEN true ELSE false END FROM StockLocator s WHERE LOWER(s.brand) = LOWER(:brand) AND LOWER(s.productDescription) = LOWER(:productDescription)") // not case sensitive
    boolean existsByBrandAndProductDescription(@Param("brand") String brand, @Param("productDescription") String productDescription); 

}