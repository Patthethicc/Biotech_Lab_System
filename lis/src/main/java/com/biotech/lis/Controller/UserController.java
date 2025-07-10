package com.biotech.lis.Controller;

import com.biotech.lis.Entity.LogInReq;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user/v1")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService){
        this.userService = userService;
    }
    
    @PostMapping("/addUser")
    public ResponseEntity<User> addUser(@RequestBody User user) {
            User savedUser = userService.addUser(user);
        return ResponseEntity.ok(savedUser);
    }

    @GetMapping("/getUser/{email}")
    public ResponseEntity<User> getUserByEmail(@PathVariable("email") String email) {
        final User userByEmail = userService.getUserByEmail(email);
        return ResponseEntity.ok(userByEmail);
    }

    @PutMapping("/updateUser")
    public ResponseEntity<User> updateUser(@RequestBody User user) {
        User updatedUser = userService.updateUser(user);
        return ResponseEntity.ok(updatedUser); 
    }

    @DeleteMapping("/deleteUser/{id}")
    public ResponseEntity<User> deleteUser(@PathVariable("id") Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/login")
    public ResponseEntity<LogInReq> logIn(@RequestBody LogInReq logInReq) {
        LogInReq check = userService.logInPass(logInReq.getEmail(), logInReq.getPassword());
        return ResponseEntity.ok(check);
    }
}
