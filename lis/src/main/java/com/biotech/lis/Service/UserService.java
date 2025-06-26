package com.biotech.lis.Service;

import org.springframework.stereotype.Service;
import com.biotech.lis.Repository.UserRepository;
import com.biotech.lis.Entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;

@Service
public class UserService {
    @Autowired
    UserRepository userRepository;

    public User addUser(User user) {

        //password hashing
        String unhashed_pass = String.valueOf(user.getPassword());
        String pw_hash = BCrypt.hashpw(unhashed_pass, BCrypt.gensalt(10));
        user.setPassword(pw_hash.toCharArray());

        return userRepository.save(user);
    }

    public User getUserByEmail(String email) {
        return userRepository.findUserByEmail(email);
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    public Boolean logInPass(String email, String password) {
        User stored_User = getUserByEmail(email);

        if(stored_User != null) {
            if(BCrypt.checkpw(password, String.valueOf(stored_User.getPassword()))) {
                return true;
            }
        }

        return false;
    }
}
