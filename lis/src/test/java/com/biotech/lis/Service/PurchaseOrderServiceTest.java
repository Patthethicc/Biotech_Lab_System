package com.biotech.lis.Service;

import com.biotech.lis.Entity.Brand;
import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class PurchaseOrderServiceTest {

    @Mock
    private PurchaseOrderRepository purchaseOrderRepository;
    
    @Mock
    private BrandService brandService;
    
    @Mock
    private UserService userService;

    @InjectMocks
    private PurchaseOrderService purchaseOrderService;

    private PurchaseOrder samplePurchaseOrder;

    @BeforeEach
    void setUp() {
        samplePurchaseOrder = new PurchaseOrder();
        samplePurchaseOrder.setItemCode("ITEM001");
        samplePurchaseOrder.setBrand("TestBrand");
        samplePurchaseOrder.setProductDescription("Test Description");
        samplePurchaseOrder.setPackSize(10.0);
        samplePurchaseOrder.setQuantity(5);
        samplePurchaseOrder.setUnitCost(100.0);
        samplePurchaseOrder.setTotalCost(500.0);
        samplePurchaseOrder.setPoPIreference("REF123");
    }

    @Test
    void testAddPurchaseOrder() {
        // Setup
        Brand mockBrand = new Brand();
        mockBrand.setAbbreviation("TST");
        mockBrand.setLatestSequence(1);
        
        // Mock brand service
        when(brandService.getBrandbyName(anyString())).thenReturn(mockBrand);
        when(purchaseOrderRepository.existsById(anyString())).thenReturn(false);
        
        // Update this mock to return a PO with the expected generated code
        PurchaseOrder savedMockPO = new PurchaseOrder();
        savedMockPO.setItemCode("TST0001"); // The code that will be generated
        savedMockPO.setBrand("TestBrand");
        savedMockPO.setProductDescription("Test Description");
        when(purchaseOrderRepository.save(any(PurchaseOrder.class))).thenReturn(savedMockPO);
        
        // Mock security context
        mockSecurityContext();

        // Execute
        PurchaseOrder savedPO = purchaseOrderService.addPurchaseOrder(samplePurchaseOrder);

        // Verify
        assertNotNull(savedPO);
        assertEquals("TST0001", savedPO.getItemCode()); // Updated expectation
        assertEquals("TestBrand", savedPO.getBrand());
        verify(purchaseOrderRepository, times(1)).save(any(PurchaseOrder.class));
    }

    @Test
    void testGetAllPurchaseOrders() {
        // Setup
        PurchaseOrder anotherPO = new PurchaseOrder();
        anotherPO.setItemCode("ITEM002");
        List<PurchaseOrder> poList = Arrays.asList(samplePurchaseOrder, anotherPO);
        
        when(purchaseOrderRepository.findAll()).thenReturn(poList);

        // Execute
        List<PurchaseOrder> result = purchaseOrderService.getAllPurchaseOrders();

        // Verify
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("ITEM001", result.get(0).getItemCode());
        assertEquals("ITEM002", result.get(1).getItemCode());
        verify(purchaseOrderRepository, times(1)).findAll();
    }

    @Test
    void testGetPurchaseOrderByCode_Found() {
        // Setup
        when(purchaseOrderRepository.findByItemCode("ITEM001")).thenReturn(samplePurchaseOrder);

        // Execute
        Optional<PurchaseOrder> result = purchaseOrderService.getPurchaseOrderByCode("ITEM001");

        // Verify
        assertTrue(result.isPresent());
        assertEquals("ITEM001", result.get().getItemCode());
        verify(purchaseOrderRepository, times(1)).findByItemCode("ITEM001");
    }

    @Test
    void testGetPurchaseOrderByCode_NotFound() {
        // Setup
        when(purchaseOrderRepository.findByItemCode("NONEXISTENT")).thenReturn(null);

        // Execute
        Optional<PurchaseOrder> result = purchaseOrderService.getPurchaseOrderByCode("NONEXISTENT");

        // Verify
        assertFalse(result.isPresent());
        verify(purchaseOrderRepository, times(1)).findByItemCode("NONEXISTENT");
    }

    @Test
    void testUpdatePurchaseOrder() {
        // Setup
        PurchaseOrder updatedPO = new PurchaseOrder();
        updatedPO.setItemCode("ITEM001");
        updatedPO.setBrand("UpdatedBrand");
        updatedPO.setProductDescription("Updated Description");
        updatedPO.setPackSize(20.0);
        
        // Mock the existence check and findByItemCode
        when(purchaseOrderRepository.existsById("ITEM001")).thenReturn(true);
        when(purchaseOrderRepository.findByItemCode("ITEM001")).thenReturn(samplePurchaseOrder);
        when(purchaseOrderRepository.save(any(PurchaseOrder.class))).thenReturn(updatedPO);

        // Execute
        PurchaseOrder result = purchaseOrderService.updatePurchaseOrder(updatedPO);

        // Verify
        assertNotNull(result);
        assertEquals("ITEM001", result.getItemCode());
        assertEquals("UpdatedBrand", result.getBrand());
        assertEquals("Updated Description", result.getProductDescription());
        assertEquals(20.0, result.getPackSize());
        verify(purchaseOrderRepository, times(1)).existsById("ITEM001");
        verify(purchaseOrderRepository, times(1)).findByItemCode("ITEM001");
        verify(purchaseOrderRepository, times(1)).save(any(PurchaseOrder.class));
    }

    @Test
    void testUpdatePurchaseOrder_NotFound() {
        // Setup
        PurchaseOrder updatedPO = new PurchaseOrder();
        updatedPO.setItemCode("NONEXISTENT");
        
        // Mock the existence check - item doesn't exist
        when(purchaseOrderRepository.existsById("NONEXISTENT")).thenReturn(false);

        // Execute & Verify
        assertThrows(IllegalArgumentException.class, () -> 
            purchaseOrderService.updatePurchaseOrder(updatedPO)
        );
        
        verify(purchaseOrderRepository, times(1)).existsById("NONEXISTENT");
        verify(purchaseOrderRepository, never()).save(any(PurchaseOrder.class));
    }

    @Test
    void testDeletePurchaseOrder() {
        // Setup - Mock the existence check
        when(purchaseOrderRepository.existsById("ITEM001")).thenReturn(true);
        doNothing().when(purchaseOrderRepository).deleteById("ITEM001"); // Fix: use deleteById instead

        // Execute
        purchaseOrderService.deletePurchaseOrder("ITEM001");

        // Verify
        verify(purchaseOrderRepository, times(1)).existsById("ITEM001");
        verify(purchaseOrderRepository, times(1)).deleteById("ITEM001"); // Fix: verify deleteById
    }
    
    @Test
    void testDeletePurchaseOrder_NotFound() {
        // Setup - Mock the existence check - item doesn't exist
        when(purchaseOrderRepository.existsById("NONEXISTENT")).thenReturn(false);

        // Execute & Verify
        assertThrows(IllegalArgumentException.class, () -> 
            purchaseOrderService.deletePurchaseOrder("NONEXISTENT")
        );
        
        verify(purchaseOrderRepository, times(1)).existsById("NONEXISTENT");
        verify(purchaseOrderRepository, never()).deleteById(anyString()); // Fix: verify deleteById
    }
    
    // Helper method to mock security context
    private void mockSecurityContext() {
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn("1"); // Mock user ID
        SecurityContextHolder.setContext(securityContext);
        
        // Mock user service
        User mockUser = new User();
        when(userService.getUserById(anyLong())).thenReturn(mockUser);
    }
}
