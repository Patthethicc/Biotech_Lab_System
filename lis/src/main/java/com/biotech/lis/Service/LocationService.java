package com.biotech.lis.Service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.biotech.lis.Entity.Location;
import com.biotech.lis.Repository.LocationRepository;

@Service
public class LocationService {

    @Autowired
    private LocationRepository locationRepository;

    public Location addLocation(Location location) {
        String cleanName = location.getLocationName().trim();

        if (locationRepository.existsByLocationNameIgnoreCase(cleanName)) {
            throw new IllegalArgumentException("Location with name '" + cleanName + "' already exists.");
        }

        return locationRepository.save(location);
    }

    public List<Location> getAllLocations() {
        return locationRepository.findAll();
    }

    public Location getLocationByName(String name) {
        Optional<Location> optionalLoc = locationRepository.findByLocationName(name);
        return optionalLoc.orElseThrow(
            () -> new RuntimeException("Location not found with name: " + name)
        );
    }

    public Location updateLocation(String name, Location updatedLocation) {
        Location location = getLocationByName(name);
        String newName = updatedLocation.getLocationName().trim();

        if (newName != null && !newName.isBlank() && !newName.equalsIgnoreCase(location.getLocationName())) {
            if (locationRepository.existsByLocationNameIgnoreCase(newName)) {
                throw new IllegalArgumentException("Location name '" + newName + "' already exists.");
            }

            location.setLocationName(newName);
        }

        Location savedLocation = locationRepository.save(location);
        
        return savedLocation;
    }

    public void deleteLocation(Integer id) {
        locationRepository.deleteById(id);
    }

}

