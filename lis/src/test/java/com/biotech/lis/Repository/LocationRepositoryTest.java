package com.biotech.lis.Repository;

import com.biotech.lis.Entity.Location;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.TestPropertySource;

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
public class LocationRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private LocationRepository locationRepository;

    // Helper method to create a sample Location
    private Location createSampleLocation(String locationName) {
        Location location = new Location();
        location.setLocationName(locationName);
        return location;
    }

    @Test
    public void testSaveLocation() {
        // Create and save a sample location
        Location location = createSampleLocation("Lazcano Ref 1");
        Location savedLocation = locationRepository.save(location);
        
        // Verify the saved location
        assertNotNull(savedLocation);
        assertNotNull(savedLocation.getLocationId());
        assertEquals("Lazcano Ref 1", savedLocation.getLocationName());
    }

    @Test
    public void testFindByLocationName_Found() {
        // Create and persist a sample location
        Location location = createSampleLocation("Gandia Cold Storage");
        entityManager.persistAndFlush(location);
        
        // Test finding by location name
        Optional<Location> found = locationRepository.findByLocationName("Gandia Cold Storage");
        
        // Verify the result
        assertTrue(found.isPresent());
        assertEquals("Gandia Cold Storage", found.get().getLocationName());
    }
    
    @Test
    public void testFindByLocationName_NotFound() {
        // Test finding a non-existent location name
        Optional<Location> found = locationRepository.findByLocationName("NONEXISTENT");
        
        // Verify the result
        assertFalse(found.isPresent());
    }
    
    @Test
    public void testFindAll() {
        // Create and persist multiple locations
        entityManager.persistAndFlush(createSampleLocation("Lazcano Ref 1"));
        entityManager.persistAndFlush(createSampleLocation("Gandia Ref 1"));
        entityManager.persistAndFlush(createSampleLocation("Cebu Warehouse"));
        
        // Test findAll
        List<Location> allLocations = locationRepository.findAll();
        
        // Verify the results
        assertNotNull(allLocations);
        assertEquals(3, allLocations.size());
    }
    
    @Test
    public void testDeleteById() {
        // Create and persist two locations
        Location loc1 = createSampleLocation("Lazcano Ref 1");
        Location loc2 = createSampleLocation("Gandia Ref 1");
        entityManager.persistAndFlush(loc1);
        entityManager.persistAndFlush(loc2);
        
        // Get the ID of the first location
        Integer loc1Id = loc1.getLocationId();
        
        // Verify both exist
        assertEquals(2, locationRepository.findAll().size());
        
        // Delete one
        locationRepository.deleteById(loc1Id);
        
        // Verify only one remains
        List<Location> remaining = locationRepository.findAll();
        assertEquals(1, remaining.size());
        assertEquals("Gandia Ref 1", remaining.get(0).getLocationName());
    }
    
    @Test
    public void testExistsById() {
        // Create and persist a sample location
        Location location = createSampleLocation("Limbaga Storage");
        entityManager.persistAndFlush(location);
        
        Integer locationId = location.getLocationId();
        
        // Test existsById
        boolean exists = locationRepository.existsById(locationId);
        boolean nonExists = locationRepository.existsById(9999);
        
        // Verify the results
        assertTrue(exists);
        assertFalse(nonExists);
    }
    
}
