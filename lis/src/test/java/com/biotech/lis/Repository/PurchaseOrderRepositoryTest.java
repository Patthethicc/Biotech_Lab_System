package com.biotech.lis.Repository;

import com.biotech.lis.Entity.PurchaseOrder;
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
public class PurchaseOrderRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    // Helper method to create a sample PurchaseOrder
    private PurchaseOrder createSamplePurchaseOrder(String itemCode) {
        PurchaseOrder po = new PurchaseOrder();
        po.setItemCode(itemCode);
        po.setBrand("TestBrand");
        po.setProductDescription("Test Description");
        po.setPackSize(10.0);
        po.setQuantity(5);
        po.setUnitCost(100.0);
        po.setTotalCost(500.0);
        po.setPoPIreference("REF123");
        return po;
    }

    @Test
    public void testSavePurchaseOrder() {
        // Create and save a sample purchase order
        PurchaseOrder po = createSamplePurchaseOrder("ITEM001");
        PurchaseOrder savedPo = purchaseOrderRepository.save(po);
        
        // Verify the saved purchase order
        assertNotNull(savedPo);
        assertEquals("ITEM001", savedPo.getItemCode());
        assertEquals("TestBrand", savedPo.getBrand());
    }

    @Test
    public void testFindByItemCode_Found() {
        // Create and persist a sample purchase order
        PurchaseOrder po = createSamplePurchaseOrder("ITEM001");
        entityManager.persistAndFlush(po);
        
        // Test finding by item code
        PurchaseOrder found = purchaseOrderRepository.findByItemCode("ITEM001");
        
        // Verify the result
        assertNotNull(found);
        assertEquals("ITEM001", found.getItemCode());
        assertEquals("TestBrand", found.getBrand());
    }
    
    @Test
    public void testFindByItemCode_NotFound() {
        // Test finding a non-existent item code
        PurchaseOrder found = purchaseOrderRepository.findByItemCode("NONEXISTENT");
        
        // Verify the result
        assertNull(found);
    }
    
    @Test
    public void testDeleteByItemCode() {
        // Create and persist two purchase orders
        PurchaseOrder po1 = createSamplePurchaseOrder("ITEM001");
        PurchaseOrder po2 = createSamplePurchaseOrder("ITEM002");
        entityManager.persistAndFlush(po1);
        entityManager.persistAndFlush(po2);
        
        // Verify both exist
        assertEquals(2, purchaseOrderRepository.findAll().size());
        
        // Delete one
        purchaseOrderRepository.deleteByItemCode("ITEM001");
        
        // Verify only one remains
        List<PurchaseOrder> remaining = purchaseOrderRepository.findAll();
        assertEquals(1, remaining.size());
        assertEquals("ITEM002", remaining.get(0).getItemCode());
    }
    
    @Test
    public void testFindAll() {
        // Create and persist multiple purchase orders
        entityManager.persistAndFlush(createSamplePurchaseOrder("ITEM001"));
        entityManager.persistAndFlush(createSamplePurchaseOrder("ITEM002"));
        entityManager.persistAndFlush(createSamplePurchaseOrder("ITEM003"));
        
        // Test findAll
        List<PurchaseOrder> allPurchaseOrders = purchaseOrderRepository.findAll();
        
        // Verify the results
        assertNotNull(allPurchaseOrders);
        assertEquals(3, allPurchaseOrders.size());
    }
    
    @Test
    public void testExistsById() {
        // Create and persist a sample purchase order
        PurchaseOrder po = createSamplePurchaseOrder("ITEM001");
        entityManager.persistAndFlush(po);
        
        // Test existsById
        boolean exists = purchaseOrderRepository.existsById("ITEM001");
        boolean nonExists = purchaseOrderRepository.existsById("NONEXISTENT");
        
        // Verify the results
        assertTrue(exists);
        assertFalse(nonExists);
    }
}
