package com.census.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.census.model.User;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, String> {
    // This allows us to find a user by their name (e.g., "admin")
    Optional<User> findByUsername(String username);
}
