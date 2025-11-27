package com.biotech.lis.Controller;

import com.biotech.lis.Entity.Inventory;
import com.biotech.lis.Entity.InventoryPayload;
import com.biotech.lis.Entity.ItemLoc;
import com.biotech.lis.Service.InventoryService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(InventoryController.class)
public class InventoryControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private InventoryService inventoryService;

    @Autowired
    private ObjectMapper objectMapper;

    private Inventory sampleInventory;
    private List<ItemLoc> sampleLocations;
    private InventoryPayload samplePayload;

    @BeforeEach
    void setUp() {
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
        sampleInventory.setAddedBy(1L);
        sampleInventory.setDateTimeAdded(LocalDateTime.now());

        // Create sample locations
        ItemLoc loc1 = new ItemLoc(1, "ITEM001", 60);
        ItemLoc loc2 = new ItemLoc(2, "ITEM001", 40);
        sampleLocations = Arrays.asList(loc1, loc2);

        // Create sample payload
        samplePayload = new InventoryPayload(sampleInventory, sampleLocations);
    }

    @Test
    public void testAddInventory_Success() throws Exception {
        // Setup - User Story 2: Adding inventory with multiple locations
        when(inventoryService.addInventory(any(InventoryPayload.class)))
            .thenReturn(sampleInventory);

        // Execute & Verify
        mockMvc.perform(post("/inv/v1/addInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(samplePayload)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.inventory.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.inventory.poPireference").value("PO-2024-001"))
                .andExpect(jsonPath("$.inventory.quantity").value(100))
                .andExpect(jsonPath("$.locations.length()").value(2))
                .andExpect(jsonPath("$.locations[0].locationId").value(1))
                .andExpect(jsonPath("$.locations[0].quantity").value(60))
                .andExpect(jsonPath("$.locations[1].locationId").value(2))
                .andExpect(jsonPath("$.locations[1].quantity").value(40));

        verify(inventoryService, times(1)).addInventory(any(InventoryPayload.class));
    }

    @Test
    public void testAddInventory_WithMultipleLocations() throws Exception {
        // Setup - User Story 2: Adding to 3 locations
        ItemLoc loc1 = new ItemLoc(1, "ITEM001", 30);
        ItemLoc loc2 = new ItemLoc(2, "ITEM001", 40);
        ItemLoc loc3 = new ItemLoc(3, "ITEM001", 30);
        List<ItemLoc> multipleLocations = Arrays.asList(loc1, loc2, loc3);
        
        InventoryPayload payload = new InventoryPayload(sampleInventory, multipleLocations);
        
        when(inventoryService.addInventory(any(InventoryPayload.class)))
            .thenReturn(sampleInventory);

        // Execute & Verify
        mockMvc.perform(post("/inv/v1/addInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(payload)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.locations.length()").value(3))
                .andExpect(jsonPath("$.locations[0].quantity").value(30))
                .andExpect(jsonPath("$.locations[1].quantity").value(40))
                .andExpect(jsonPath("$.locations[2].quantity").value(30));

        verify(inventoryService, times(1)).addInventory(any(InventoryPayload.class));
    }

    @Test
    public void testAddInventory_InvalidJson() throws Exception {
        // Execute & Verify
        mockMvc.perform(post("/inv/v1/addInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{invalid json}"))
                .andExpect(status().isBadRequest());

        verify(inventoryService, never()).addInventory(any());
    }

    @Test
    public void testAddInventory_EmptyLocations() throws Exception {
        // Setup - Empty locations list
        InventoryPayload emptyLocPayload = new InventoryPayload(sampleInventory, Collections.emptyList());
        
        when(inventoryService.addInventory(any(InventoryPayload.class)))
            .thenReturn(sampleInventory);

        // Execute & Verify
        mockMvc.perform(post("/inv/v1/addInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(emptyLocPayload)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.inventory.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.locations.length()").value(0));

        verify(inventoryService, times(1)).addInventory(any(InventoryPayload.class));
    }

    @Test
    public void testGetAllInventories_Success() throws Exception {
        // Setup
        Inventory inv1 = new Inventory();
        inv1.setItemCode("ITEM001");
        inv1.setItemDescription("Item 1");

        Inventory inv2 = new Inventory();
        inv2.setItemCode("ITEM002");
        inv2.setItemDescription("Item 2");

        ItemLoc loc1 = new ItemLoc(1, "ITEM001", 50);
        ItemLoc loc2 = new ItemLoc(1, "ITEM002", 80);

        InventoryPayload payload1 = new InventoryPayload(inv1, Collections.singletonList(loc1));
        InventoryPayload payload2 = new InventoryPayload(inv2, Collections.singletonList(loc2));

        when(inventoryService.getInventoriesWithLocations())
            .thenReturn(Arrays.asList(payload1, payload2));

        // Execute & Verify
        mockMvc.perform(get("/inv/v1/getInv"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].inventory.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$[1].inventory.itemCode").value("ITEM002"));

        verify(inventoryService, times(1)).getInventoriesWithLocations();
    }

    @Test
    public void testGetAllInventories_EmptyList() throws Exception {
        // Setup
        when(inventoryService.getInventoriesWithLocations())
            .thenReturn(Collections.emptyList());

        // Execute & Verify
        mockMvc.perform(get("/inv/v1/getInv"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));

        verify(inventoryService, times(1)).getInventoriesWithLocations();
    }

    @Test
    public void testGetInventoryById_Success() throws Exception {
        // Setup
        when(inventoryService.getInventoryByCode("ITEM001"))
            .thenReturn(sampleInventory);

        // Execute & Verify
        mockMvc.perform(get("/inv/v1/getInv/ITEM001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.poPireference").value("PO-2024-001"))
                .andExpect(jsonPath("$.quantity").value(100));

        verify(inventoryService, times(1)).getInventoryByCode("ITEM001");
    }

    @Test
    public void testGetInventoryById_NotFound() throws Exception {
        // Setup
        when(inventoryService.getInventoryByCode("NONEXISTENT"))
            .thenReturn(null);

        // Execute & Verify
        mockMvc.perform(get("/inv/v1/getInv/NONEXISTENT"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").doesNotExist());

        verify(inventoryService, times(1)).getInventoryByCode("NONEXISTENT");
    }

    @Test
    public void testUpdateInventory_Success() throws Exception {
        // Setup
        Inventory updatedInventory = new Inventory();
        updatedInventory.setItemCode("ITEM001");
        updatedInventory.setPoPireference("PO-2024-002");
        updatedInventory.setQuantity(150);

        ItemLoc newLoc1 = new ItemLoc(1, "ITEM001", 100);
        ItemLoc newLoc2 = new ItemLoc(2, "ITEM001", 50);
        List<ItemLoc> newLocations = Arrays.asList(newLoc1, newLoc2);

        InventoryPayload updatedPayload = new InventoryPayload(updatedInventory, newLocations);

        when(inventoryService.updateInventory(any(InventoryPayload.class)))
            .thenReturn(updatedPayload);

        // Execute & Verify
        mockMvc.perform(put("/inv/v1/updateInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedPayload)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.inventory.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.inventory.quantity").value(150))
                .andExpect(jsonPath("$.locations.length()").value(2));

        verify(inventoryService, times(1)).updateInventory(any(InventoryPayload.class));
    }

    @Test
    public void testUpdateInventory_InvalidJson() throws Exception {
        // Execute & Verify
        mockMvc.perform(put("/inv/v1/updateInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{invalid json}"))
                .andExpect(status().isBadRequest());

        verify(inventoryService, never()).updateInventory(any());
    }

    @Test
    public void testDeleteInventory_Success() throws Exception {
        // Setup
        doNothing().when(inventoryService).deleteByInventoryId("ITEM001");

        // Execute & Verify
        mockMvc.perform(delete("/inv/v1/deleteInv/ITEM001"))
                .andExpect(status().isOk());

        verify(inventoryService, times(1)).deleteByInventoryId("ITEM001");
    }

    @Test
    public void testDeleteInventory_NonExistent() throws Exception {
        // Setup
        doNothing().when(inventoryService).deleteByInventoryId("NONEXISTENT");

        // Execute & Verify
        mockMvc.perform(delete("/inv/v1/deleteInv/NONEXISTENT"))
                .andExpect(status().isOk());

        verify(inventoryService, times(1)).deleteByInventoryId("NONEXISTENT");
    }

    @Test
    public void testGetTopStock_Success() throws Exception {
        // Setup
        Inventory inv1 = new Inventory();
        inv1.setItemCode("ITEM001");
        inv1.setQuantity(100);

        Inventory inv2 = new Inventory();
        inv2.setItemCode("ITEM002");
        inv2.setQuantity(200);

        Inventory inv3 = new Inventory();
        inv3.setItemCode("ITEM003");
        inv3.setQuantity(50);

        List<Inventory> topStock = Arrays.asList(inv2, inv1, inv3);

        when(inventoryService.getHighestStock()).thenReturn(topStock);

        // Execute & Verify
        mockMvc.perform(get("/inv/v1/getTopStock"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].quantity").value(200))
                .andExpect(jsonPath("$[1].quantity").value(100))
                .andExpect(jsonPath("$[2].quantity").value(50));

        verify(inventoryService, times(1)).getHighestStock();
    }

    @Test
    public void testGetLowStock_Success() throws Exception {
        // Setup
        Inventory inv1 = new Inventory();
        inv1.setItemCode("ITEM001");
        inv1.setQuantity(10);

        Inventory inv2 = new Inventory();
        inv2.setItemCode("ITEM002");
        inv2.setQuantity(50);

        Inventory inv3 = new Inventory();
        inv3.setItemCode("ITEM003");
        inv3.setQuantity(25);

        List<Inventory> lowStock = Arrays.asList(inv1, inv3, inv2);

        when(inventoryService.getLowestStock()).thenReturn(lowStock);

        // Execute & Verify
        mockMvc.perform(get("/inv/v1/getLowStock"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].quantity").value(10))
                .andExpect(jsonPath("$[1].quantity").value(25))
                .andExpect(jsonPath("$[2].quantity").value(50));

        verify(inventoryService, times(1)).getLowestStock();
    }

    @Test
    public void testAddInventory_WithAllRequiredFields() throws Exception {
        // Setup - User Story 2: All required fields
        Inventory fullInventory = new Inventory();
        fullInventory.setItemCode("ITEM001");
        fullInventory.setPoPireference("PO-2024-001");
        fullInventory.setInvoiceNum("INV-2024-001");
        fullInventory.setItemDescription("Chemical Reagent XYZ");
        fullInventory.setBrandId(1);
        fullInventory.setLotNum(98765);
        fullInventory.setExpiry(LocalDate.of(2025, 12, 31));
        fullInventory.setPackSize(500);
        fullInventory.setQuantity(100);
        fullInventory.setCostOfSale(250.50);
        fullInventory.setNote("Store in cool place");

        ItemLoc loc1 = new ItemLoc(1, null, 60);
        ItemLoc loc2 = new ItemLoc(2, null, 40);
        
        InventoryPayload fullPayload = new InventoryPayload(fullInventory, Arrays.asList(loc1, loc2));

        when(inventoryService.addInventory(any(InventoryPayload.class)))
            .thenReturn(fullInventory);

        // Execute & Verify
        mockMvc.perform(post("/inv/v1/addInv")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(fullPayload)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.inventory.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.inventory.poPireference").value("PO-2024-001"))
                .andExpect(jsonPath("$.inventory.invoiceNum").value("INV-2024-001"))
                .andExpect(jsonPath("$.inventory.itemDescription").value("Chemical Reagent XYZ"))
                .andExpect(jsonPath("$.inventory.lotNum").value(98765))
                .andExpect(jsonPath("$.inventory.packSize").value(500))
                .andExpect(jsonPath("$.inventory.quantity").value(100))
                .andExpect(jsonPath("$.inventory.costOfSale").value(250.50))
                .andExpect(jsonPath("$.inventory.note").value("Store in cool place"))
                .andExpect(jsonPath("$.locations.length()").value(2));

        verify(inventoryService, times(1)).addInventory(any(InventoryPayload.class));
    }
}
