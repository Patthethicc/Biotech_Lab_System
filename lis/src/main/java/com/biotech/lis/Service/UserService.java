package com.biotech.lis.Service;

import org.springframework.stereotype.Service;
import com.biotech.lis.Repository.UserRepository;
import com.biotech.lis.Entity.User;
import org.springframework.beans.factory.annotation.Autowired;

@Service
public class UserService {
    @Autowired
    UserRepository userRepository;

    public User addUser(User user) {
        return userRepository.save(user);
    }

    public User getUserByName(String name) {
        return userRepository.findUserByFirstName(name);
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}
