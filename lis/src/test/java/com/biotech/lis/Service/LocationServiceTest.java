package com.biotech.lis.Service;

import com.biotech.lis.Entity.Location;
import com.biotech.lis.Repository.LocationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class LocationServiceTest {

    @Mock
    private LocationRepository locationRepository;

    @InjectMocks
    private LocationService locationService;

    private Location sampleLocation;

    @BeforeEach
    void setUp() {
        sampleLocation = new Location();
        sampleLocation.setLocationId(1);
        sampleLocation.setLocationName("Lazcano Ref 1");
    }

    @Test
    void testAddLocation() {
        // Setup
        Location newLocation = new Location();
        newLocation.setLocationName("Gandia Cold Storage");
        
        Location savedLocation = new Location();
        savedLocation.setLocationId(1);
        savedLocation.setLocationName("Gandia Cold Storage");
        
        when(locationRepository.save(any(Location.class))).thenReturn(savedLocation);

        // Execute
        Location result = locationService.addLocation(newLocation);

        // Verify
        assertNotNull(result);
        assertEquals(1, result.getLocationId());
        assertEquals("Gandia Cold Storage", result.getLocationName());
        verify(locationRepository, times(1)).save(any(Location.class));
    }

    @Test
    void testGetAllLocations() {
        // Setup
        Location location1 = new Location(1, "Lazcano Ref 1");
        Location location2 = new Location(2, "Gandia Ref 1");
        Location location3 = new Location(3, "Cebu Warehouse");
        List<Location> locationList = Arrays.asList(location1, location2, location3);
        
        when(locationRepository.findAll()).thenReturn(locationList);

        // Execute
        List<Location> result = locationService.getAllLocations();

        // Verify
        assertNotNull(result);
        assertEquals(3, result.size());
        assertEquals("Lazcano Ref 1", result.get(0).getLocationName());
        assertEquals("Gandia Ref 1", result.get(1).getLocationName());
        assertEquals("Cebu Warehouse", result.get(2).getLocationName());
        verify(locationRepository, times(1)).findAll();
    }

    @Test
    void testGetLocationByName_Found() {
        // Setup
        when(locationRepository.findByLocationName("Lazcano Ref 1"))
            .thenReturn(Optional.of(sampleLocation));

        // Execute
        Location result = locationService.getLocationByName("Lazcano Ref 1");

        // Verify
        assertNotNull(result);
        assertEquals(1, result.getLocationId());
        assertEquals("Lazcano Ref 1", result.getLocationName());
        verify(locationRepository, times(1)).findByLocationName("Lazcano Ref 1");
    }

    @Test
    void testGetLocationByName_NotFound() {
        // Setup
        when(locationRepository.findByLocationName("NONEXISTENT"))
            .thenReturn(Optional.empty());

        // Execute & Verify
        RuntimeException exception = assertThrows(RuntimeException.class, () -> 
            locationService.getLocationByName("NONEXISTENT")
        );
        
        assertEquals("Location not found with name: NONEXISTENT", exception.getMessage());
        verify(locationRepository, times(1)).findByLocationName("NONEXISTENT");
    }

    @Test
    void testUpdateLocation_Success() {
        // Setup
        Location existingLocation = new Location(1, "Old Location Name");
        Location updatedLocation = new Location();
        updatedLocation.setLocationName("New Location Name");
        
        Location savedLocation = new Location(1, "New Location Name");
        
        when(locationRepository.findByLocationName("Old Location Name"))
            .thenReturn(Optional.of(existingLocation));
        when(locationRepository.save(any(Location.class))).thenReturn(savedLocation);

        // Execute
        Location result = locationService.updateLocation("Old Location Name", updatedLocation);

        // Verify
        assertNotNull(result);
        assertEquals(1, result.getLocationId());
        assertEquals("New Location Name", result.getLocationName());
        verify(locationRepository, times(1)).findByLocationName("Old Location Name");
        verify(locationRepository, times(1)).save(any(Location.class));
    }

    @Test
    void testUpdateLocation_LocationNotFound() {
        // Setup
        Location updatedLocation = new Location();
        updatedLocation.setLocationName("New Name");
        
        when(locationRepository.findByLocationName("NONEXISTENT"))
            .thenReturn(Optional.empty());

        // Execute & Verify
        RuntimeException exception = assertThrows(RuntimeException.class, () -> 
            locationService.updateLocation("NONEXISTENT", updatedLocation)
        );
        
        assertEquals("Location not found with name: NONEXISTENT", exception.getMessage());
        verify(locationRepository, times(1)).findByLocationName("NONEXISTENT");
        verify(locationRepository, never()).save(any(Location.class));
    }

    @Test
    void testUpdateLocation_WithNullName() {
        // Setup
        Location existingLocation = new Location(1, "Original Name");
        Location updatedLocation = new Location();
        updatedLocation.setLocationName(null); // Null name - will cause NullPointerException
        
        when(locationRepository.findByLocationName("Original Name"))
            .thenReturn(Optional.of(existingLocation));

        // Execute & Verify - Expecting NullPointerException due to .trim() on null
        assertThrows(NullPointerException.class, () -> 
            locationService.updateLocation("Original Name", updatedLocation)
        );

        verify(locationRepository, times(1)).findByLocationName("Original Name");
        verify(locationRepository, never()).save(any(Location.class));
    }

    @Test
    void testUpdateLocation_WithBlankName() {
        // Setup
        Location existingLocation = new Location(1, "Original Name");
        Location updatedLocation = new Location();
        updatedLocation.setLocationName("   "); // Blank name - should not update
        
        when(locationRepository.findByLocationName("Original Name"))
            .thenReturn(Optional.of(existingLocation));
        when(locationRepository.save(any(Location.class))).thenReturn(existingLocation);

        // Execute
        Location result = locationService.updateLocation("Original Name", updatedLocation);

        // Verify - Name should remain unchanged
        assertNotNull(result);
        assertEquals("Original Name", result.getLocationName());
        verify(locationRepository, times(1)).findByLocationName("Original Name");
        verify(locationRepository, times(1)).save(any(Location.class));
    }

    @Test
    void testDeleteLocation() {
        // Setup
        doNothing().when(locationRepository).deleteById(1);

        // Execute
        locationService.deleteLocation(1);

        // Verify
        verify(locationRepository, times(1)).deleteById(1);
    }

    @Test
    void testDeleteLocation_WithNonExistentId() {
        // Setup
        doNothing().when(locationRepository).deleteById(9999);

        // Execute
        locationService.deleteLocation(9999);

        // Verify - Should still call deleteById even if location doesn't exist
        // (JPA deleteById doesn't throw exception if entity doesn't exist)
        verify(locationRepository, times(1)).deleteById(9999);
    }
}
