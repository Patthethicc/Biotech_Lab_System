package com.biotech.lis.Controller;

import com.biotech.lis.Entity.PurchaseOrder;
import com.biotech.lis.Service.PurchaseOrderService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Collections;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PurchaseOrderController.class)
public class PurchaseOrderControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PurchaseOrderService purchaseOrderService;

    @Autowired
    private ObjectMapper objectMapper;

    // Helper method to create a sample PurchaseOrder
    private PurchaseOrder createSamplePurchaseOrder() {
        PurchaseOrder po = new PurchaseOrder();
        po.setItemCode("ITEM001");
        po.setBrandId(1);
        po.setProductDescription("Test Description");
        po.setPackSize(10.0);
        po.setQuantity(5);
        po.setUnitCost(100.0);
        po.setPoPireference("REF123");
        return po;
    }

    @Test
    public void testAddPurchaseOrder_Success() throws Exception {
        PurchaseOrder samplePO = createSamplePurchaseOrder();
        
        when(purchaseOrderService.addPurchaseOrder(any(PurchaseOrder.class)))
            .thenReturn(samplePO);

        mockMvc.perform(post("/PO/v1/addPO")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(samplePO)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.brand").value("TestBrand"));

        verify(purchaseOrderService, times(1)).addPurchaseOrder(any(PurchaseOrder.class));
    }

    @Test
    public void testAddPurchaseOrder_NullInput() throws Exception {
        mockMvc.perform(post("/PO/v1/addPO")
                .contentType(MediaType.APPLICATION_JSON)
                .content(""))
                .andExpect(status().isBadRequest());

        verify(purchaseOrderService, never()).addPurchaseOrder(any());
    }

    @Test
    public void testAddPurchaseOrder_ServiceThrowsException() throws Exception {
        PurchaseOrder samplePO = createSamplePurchaseOrder();
        
        when(purchaseOrderService.addPurchaseOrder(any(PurchaseOrder.class)))
            .thenThrow(new RuntimeException("Database error"));

        mockMvc.perform(post("/PO/v1/addPO")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(samplePO)))
                .andExpect(status().isInternalServerError());

        verify(purchaseOrderService, times(1)).addPurchaseOrder(any());
    }

    @Test
    public void testGetAllPurchaseOrders_Success() throws Exception {
        PurchaseOrder po1 = createSamplePurchaseOrder();
        PurchaseOrder po2 = createSamplePurchaseOrder();
        po2.setItemCode("ITEM002");
        
        when(purchaseOrderService.getAllPurchaseOrders())
            .thenReturn(Arrays.asList(po1, po2));

        mockMvc.perform(get("/PO/v1/getPOs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].itemCode").value("ITEM001"))
                .andExpect(jsonPath("$[1].itemCode").value("ITEM002"));

        verify(purchaseOrderService, times(1)).getAllPurchaseOrders();
    }

    @Test
    public void testGetAllPurchaseOrders_EmptyList() throws Exception {
        when(purchaseOrderService.getAllPurchaseOrders())
            .thenReturn(Collections.emptyList());

        mockMvc.perform(get("/PO/v1/getPOs"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));

        verify(purchaseOrderService, times(1)).getAllPurchaseOrders();
    }

    @Test
    public void testGetPurchaseOrderByCode_Success() throws Exception {
        PurchaseOrder samplePO = createSamplePurchaseOrder();
        
        when(purchaseOrderService.getPurchaseOrderByCode("ITEM001"))
            .thenReturn(Optional.of(samplePO));

        mockMvc.perform(get("/PO/v1/getPO/ITEM001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.itemCode").value("ITEM001"))
                .andExpect(jsonPath("$.brand").value("TestBrand"));

        verify(purchaseOrderService, times(1)).getPurchaseOrderByCode("ITEM001");
    }

    @Test
    public void testGetPurchaseOrderByCode_NotFound() throws Exception {
        when(purchaseOrderService.getPurchaseOrderByCode("NONEXISTENT"))
            .thenReturn(Optional.empty());

        mockMvc.perform(get("/PO/v1/getPO/NONEXISTENT"))
                .andExpect(status().isNotFound());

        verify(purchaseOrderService, times(1)).getPurchaseOrderByCode("NONEXISTENT");
    }

    @Test
    public void testUpdatePurchaseOrder_Success() throws Exception {
        PurchaseOrder samplePO = createSamplePurchaseOrder();
        
        when(purchaseOrderService.getPurchaseOrderByCode("ITEM001"))
            .thenReturn(Optional.of(samplePO));
        when(purchaseOrderService.updatePurchaseOrder(any(PurchaseOrder.class)))
            .thenReturn(samplePO);

        mockMvc.perform(put("/PO/v1/updatePO")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(samplePO)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.itemCode").value("ITEM001"));

        verify(purchaseOrderService, times(1)).getPurchaseOrderByCode("ITEM001");
        verify(purchaseOrderService, times(1)).updatePurchaseOrder(any(PurchaseOrder.class));
    }

    @Test
    public void testUpdatePurchaseOrder_NotFound() throws Exception {
        PurchaseOrder samplePO = createSamplePurchaseOrder();
        
        when(purchaseOrderService.getPurchaseOrderByCode("ITEM001"))
            .thenReturn(Optional.empty());

        mockMvc.perform(put("/PO/v1/updatePO")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(samplePO)))
                .andExpect(status().isNotFound());

        verify(purchaseOrderService, times(1)).getPurchaseOrderByCode("ITEM001");
        verify(purchaseOrderService, never()).updatePurchaseOrder(any());
    }

    @Test
    public void testDeletePurchaseOrder_Success() throws Exception {
        PurchaseOrder samplePO = createSamplePurchaseOrder();
        
        when(purchaseOrderService.getPurchaseOrderByCode("ITEM001"))
            .thenReturn(Optional.of(samplePO));
        doNothing().when(purchaseOrderService).deletePurchaseOrder("ITEM001");

        mockMvc.perform(delete("/PO/v1/deletePO/ITEM001"))
                .andExpect(status().isNoContent());

        verify(purchaseOrderService, times(1)).getPurchaseOrderByCode("ITEM001");
        verify(purchaseOrderService, times(1)).deletePurchaseOrder("ITEM001");
    }

    @Test
    public void testDeletePurchaseOrder_NotFound() throws Exception {
        when(purchaseOrderService.getPurchaseOrderByCode("NONEXISTENT"))
            .thenReturn(Optional.empty());

        mockMvc.perform(delete("/PO/v1/deletePO/NONEXISTENT"))
                .andExpect(status().isNotFound());

        verify(purchaseOrderService, times(1)).getPurchaseOrderByCode("NONEXISTENT");
        verify(purchaseOrderService, never()).deletePurchaseOrder(anyString());
    }
}