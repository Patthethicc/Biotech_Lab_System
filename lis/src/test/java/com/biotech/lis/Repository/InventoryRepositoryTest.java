package com.biotech.lis.Repository;

import com.biotech.lis.Entity.Inventory;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.TestPropertySource;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@TestPropertySource(properties = {
    "spring.jpa.hibernate.ddl-auto=none",
    "spring.jpa.show-sql=true",
    "spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1",
    "spring.sql.init.mode=embedded",
    "spring.sql.init.schema-locations=classpath:schema.sql"
})
public class InventoryRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private InventoryRepository inventoryRepository;

    // Helper method to create a sample inventory
    private Inventory createSampleInventory(String itemCode, String poReference, Integer quantity) {
        Inventory inventory = new Inventory();
        inventory.setItemCode(itemCode);
        inventory.setPoPireference(poReference);
        inventory.setInvoiceNum("INV-001");
        inventory.setItemDescription("Test Product Description");
        inventory.setBrandId(1);
        inventory.setLotNum(12345);
        inventory.setExpiry(LocalDate.now().plusMonths(6));
        inventory.setPackSize(100);
        inventory.setQuantity(quantity);
        inventory.setCostOfSale(150.00);
        inventory.setNote("Test note");
        inventory.setAddedBy(1L);
        inventory.setDateTimeAdded(LocalDateTime.now());
        return inventory;
    }

    @Test
    public void testSaveInventory() {
        // Create and save a sample inventory
        Inventory inventory = createSampleInventory("ITEM001", "PO-001", 50);
        Inventory savedInventory = inventoryRepository.save(inventory);
        
        // Verify the saved inventory
        assertNotNull(savedInventory);
        assertEquals("ITEM001", savedInventory.getItemCode());
        assertEquals("PO-001", savedInventory.getPoPireference());
        assertEquals(50, savedInventory.getQuantity());
        assertEquals("Test Product Description", savedInventory.getItemDescription());
    }

    @Test
    public void testFindById_Found() {
        // Create and persist a sample inventory
        Inventory inventory = createSampleInventory("ITEM001", "PO-001", 50);
        entityManager.persistAndFlush(inventory);
        
        // Test finding by ID (itemCode)
        Optional<Inventory> found = inventoryRepository.findById("ITEM001");
        
        // Verify the result
        assertTrue(found.isPresent());
        assertEquals("ITEM001", found.get().getItemCode());
        assertEquals("PO-001", found.get().getPoPireference());
    }

    @Test
    public void testFindById_NotFound() {
        // Test finding a non-existent item code
        Optional<Inventory> found = inventoryRepository.findById("NONEXISTENT");
        
        // Verify the result
        assertFalse(found.isPresent());
    }

    @Test
    public void testfindByQuantityLessThanEqual() {
       
        entityManager.persistAndFlush(createSampleInventory("ITEM001", "PO-001", 5));
        entityManager.persistAndFlush(createSampleInventory("ITEM002", "PO-002", 10)); 
        entityManager.persistAndFlush(createSampleInventory("ITEM002", "PO-002", 10));
        entityManager.persistAndFlush(createSampleInventory("ITEM003", "PO-003", 25));
        entityManager.persistAndFlush(createSampleInventory("ITEM004", "PO-004", 8));
        
       
        List<Inventory> lowStock = inventoryRepository.findByQuantityLessThanEqual(10);
        
       
        assertNotNull(lowStock);
        assertEquals(3, lowStock.size()); // Should find ITEM001, ITEM002, and ITEM004
        assertEquals(3, lowStock.size());
        assertTrue(lowStock.stream().allMatch(inv -> inv.getQuantity() <= 10));
    }

    @Test
    public void testfindByQuantityLessThanEqual_NoResults() {
        // Create and persist inventories with high quantities
        entityManager.persistAndFlush(createSampleInventory("ITEM001", "PO-001", 50));
        entityManager.persistAndFlush(createSampleInventory("ITEM002", "PO-002", 100));
        
        // Test finding inventories with quantity less than 10
        // Test finding inventories with quantity less than or equal to 10
        List<Inventory> lowStock = inventoryRepository.findByQuantityLessThanEqual(10);
        
        // Verify no results
        assertNotNull(lowStock);
        assertTrue(lowStock.isEmpty());
    }

    @Test
    public void testfindByQuantityLessThanEqual_WithZeroThreshold() {
       
        entityManager.persistAndFlush(createSampleInventory("ITEM001", "PO-001", 0));
        entityManager.persistAndFlush(createSampleInventory("ITEM002", "PO-002", 1));
        entityManager.persistAndFlush(createSampleInventory("ITEM003", "PO-003", -1)); // Edge case: negative quantity
        entityManager.persistAndFlush(createSampleInventory("ITEM003", "PO-003", -1));
        
        
        List<Inventory> outOfStock = inventoryRepository.findByQuantityLessThanEqual(0);
        
        // Verify the results
        assertNotNull(outOfStock);
        assertEquals(2, outOfStock.size()); // Should find ITEM001 and ITEM003
        assertEquals(2, outOfStock.size());
        assertTrue(outOfStock.stream().anyMatch(inv -> inv.getItemCode().equals("ITEM001")));
        assertTrue(outOfStock.stream().anyMatch(inv -> inv.getItemCode().equals("ITEM003")));
    }

    @Test
    public void testDeleteByItemCode() {
        // Create and persist multiple inventories
        entityManager.persistAndFlush(createSampleInventory("ITEM001", "PO-001", 50));
        entityManager.persistAndFlush(createSampleInventory("ITEM002", "PO-002", 30));
        entityManager.persistAndFlush(createSampleInventory("ITEM003", "PO-003", 40));
        
        // Verify all exist
        assertEquals(3, inventoryRepository.findAll().size());
        
        // Delete one inventory
        inventoryRepository.deleteByItemCode("ITEM001");
        entityManager.flush();
        
        // Verify deletion
        Optional<Inventory> deleted = inventoryRepository.findById("ITEM001");
        assertFalse(deleted.isPresent());
        
        // Verify others still exist
        assertEquals(2, inventoryRepository.findAll().size());
    }

    @Test
    public void testFindAll() {
        // Create and persist multiple inventories
        entityManager.persistAndFlush(createSampleInventory("ITEM001", "PO-001", 50));
        entityManager.persistAndFlush(createSampleInventory("ITEM002", "PO-002", 30));
        entityManager.persistAndFlush(createSampleInventory("ITEM003", "PO-003", 40));
        
        // Test findAll
        List<Inventory> allInventories = inventoryRepository.findAll();
        
        // Verify the results
        assertNotNull(allInventories);
        assertEquals(3, allInventories.size());
    }

    @Test
    public void testUpdateInventory() {
        // Create and persist an inventory
        Inventory inventory = createSampleInventory("ITEM001", "PO-001", 50);
        entityManager.persistAndFlush(inventory);
        
        // Update fields
        inventory.setQuantity(75);
        inventory.setNote("Updated note");
        inventory.setCostOfSale(200.00);
        Inventory updatedInventory = inventoryRepository.save(inventory);
        
        // Verify the update
        assertNotNull(updatedInventory);
        assertEquals("ITEM001", updatedInventory.getItemCode());
        assertEquals(75, updatedInventory.getQuantity());
        assertEquals("Updated note", updatedInventory.getNote());
        assertEquals(200.00, updatedInventory.getCostOfSale());
    }

    @Test
    public void testSaveInventoryWithAllFields() {
        // Test User Story 2: Saving inventory with all required fields
        Inventory inventory = new Inventory();
        inventory.setItemCode("ITEM001");
        inventory.setPoPireference("PO-2024-001");
        inventory.setInvoiceNum("INV-2024-001");
        inventory.setItemDescription("Premium Chemical Reagent");
        inventory.setBrandId(1);
        inventory.setLotNum(98765);
        inventory.setExpiry(LocalDate.of(2025, 12, 31));
        inventory.setPackSize(500);
        inventory.setQuantity(100);
        inventory.setCostOfSale(250.50);
        inventory.setNote("Store in cool, dry place");
        inventory.setAddedBy(1L);
        inventory.setDateTimeAdded(LocalDateTime.now());
        
        Inventory savedInventory = inventoryRepository.save(inventory);
        
        // Verify all fields
        assertNotNull(savedInventory);
        assertEquals("ITEM001", savedInventory.getItemCode());
        assertEquals("PO-2024-001", savedInventory.getPoPireference());
        assertEquals("INV-2024-001", savedInventory.getInvoiceNum());
        assertEquals("Premium Chemical Reagent", savedInventory.getItemDescription());
        assertEquals(1, savedInventory.getBrandId());
        assertEquals(98765, savedInventory.getLotNum());
        assertEquals(LocalDate.of(2025, 12, 31), savedInventory.getExpiry());
        assertEquals(500, savedInventory.getPackSize());
        assertEquals(100, savedInventory.getQuantity());
        assertEquals(250.50, savedInventory.getCostOfSale());
        assertEquals("Store in cool, dry place", savedInventory.getNote());
        assertEquals(1L, savedInventory.getAddedBy());
        assertNotNull(savedInventory.getDateTimeAdded());
    }

    @Test
    public void testSaveInventoryWithNullableFields() {
        // Test saving inventory with some nullable fields as null
        Inventory inventory = new Inventory();
        inventory.setItemCode("ITEM002");
        inventory.setPoPireference("PO-002");
        inventory.setInvoiceNum(null);  // Nullable
        inventory.setItemDescription("Test Item");
        inventory.setBrandId(2);
        inventory.setLotNum(null);  // Nullable
        inventory.setExpiry(LocalDate.now().plusMonths(3));
        inventory.setPackSize(100);
        inventory.setQuantity(50);
        inventory.setCostOfSale(100.00);
        inventory.setNote(null);  // Nullable
        inventory.setAddedBy(1L);
        inventory.setDateTimeAdded(LocalDateTime.now());
        
        Inventory savedInventory = inventoryRepository.save(inventory);
        
        // Verify saved with null fields
        assertNotNull(savedInventory);
        assertEquals("ITEM002", savedInventory.getItemCode());
        assertNull(savedInventory.getInvoiceNum());
        assertNull(savedInventory.getLotNum());
        assertNull(savedInventory.getNote());
    }

    @Test
    public void testExistsById() {
        // Create and persist an inventory
        entityManager.persistAndFlush(createSampleInventory("ITEM001", "PO-001", 50));
        
        // Test existsById
        boolean exists = inventoryRepository.existsById("ITEM001");
        boolean notExists = inventoryRepository.existsById("NONEXISTENT");
        
        // Verify the results
        assertTrue(exists);
        assertFalse(notExists);
    }
}
