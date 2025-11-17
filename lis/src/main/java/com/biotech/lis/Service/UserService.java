package com.biotech.lis.Service;

import org.springframework.stereotype.Service;
import com.biotech.lis.Repository.UserRepository;
import com.biotech.lis.config.JwtService;
import com.biotech.lis.Entity.LogInReq;
import com.biotech.lis.Entity.User;
import com.biotech.lis.Exception.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;

import java.util.logging.Logger;
import java.util.List;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final JwtService jwtService;
    private static final Logger logger = Logger.getLogger(UserService.class.getName());

    @Autowired
    public UserService(UserRepository userRepository, JwtService jwtService) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
    }

    public User addUser(User user) {
        try {
            validateUserData(user);
            
            if (userRepository.findUserByEmail(user.getEmail()) != null) {
                throw new UserAlreadyExistsException("User with email " + user.getEmail() + " already exists");
            }

            String unhashed_pass = String.valueOf(user.getPassword());
            if (unhashed_pass.length() < 6) {
                throw new InvalidUserDataException("Password must be at least 6 characters long");
            }
            
            String pw_hash = BCrypt.hashpw(unhashed_pass, BCrypt.gensalt(10));
            user.setPassword(pw_hash.toCharArray());

            User savedUser = userRepository.save(user);
            logger.info("User created successfully with email: " + user.getEmail());
            logger.info("User created successfully with id: " + user.getUserId());
            return savedUser;
            
        } catch (UserAlreadyExistsException | InvalidUserDataException e) {
            logger.warning("Failed to create user: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.severe("Unexpected error while creating user: " + e.getMessage());
            throw new RuntimeException("Failed to create user due to internal error", e);
        }
    }

    public User getUserById(Long id) {
        System.out.println(id);
        try {
            if (id == null || id <= 0) {
                throw new InvalidUserDataException("Invalid user ID provided");
            }
            
            User user = userRepository.findById(id).orElse(null);
            if (user == null) {
                throw new UserNotFoundException("User with ID " + id + " not found");
            }
            return user;
            
        } catch (UserNotFoundException | InvalidUserDataException e) {
            logger.warning("Failed to get user by ID: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.severe("Unexpected error while getting user by ID: " + e.getMessage());
            throw new RuntimeException("Failed to retrieve user due to internal error", e);
        }
    }

    public User getUserByEmail(String email) {
        System.out.println(email);
        try {
            if (email == null || email.trim().isEmpty()) {
                throw new InvalidUserDataException("Email cannot be null or empty");
            }
            
            if (!isValidEmail(email)) {
                throw new InvalidUserDataException("Invalid email format");
            }
            
            User user = userRepository.findUserByEmail(email);
            if (user == null) {
                throw new UserNotFoundException("User with email " + email + " not found");
            }
            return user;
            
        } catch (UserNotFoundException | InvalidUserDataException e) {
            logger.warning("Failed to get user by email: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.severe("Unexpected error while getting user by email: " + e.getMessage());
            throw new RuntimeException("Failed to retrieve user due to internal error", e);
        }
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }


    public User updateUser(User user) {
        try {
            if (user.getUserId() == null) {
                throw new InvalidUserDataException("User ID is required for update");
            }

            User existingUser = userRepository.findById(user.getUserId())
                    .orElseThrow(() -> new UserNotFoundException("User with ID " + user.getUserId() + " not found"));

            if (user.getFirstName() != null && !user.getFirstName().trim().isEmpty()) {
                existingUser.setFirstName(user.getFirstName());
            }
            if (user.getLastName() != null && !user.getLastName().trim().isEmpty()) {
                existingUser.setLastName(user.getLastName());
            }
            if (user.getEmail() != null && !user.getEmail().trim().isEmpty()) {
                if (!existingUser.getEmail().equals(user.getEmail()) && userRepository.findUserByEmail(user.getEmail()) != null) {
                    throw new UserAlreadyExistsException("Email " + user.getEmail() + " is already in use"); //
                }
                existingUser.setEmail(user.getEmail());
            }

            if (user.getPassword() != null && user.getPassword().length > 0) {
                String newPassword = String.valueOf(user.getPassword());
                if (newPassword.length() < 6) {
                    throw new InvalidUserDataException("Password must be at least 6 characters long"); //
                }
                String pw_hash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10)); //
                existingUser.setPassword(pw_hash.toCharArray());
            }

            User updatedUser = userRepository.save(existingUser);
            logger.info("User updated successfully with ID: " + updatedUser.getUserId()); 
            return updatedUser;

        } catch (UserNotFoundException | UserAlreadyExistsException | InvalidUserDataException e) {
            logger.warning("Failed to update user: " + e.getMessage()); 
            throw e;
        } catch (Exception e) {
            logger.severe("Unexpected error while updating user: " + e.getMessage()); 
            throw new RuntimeException("Failed to update user due to internal error", e); 
        }
    }

    public void deleteUser(Long id) {
        try {
            if (id == null || id <= 0) {
                throw new InvalidUserDataException("Invalid user ID provided");
            }
            
            getUserById(id);
            
            userRepository.deleteById(id);
            logger.info("User deleted successfully with ID: " + id);
            
        } catch (UserNotFoundException | InvalidUserDataException e) {
            logger.warning("Failed to delete user: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.severe("Unexpected error while deleting user: " + e.getMessage());
            throw new RuntimeException("Failed to delete user due to internal error", e);
        }
    }

    public LogInReq logInPass(String email, String password) {
        try {
            if (email == null || email.trim().isEmpty()) {
                throw new InvalidCredentialsException("Email address is required");
            }
            
            if (password == null || password.trim().isEmpty()) {
                throw new InvalidCredentialsException("Password is required");
            }
            
            // Validate email format
            if (!isValidEmail(email)) {
                throw new InvalidCredentialsException("Please enter a valid email address");
            }
            
            User stored_User;
            try {
                stored_User = getUserByEmail(email);
            } catch (UserNotFoundException e) {
                // Don't reveal that the user doesn't exist for security
                throw new InvalidCredentialsException("Invalid email address or password");
            }
            
            LogInReq request = new LogInReq();
            request.setEmail(email);
            request.setCheck(false);
            
            if (BCrypt.checkpw(password, String.valueOf(stored_User.getPassword()))) {
                request.setCheck(true);
                request.setPassword("password");
                System.out.println(stored_User);
                try {
                    request.setToken(jwtService.generateToken(stored_User.getUserId()));
                } catch (Exception e) {
                    throw new JwtTokenException("Failed to generate authentication token");
                }
                
                logger.info("User logged in successfully: " + email);
            } else {
                // Specific error for wrong password 
                throw new InvalidCredentialsException("Invalid email address or password");
            }
            
            return request;
            
        } catch (InvalidCredentialsException | JwtTokenException e) {
            logger.warning("Login failed: " + e.getMessage());
            throw e;
        } catch (Exception e) {
            logger.severe("Unexpected error during login: " + e.getMessage());
            throw new RuntimeException("Login failed due to internal error", e);
        }
    }
    
    private void validateUserData(User user) {
        if (user == null) {
            throw new InvalidUserDataException("User data cannot be null");
        }
        
        if (user.getFirstName() == null || user.getFirstName().trim().isEmpty()) {
            throw new InvalidUserDataException("First name is required");
        }
        
        if (user.getLastName() == null || user.getLastName().trim().isEmpty()) {
            throw new InvalidUserDataException("Last name is required");
        }
        
        if (user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            throw new InvalidUserDataException("Email is required");
        }
        
        if (!isValidEmail(user.getEmail())) {
            throw new InvalidUserDataException("Invalid email format");
        }
        
        if (user.getPassword() == null || user.getPassword().length == 0) {
            throw new InvalidUserDataException("Password is required");
        }
    }
    
    private boolean isValidEmail(String email) {
        return email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }
}
