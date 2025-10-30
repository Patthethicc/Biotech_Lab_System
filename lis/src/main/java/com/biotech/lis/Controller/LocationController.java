package com.biotech.lis.Controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.biotech.lis.Service.LocationService;
import com.biotech.lis.Entity.Location;

@RestController
@RequestMapping("/locations")
public class LocationController {

    private final LocationService locationService;

    @Autowired
    public LocationController(LocationService locationService) {
        this.locationService = locationService;
    }

    @PostMapping("/addLoc")
    public ResponseEntity<Location> addLocation(@RequestBody Location location) {
        Location savedLocation = locationService.addLocation(location);
        return ResponseEntity.status(HttpStatus.CREATED).body(savedLocation);
    }

    @GetMapping("/getLoc")
    public ResponseEntity<List<Location>> getAllLocations() {
        List<Location> locations = locationService.getAllLocations();
        return ResponseEntity.ok(locations);
    }

    @PutMapping("/editLoc/{name}")
    public ResponseEntity<Location> updateLocation(@PathVariable("name") String name, @RequestBody Location location) {
        return ResponseEntity.ok(locationService.updateLocation(name, location));
    }

    @DeleteMapping("/deleteLoc/{id}")
    public ResponseEntity<String> deleteLocation(@PathVariable Integer id) {
        locationService.deleteLocation(id);
        return ResponseEntity.noContent().build();
    }
}

