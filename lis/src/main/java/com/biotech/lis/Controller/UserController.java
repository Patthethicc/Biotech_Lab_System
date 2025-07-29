package com.biotech.lis.Controller;

import com.biotech.lis.Entity.LogInReq;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Service.UserService;
import com.biotech.lis.Exception.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/user/v1")
public class UserController {

    private final UserService userService;
    private static final Logger logger = Logger.getLogger(UserController.class.getName());

    public UserController(UserService userService){
        this.userService = userService;
    }
    
    @PostMapping("/addUser")
    public ResponseEntity<?> addUser(@RequestBody User user) {
        try {
            User savedUser = userService.addUser(user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "User created successfully");
            response.put("user", savedUser);
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (UserAlreadyExistsException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(errorResponse);
            
        } catch (InvalidUserDataException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
            
        } catch (Exception e) {
            logger.severe("Unexpected error in addUser: " + e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Internal server error occurred");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @GetMapping("/getUser/id/{id}")
    public ResponseEntity<?> getUserById(@PathVariable("id") Long id) {
        try {
            User userById = userService.getUserById(id);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("user", userById);
            
            return ResponseEntity.ok(response);
            
        } catch (UserNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
            
        } catch (InvalidUserDataException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
            
        } catch (Exception e) {
            logger.severe("Unexpected error in getUserByEmail: " + e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Internal server error occurred");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @GetMapping("/getUser/{email}")
    public ResponseEntity<?> getUserByEmail(@PathVariable("email") String email) {
        try {
            User userByEmail = userService.getUserByEmail(email);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("user", userByEmail);
            
            return ResponseEntity.ok(response);
            
        } catch (UserNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
            
        } catch (InvalidUserDataException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
            
        } catch (Exception e) {
            logger.severe("Unexpected error in getUserByEmail: " + e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Internal server error occurred");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @PutMapping("/updateUser")
    public ResponseEntity<?> updateUser(@RequestBody User user) {
        try {
            User updatedUser = userService.updateUser(user);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "User updated successfully");
            response.put("user", updatedUser);
            
            return ResponseEntity.ok(response);
            
        } catch (UserNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
            
        } catch (UserAlreadyExistsException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(errorResponse);
            
        } catch (InvalidUserDataException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
            
        } catch (Exception e) {
            logger.severe("Unexpected error in updateUser: " + e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Internal server error occurred");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @DeleteMapping("/deleteUser/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable("id") Long id) {
        try {
            userService.deleteUser(id);
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "User deleted successfully");
            
            return ResponseEntity.ok(response);
            
        } catch (UserNotFoundException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
            
        } catch (InvalidUserDataException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
            
        } catch (Exception e) {
            logger.severe("Unexpected error in deleteUser: " + e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Internal server error occurred");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> logIn(@RequestBody LogInReq logInReq) {
        try {
            LogInReq check = userService.logInPass(logInReq.getEmail(), logInReq.getPassword());
            
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Login successful");
            response.put("data", check);
            
            return ResponseEntity.ok(response);
            
        } catch (InvalidCredentialsException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
            
        } catch (JwtTokenException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Authentication token generation failed");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
            
        } catch (Exception e) {
            logger.severe("Unexpected error in login: " + e.getMessage());
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "Login failed due to internal error");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
