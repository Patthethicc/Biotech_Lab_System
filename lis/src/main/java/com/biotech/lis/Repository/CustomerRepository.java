package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.biotech.lis.Entity.Customer;

public interface CustomerRepository extends JpaRepository<Customer, Integer> {
    boolean existsByName(String name);
    Customer findByName(String name);
}
