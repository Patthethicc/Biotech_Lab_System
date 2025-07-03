package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.TransactionEntry;

@Repository
public interface TransactionEntryRepository extends JpaRepository<TransactionEntry, String> {
}
