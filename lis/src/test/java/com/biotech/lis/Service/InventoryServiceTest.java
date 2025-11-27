package com.biotech.lis.Service;

import com.biotech.lis.Entity.*;
import com.biotech.lis.Repository.InventoryRepository;
import com.biotech.lis.Repository.ItemLocRepository;
import com.biotech.lis.Repository.PurchaseOrderRepository;
import com.biotech.lis.Repository.TransactionEntryRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class InventoryServiceTest {

    @Mock
    private InventoryRepository inventoryRepository;

    @Mock
    private ItemLocRepository itemLocRepository;

    @Mock
    private UserService userService;

    @Mock
    private BrandService brandService;

    @Mock
    private StockLocatorService stockLocatorService;

    @Mock
    private PurchaseOrderService purchaseOrderService;

    @Mock
    private PurchaseOrderRepository purchaseOrderRepository;

    @Mock
    private TransactionEntryRepository transactionEntryRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private InventoryService inventoryService;

    private User mockUser;
    private Inventory sampleInventory;
    private List<ItemLoc> sampleLocations;

    @BeforeEach
    void setUp() {
        // Mock security context (Skipped authentication)
        mockUser = new User();
        mockUser.setUserId(1L);
        mockUser.setFirstName("Test");
        mockUser.setLastName("User");

        // Use lenient() to avoid unnecessary errors for tests that don't need auth
        lenient().when(authentication.getName()).thenReturn("1");
        lenient().when(securityContext.getAuthentication()).thenReturn(authentication);
        lenient().when(userService.getUserById(1L)).thenReturn(mockUser);

        // Create sample inventory
        sampleInventory = new Inventory();
        sampleInventory.setItemCode("ITEM001");
        sampleInventory.setPoPireference("PO-2024-001");
        sampleInventory.setInvoiceNum("INV-2024-001");
        sampleInventory.setItemDescription("Test Chemical Reagent");
        sampleInventory.setBrandId(1);
        sampleInventory.setLotNum(12345);
        sampleInventory.setExpiry(LocalDate.now().plusMonths(6));
        sampleInventory.setPackSize(500);
        sampleInventory.setQuantity(100);
        sampleInventory.setCostOfSale(250.50);
        sampleInventory.setNote("Test note");

        // Create sample locations
        ItemLoc loc1 = new ItemLoc();
        loc1.setLocationId(1);
        loc1.setItemCode("ITEM001");
        loc1.setQuantity(60);

        ItemLoc loc2 = new ItemLoc();
        loc2.setLocationId(2);
        loc2.setItemCode("ITEM001");
        loc2.setQuantity(40);

        sampleLocations = Arrays.asList(loc1, loc2);
    }

    // Helper method to setup authentication for tests that need it
    private void setupAuthentication() {
        SecurityContextHolder.setContext(securityContext);
    }

    @Test
    void testAddInventory_Success() {
        // Setup
        setupAuthentication();
        InventoryPayload payload = new InventoryPayload(sampleInventory, sampleLocations);
        
        Inventory savedInventory = new Inventory();
        savedInventory.setItemCode("ITEM001");
        savedInventory.setPoPireference("PO-2024-001");
        savedInventory.setInvoiceNum("INV-2024-001");
        savedInventory.setItemDescription("Test Chemical Reagent");
        savedInventory.setBrandId(1);
        savedInventory.setQuantity(100);
        savedInventory.setAddedBy(1L);
        savedInventory.setDateTimeAdded(LocalDateTime.now());

        when(inventoryRepository.save(any(Inventory.class))).thenReturn(savedInventory);
        when(itemLocRepository.save(any(ItemLoc.class))).thenAnswer(i -> i.getArgument(0));

        // Execute
        Inventory result = inventoryService.addInventory(payload);

        // Verify
        assertNotNull(result);
        assertEquals("ITEM001", result.getItemCode());
        assertEquals(1L, result.getAddedBy());
        assertNotNull(result.getDateTimeAdded());
        
        // Verify repository interactions
        verify(inventoryRepository, times(2)).save(any(Inventory.class));
        verify(itemLocRepository, times(2)).save(any(ItemLoc.class));
    }

    @Test
    void testAddInventory_WithMultipleLocations() {
        // Setup - User Story 2: Adding inventory to 3 different locations
        setupAuthentication();
        ItemLoc loc1 = new ItemLoc(1, "ITEM001", 30);
        ItemLoc loc2 = new ItemLoc(2, "ITEM001", 40);
        ItemLoc loc3 = new ItemLoc(3, "ITEM001", 30);
        List<ItemLoc> multipleLocations = Arrays.asList(loc1, loc2, loc3);

        InventoryPayload payload = new InventoryPayload(sampleInventory, multipleLocations);
        
        when(inventoryRepository.save(any(Inventory.class))).thenReturn(sampleInventory);
        when(itemLocRepository.save(any(ItemLoc.class))).thenAnswer(i -> i.getArgument(0));

        // Execute
        Inventory result = inventoryService.addInventory(payload);

        // Verify
        assertNotNull(result);
        verify(itemLocRepository, times(3)).save(any(ItemLoc.class));
        
        // Verify each location was saved with correct itemCode and quantity
        // Note: There are TWO locations with quantity 30, so we verify at least once
        verify(itemLocRepository, atLeastOnce()).save(argThat(loc -> 
            loc.getItemCode().equals("ITEM001") && loc.getQuantity() == 30));
        verify(itemLocRepository, times(1)).save(argThat(loc -> 
            loc.getItemCode().equals("ITEM001") && loc.getQuantity() == 40));
    }

    @Test
    void testAddInventory_WithSingleLocation() {
        // Setup
        setupAuthentication();
        ItemLoc singleLoc = new ItemLoc(1, null, 100);
        List<ItemLoc> singleLocation = Collections.singletonList(singleLoc);
        
        InventoryPayload payload = new InventoryPayload(sampleInventory, singleLocation);
        
        when(inventoryRepository.save(any(Inventory.class))).thenReturn(sampleInventory);
        when(itemLocRepository.save(any(ItemLoc.class))).thenReturn(singleLoc);

        // Execute
        Inventory result = inventoryService.addInventory(payload);

        // Verify
        assertNotNull(result);
        verify(itemLocRepository, times(1)).save(any(ItemLoc.class));
    }

    @Test
    void testGetInventoriesWithLocations() {
        // Setup
        Inventory inv1 = new Inventory();
        inv1.setItemCode("ITEM001");
        inv1.setItemDescription("Item 1");

        Inventory inv2 = new Inventory();
        inv2.setItemCode("ITEM002");
        inv2.setItemDescription("Item 2");

        List<Inventory> inventories = Arrays.asList(inv1, inv2);

        ItemLoc loc1 = new ItemLoc(1, "ITEM001", 50);
        ItemLoc loc2 = new ItemLoc(2, "ITEM001", 30);
        ItemLoc loc3 = new ItemLoc(1, "ITEM002", 80);

        when(inventoryRepository.findAll()).thenReturn(inventories);
        when(itemLocRepository.findByItemCode("ITEM001")).thenReturn(Arrays.asList(loc1, loc2));
        when(itemLocRepository.findByItemCode("ITEM002")).thenReturn(Collections.singletonList(loc3));

        // Execute
        List<InventoryPayload> result = inventoryService.getInventoriesWithLocations();

        // Verify
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("ITEM001", result.get(0).getInventory().getItemCode());
        assertEquals(2, result.get(0).getLocations().size());
        assertEquals("ITEM002", result.get(1).getInventory().getItemCode());
        assertEquals(1, result.get(1).getLocations().size());

        verify(inventoryRepository, times(1)).findAll();
        verify(itemLocRepository, times(1)).findByItemCode("ITEM001");
        verify(itemLocRepository, times(1)).findByItemCode("ITEM002");
    }

    @Test
    void testGetInventoryByCode() {
        // Setup
        when(inventoryRepository.getReferenceById("ITEM001")).thenReturn(sampleInventory);

        // Execute
        Inventory result = inventoryService.getInventoryByCode("ITEM001");

        // Verify
        assertNotNull(result);
        assertEquals("ITEM001", result.getItemCode());
        verify(inventoryRepository, times(1)).getReferenceById("ITEM001");
    }

    @Test
    void testGetInventories() {
        // Setup
        List<Inventory> inventories = Arrays.asList(sampleInventory);
        when(inventoryRepository.findAll()).thenReturn(inventories);

        // Execute
        List<Inventory> result = inventoryService.getInventories();

        // Verify
        assertNotNull(result);
        assertEquals(1, result.size());
        verify(inventoryRepository, times(1)).findAll();
    }

    @Test
    void testGetHighestStock() {
        // Setup
        Inventory inv1 = new Inventory();
        inv1.setItemCode("ITEM001");
        inv1.setQuantity(50);

        Inventory inv2 = new Inventory();
        inv2.setItemCode("ITEM002");
        inv2.setQuantity(100);

        Inventory inv3 = new Inventory();
        inv3.setItemCode("ITEM003");
        inv3.setQuantity(25);

        List<Inventory> inventories = Arrays.asList(inv1, inv2, inv3);
        when(inventoryRepository.findAll()).thenReturn(inventories);

        // Execute
        List<Inventory> result = inventoryService.getHighestStock();

        // Verify - Should be sorted in descending order
        assertNotNull(result);
        assertEquals(3, result.size());
        assertEquals(100, result.get(0).getQuantity());
        assertEquals(50, result.get(1).getQuantity());
        assertEquals(25, result.get(2).getQuantity());
    }

    @Test
    void testGetLowestStock() {
        // Setup
        Inventory inv1 = new Inventory();
        inv1.setItemCode("ITEM001");
        inv1.setQuantity(50);

        Inventory inv2 = new Inventory();
        inv2.setItemCode("ITEM002");
        inv2.setQuantity(100);

        Inventory inv3 = new Inventory();
        inv3.setItemCode("ITEM003");
        inv3.setQuantity(25);

        List<Inventory> inventories = Arrays.asList(inv1, inv2, inv3);
        when(inventoryRepository.findAll()).thenReturn(inventories);

        // Execute
        List<Inventory> result = inventoryService.getLowestStock();

        // Verify - Should be sorted in ascending order
        assertNotNull(result);
        assertEquals(3, result.size());
        assertEquals(25, result.get(0).getQuantity());
        assertEquals(50, result.get(1).getQuantity());
        assertEquals(100, result.get(2).getQuantity());
    }

    @Test
    void testUpdateInventory_Success() {
        // Setup
        setupAuthentication();
        Inventory existingInventory = new Inventory();
        existingInventory.setItemCode("ITEM001");
        existingInventory.setQuantity(50);
        existingInventory.setNote("Old note");

        Inventory updatedData = new Inventory();
        updatedData.setItemCode("ITEM001");
        updatedData.setPoPireference("PO-2024-002");
        updatedData.setInvoiceNum("INV-2024-002");
        updatedData.setItemDescription("Updated Description");
        updatedData.setBrandId(2);
        updatedData.setLotNum(54321);
        updatedData.setExpiry(LocalDate.now().plusYears(1));
        updatedData.setPackSize(1000);
        updatedData.setQuantity(150);
        updatedData.setCostOfSale(300.00);
        updatedData.setNote("Updated note");

        ItemLoc newLoc1 = new ItemLoc(1, null, 100);
        ItemLoc newLoc2 = new ItemLoc(2, null, 50);
        List<ItemLoc> newLocations = Arrays.asList(newLoc1, newLoc2);

        InventoryPayload payload = new InventoryPayload(updatedData, newLocations);

        when(inventoryRepository.getReferenceById("ITEM001")).thenReturn(existingInventory);
        when(inventoryRepository.save(any(Inventory.class))).thenReturn(existingInventory);
        when(itemLocRepository.findByItemCode("ITEM001")).thenReturn(newLocations);
        doNothing().when(itemLocRepository).deleteByItemCode("ITEM001");
        when(itemLocRepository.save(any(ItemLoc.class))).thenAnswer(i -> i.getArgument(0));

        // Execute
        InventoryPayload result = inventoryService.updateInventory(payload);

        // Verify
        assertNotNull(result);
        assertEquals("ITEM001", result.getInventory().getItemCode());
        assertEquals(2, result.getLocations().size());
        
        verify(inventoryRepository, times(1)).getReferenceById("ITEM001");
        verify(inventoryRepository, times(1)).save(any(Inventory.class));
        verify(itemLocRepository, times(1)).deleteByItemCode("ITEM001");
        verify(itemLocRepository, times(2)).save(any(ItemLoc.class));
    }

    @Test
    void testUpdateInventory_NotFound() {
        // Setup
        setupAuthentication();
        InventoryPayload payload = new InventoryPayload(sampleInventory, sampleLocations);
        
        when(inventoryRepository.getReferenceById("ITEM001")).thenReturn(null);

        // Execute & Verify
        assertThrows(IllegalArgumentException.class, () -> 
            inventoryService.updateInventory(payload)
        );

        verify(inventoryRepository, times(1)).getReferenceById("ITEM001");
        verify(inventoryRepository, never()).save(any(Inventory.class));
        verify(itemLocRepository, never()).save(any(ItemLoc.class));
    }

    @Test
    void testDeleteByInventoryId() {
        // Setup
        doNothing().when(itemLocRepository).deleteByItemCode("ITEM001");
        doNothing().when(inventoryRepository).deleteById("ITEM001");

        // Execute
        inventoryService.deleteByInventoryId("ITEM001");

        // Verify - ItemLoc entries deleted first, then Inventory
        verify(itemLocRepository, times(1)).deleteByItemCode("ITEM001");
        verify(inventoryRepository, times(1)).deleteById("ITEM001");
    }

    @Test
    void testAddInventory_SetsUserAndTimestamp() {
        // Setup
        setupAuthentication();
        InventoryPayload payload = new InventoryPayload(sampleInventory, sampleLocations);
        
        when(inventoryRepository.save(any(Inventory.class))).thenAnswer(invocation -> {
            Inventory saved = invocation.getArgument(0);
            assertEquals(1L, saved.getAddedBy());
            assertNotNull(saved.getDateTimeAdded());
            return saved;
        });
        when(itemLocRepository.save(any(ItemLoc.class))).thenAnswer(i -> i.getArgument(0));

        // Execute
        inventoryService.addInventory(payload);

        // Verify
        verify(userService, times(1)).getUserById(1L);
        verify(inventoryRepository, times(2)).save(any(Inventory.class));
    }
}
