package com.biotech.lis.Repository;
import com.biotech.lis.DTO.UserSummary;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.biotech.lis.Entity.User;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    public User findUserByEmail(String email);

    List<UserSummary> findAllProjectedBy();
}
