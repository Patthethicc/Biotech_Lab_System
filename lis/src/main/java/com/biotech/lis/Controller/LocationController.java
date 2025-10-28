package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.biotech.lis.Service.LocationService;
import com.biotech.lis.Entity.Location;

@RestController
@RequestMapping("/locations")
public class LocationController {

    private LocationService locationService;

    @PostMapping("/addLoc")
    public ResponseEntity<Location> addLocation(@RequestBody Location location) {
        Location savedLocation = locationService.addLocation(location);
        return ResponseEntity.ok(savedLocation);
    }

    @GetMapping("/getLoc")
    public ResponseEntity<List<Location>> getAllLocations() {
        List<Location> locations = locationService.getAllLocations();
        return ResponseEntity.ok(locations);
    }

    @PutMapping("/editLoc/{id}")
    public ResponseEntity<Location> updateLocation(@PathVariable String name, @RequestBody Location location) {
        return ResponseEntity.ok(locationService.updateLocation(name, location));
    }

    @DeleteMapping("/deleteLoc/{id}")
    public ResponseEntity<String> deleteLocation(@PathVariable Integer id) {
        locationService.deleteLocation(id);
        return ResponseEntity.ok("Location deleted successfully.");
    }
}

