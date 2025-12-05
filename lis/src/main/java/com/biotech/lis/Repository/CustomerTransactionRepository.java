package com.biotech.lis.Repository;

import com.biotech.lis.Entity.CustomerTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CustomerTransactionRepository extends JpaRepository<CustomerTransaction, Long> {
    boolean existsByInvoiceReference(String invoiceReference);
}
