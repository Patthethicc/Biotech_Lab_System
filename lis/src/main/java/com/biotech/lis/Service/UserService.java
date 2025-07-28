package com.biotech.lis.Service;

import org.springframework.stereotype.Service;
import com.biotech.lis.Repository.UserRepository;
import com.biotech.lis.config.JwtService;
import com.biotech.lis.Entity.LogInReq;
import com.biotech.lis.Entity.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCrypt;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final JwtService jwtService;

    @Autowired
    public UserService(UserRepository userRepository, JwtService jwtService) {
        this.userRepository = userRepository;
        this.jwtService = jwtService;
    }

    public User addUser(User user) {

        //password hashing
        String unhashed_pass = String.valueOf(user.getPassword());
        String pw_hash = BCrypt.hashpw(unhashed_pass, BCrypt.gensalt(10));
        user.setPassword(pw_hash.toCharArray());

        return userRepository.save(user);
    }

    public User getUserById(Long id){
        return userRepository.getReferenceById(id);
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

    public LogInReq logInPass(String email, String password) {
        User stored_User = getUserByEmail(email);
        LogInReq request = new LogInReq();
        request.setEmail(email);
        request.setCheck(false);
        if(stored_User != null) {
            if(BCrypt.checkpw(password, String.valueOf(stored_User.getPassword()))) {
                request.setCheck(true);
                request.setPassword("password");
                request.setToken(jwtService.generateToken(stored_User.getUserId()));
            }
        }
        return request;
    }
}
