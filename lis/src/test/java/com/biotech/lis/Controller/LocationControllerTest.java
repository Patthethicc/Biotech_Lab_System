package com.biotech.lis.Controller;

import com.biotech.lis.Entity.Location;
import com.biotech.lis.Service.LocationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(LocationController.class)
public class LocationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private LocationService locationService;

    @Autowired
    private ObjectMapper objectMapper;

    // Helper method to create a sample Location
    private Location createSampleLocation(Integer id, String name) {
        Location location = new Location();
        location.setLocationId(id);
        location.setLocationName(name);
        return location;
    }

    @Test
    public void testAddLocation_Success() throws Exception {
        Location sampleLocation = createSampleLocation(1, "Lazcano Ref 1");
        
        when(locationService.addLocation(any(Location.class)))
            .thenReturn(sampleLocation);

        mockMvc.perform(post("/locations/addLoc")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(sampleLocation)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.locationId").value(1))
                .andExpect(jsonPath("$.locationName").value("Lazcano Ref 1"));

        verify(locationService, times(1)).addLocation(any(Location.class));
    }

    @Test
    public void testAddLocation_NullInput() throws Exception {
        mockMvc.perform(post("/locations/addLoc")
                .contentType(MediaType.APPLICATION_JSON)
                .content(""))
                .andExpect(status().isBadRequest());

        verify(locationService, never()).addLocation(any());
    }

    @Test
    public void testAddLocation_ServiceThrowsException() throws Exception {
        Location sampleLocation = createSampleLocation(null, "Test Location");
        
        when(locationService.addLocation(any(Location.class)))
            .thenThrow(new RuntimeException("Database error"));

        mockMvc.perform(post("/locations/addLoc")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(sampleLocation)))
                .andExpect(status().isInternalServerError());

        verify(locationService, times(1)).addLocation(any(Location.class));
    }

    @Test
    public void testGetAllLocations_Success() throws Exception {
        Location loc1 = createSampleLocation(1, "Lazcano Ref 1");
        Location loc2 = createSampleLocation(2, "Gandia Cold Storage");
        Location loc3 = createSampleLocation(3, "Cebu Warehouse");
        
        when(locationService.getAllLocations())
            .thenReturn(Arrays.asList(loc1, loc2, loc3));

        mockMvc.perform(get("/locations/getLoc"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(3))
                .andExpect(jsonPath("$[0].locationName").value("Lazcano Ref 1"))
                .andExpect(jsonPath("$[1].locationName").value("Gandia Cold Storage"))
                .andExpect(jsonPath("$[2].locationName").value("Cebu Warehouse"));

        verify(locationService, times(1)).getAllLocations();
    }

    @Test
    public void testGetAllLocations_EmptyList() throws Exception {
        when(locationService.getAllLocations())
            .thenReturn(Collections.emptyList());

        mockMvc.perform(get("/locations/getLoc"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));

        verify(locationService, times(1)).getAllLocations();
    }

    @Test
    public void testUpdateLocation_Success() throws Exception {
        Location updatedLocation = createSampleLocation(1, "Updated Location Name");
        
        when(locationService.updateLocation(anyString(), any(Location.class)))
            .thenReturn(updatedLocation);

        mockMvc.perform(put("/locations/editLoc/OldName")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedLocation)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.locationId").value(1))
                .andExpect(jsonPath("$.locationName").value("Updated Location Name"));

        verify(locationService, times(1)).updateLocation(eq("OldName"), any(Location.class));
    }

    @Test
    public void testUpdateLocation_NotFound() throws Exception {
        Location updateData = createSampleLocation(null, "New Name");
        
        when(locationService.updateLocation(eq("NONEXISTENT"), any(Location.class)))
            .thenThrow(new RuntimeException("Location not found with name: NONEXISTENT"));

        // Controller returns 404 for RuntimeException in updateLocation
        mockMvc.perform(put("/locations/editLoc/NONEXISTENT")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updateData)))
                .andExpect(status().isNotFound());

        verify(locationService, times(1)).updateLocation(eq("NONEXISTENT"), any(Location.class));
    }

    @Test
    public void testUpdateLocation_InvalidJson() throws Exception {
        mockMvc.perform(put("/locations/editLoc/TestLocation")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{invalid json}"))
                .andExpect(status().isBadRequest());

        verify(locationService, never()).updateLocation(anyString(), any());
    }

    @Test
    public void testDeleteLocation_Success() throws Exception {
        doNothing().when(locationService).deleteLocation(1);

        mockMvc.perform(delete("/locations/deleteLoc/1"))
                .andExpect(status().isNoContent());

        verify(locationService, times(1)).deleteLocation(1);
    }

    @Test
    public void testDeleteLocation_WithNonExistentId() throws Exception {
        doNothing().when(locationService).deleteLocation(9999);

        mockMvc.perform(delete("/locations/deleteLoc/9999"))
                .andExpect(status().isNoContent());

        verify(locationService, times(1)).deleteLocation(9999);
    }

    @Test
    public void testDeleteLocation_InvalidIdFormat() throws Exception {
        mockMvc.perform(delete("/locations/deleteLoc/invalid"))
                .andExpect(status().isBadRequest());

        verify(locationService, never()).deleteLocation(anyInt());
    }

    @Test
    public void testAddLocation_WithEmptyLocationName() throws Exception {
        Location emptyNameLocation = createSampleLocation(null, "");
        
        when(locationService.addLocation(any(Location.class)))
            .thenReturn(emptyNameLocation);

        mockMvc.perform(post("/locations/addLoc")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(emptyNameLocation)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.locationName").value(""));

        verify(locationService, times(1)).addLocation(any(Location.class));
    }

    @Test
    public void testUpdateLocation_WithSpecialCharacters() throws Exception {
        Location specialCharLocation = createSampleLocation(1, "Location #1 - Storage & Ref");
        
        when(locationService.updateLocation(eq("OldName"), any(Location.class)))
            .thenReturn(specialCharLocation);

        mockMvc.perform(put("/locations/editLoc/OldName")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(specialCharLocation)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.locationName").value("Location #1 - Storage & Ref"));

        verify(locationService, times(1)).updateLocation(eq("OldName"), any(Location.class));
    }
}
