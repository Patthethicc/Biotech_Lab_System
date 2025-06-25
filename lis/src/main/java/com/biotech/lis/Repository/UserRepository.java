package com.biotech.lis.Repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    public User findUserByFirstName(String firstName);
}
