package com.biotech.lis.Repository;

import com.biotech.lis.Entity.ItemLoc;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.TestPropertySource;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@TestPropertySource(properties = {
    "spring.jpa.hibernate.ddl-auto=none",
    "spring.jpa.show-sql=true",
    "spring.datasource.url=jdbc:h2:mem:testdb;DB_CLOSE_DELAY=-1",
    "spring.sql.init.mode=embedded",
    "spring.sql.init.schema-locations=classpath:schema.sql"
})
public class ItemLocRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private ItemLocRepository itemLocRepository;

    // Helper method to create a sample ItemLoc
    private ItemLoc createSampleItemLoc(Integer locationId, String itemCode, Integer quantity) {
        ItemLoc itemLoc = new ItemLoc();
        itemLoc.setLocationId(locationId);
        itemLoc.setItemCode(itemCode);
        itemLoc.setQuantity(quantity);
        return itemLoc;
    }

    @Test
    public void testSaveItemLoc() {
        // Create and save a sample ItemLoc
        ItemLoc itemLoc = createSampleItemLoc(1, "ITEM001", 50);
        ItemLoc savedItemLoc = itemLocRepository.save(itemLoc);
        
        // Verify the saved ItemLoc
        assertNotNull(savedItemLoc);
        assertEquals(1, savedItemLoc.getLocationId());
        assertEquals("ITEM001", savedItemLoc.getItemCode());
        assertEquals(50, savedItemLoc.getQuantity());
    }

    @Test
    public void testFindByItemCode_Found() {
        // Create and persist multiple ItemLoc entries for the same item
        entityManager.persistAndFlush(createSampleItemLoc(1, "ITEM001", 30));
        entityManager.persistAndFlush(createSampleItemLoc(2, "ITEM001", 20));
        entityManager.persistAndFlush(createSampleItemLoc(3, "ITEM002", 40));
        
        // Test finding by item code
        List<ItemLoc> found = itemLocRepository.findByItemCode("ITEM001");
        
        // Verify the results
        assertNotNull(found);
        assertEquals(2, found.size());
        assertTrue(found.stream().allMatch(loc -> "ITEM001".equals(loc.getItemCode())));
    }

    @Test
    public void testFindByItemCode_NotFound() {
        // Create and persist an ItemLoc
        entityManager.persistAndFlush(createSampleItemLoc(1, "ITEM001", 30));
        
        // Test finding a non-existent item code
        List<ItemLoc> found = itemLocRepository.findByItemCode("NONEXISTENT");
        
        // Verify the result is empty
        assertNotNull(found);
        assertTrue(found.isEmpty());
    }

    @Test
    public void testFindByItemCode_MultipleLocations() {
        // Create and persist multiple locations for one item
        entityManager.persistAndFlush(createSampleItemLoc(1, "ITEM001", 10));
        entityManager.persistAndFlush(createSampleItemLoc(2, "ITEM001", 15));
        entityManager.persistAndFlush(createSampleItemLoc(3, "ITEM001", 25));
        
        // Test finding all locations
        List<ItemLoc> locations = itemLocRepository.findByItemCode("ITEM001");
        
        // Verify all locations are retrieved
        assertNotNull(locations);
        assertEquals(3, locations.size());
        
        // Verify total quantity
        int totalQuantity = locations.stream()
                .mapToInt(ItemLoc::getQuantity)
                .sum();
        assertEquals(50, totalQuantity);
    }

    @Test
    public void testDeleteByItemCode() {
        // Create and persist multiple ItemLoc entries
        entityManager.persistAndFlush(createSampleItemLoc(1, "ITEM001", 30));
        entityManager.persistAndFlush(createSampleItemLoc(2, "ITEM001", 20));
        entityManager.persistAndFlush(createSampleItemLoc(3, "ITEM002", 40));
        
        // Verify initial count
        assertEquals(2, itemLocRepository.findByItemCode("ITEM001").size());
        assertEquals(1, itemLocRepository.findByItemCode("ITEM002").size());
        
        // Delete all entries for ITEM001
        itemLocRepository.deleteByItemCode("ITEM001");
        entityManager.flush();
        
        // Verify ITEM001 entries are deleted
        List<ItemLoc> remainingItem001 = itemLocRepository.findByItemCode("ITEM001");
        assertTrue(remainingItem001.isEmpty());
        
        // Verify ITEM002 entries still exist
        List<ItemLoc> remainingItem002 = itemLocRepository.findByItemCode("ITEM002");
        assertEquals(1, remainingItem002.size());
    }

    @Test
    public void testFindAll() {
        // Create and persist multiple ItemLoc entries
        entityManager.persistAndFlush(createSampleItemLoc(1, "ITEM001", 30));
        entityManager.persistAndFlush(createSampleItemLoc(2, "ITEM002", 20));
        entityManager.persistAndFlush(createSampleItemLoc(3, "ITEM003", 40));
        
        // Test findAll
        List<ItemLoc> allItemLocs = itemLocRepository.findAll();
        
        // Verify the results
        assertNotNull(allItemLocs);
        assertEquals(3, allItemLocs.size());
    }

    @Test
    public void testUpdateItemLoc() {
        // Create and persist an ItemLoc
        ItemLoc itemLoc = createSampleItemLoc(1, "ITEM001", 30);
        entityManager.persistAndFlush(itemLoc);
        
        // Update the quantity
        itemLoc.setQuantity(50);
        ItemLoc updatedItemLoc = itemLocRepository.save(itemLoc);
        
        // Verify the update
        assertNotNull(updatedItemLoc);
        assertEquals(1, updatedItemLoc.getLocationId());
        assertEquals("ITEM001", updatedItemLoc.getItemCode());
        assertEquals(50, updatedItemLoc.getQuantity());
    }

    @Test
    public void testSaveMultipleLocationsForSameItem() {
        // Simulate User Story 2: Adding inventory to multiple locations
        String itemCode = "ITEM001";
        
        ItemLoc loc1 = createSampleItemLoc(1, itemCode, 15);
        ItemLoc loc2 = createSampleItemLoc(2, itemCode, 25);
        ItemLoc loc3 = createSampleItemLoc(3, itemCode, 10);
        
        itemLocRepository.save(loc1);
        itemLocRepository.save(loc2);
        itemLocRepository.save(loc3);
        
        // Verify all locations are saved
        List<ItemLoc> savedLocations = itemLocRepository.findByItemCode(itemCode);
        assertEquals(3, savedLocations.size());
        
        // Verify total quantity distributed across locations
        int totalQty = savedLocations.stream()
                .mapToInt(ItemLoc::getQuantity)
                .sum();
        assertEquals(50, totalQty);
    }
}
