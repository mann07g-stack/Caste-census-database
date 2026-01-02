package com.census.config;

import com.census.model.Role;
import com.census.model.User;
import com.census.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;

    public DataSeeder(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        // 1. Check if we already have users. If yes, do nothing.
        if (userRepository.count() > 0) {
            System.out.println("✅ Users already exist. Skipping seed.");
            return;
        }

        System.out.println("⚡ No users found. Creating default Admin & Enumerator...");

        // 2. Create Admin
        User admin = new User();
        admin.setUsername("admin");
        admin.setPassword("admin123"); // In real life, encrypt this!
        admin.setRole(Role.ADMIN);
        userRepository.save(admin);

        // 3. Create Enumerator
        User enumerator = new User();
        enumerator.setUsername("user");
        enumerator.setPassword("user123");
        enumerator.setRole(Role.ENUMERATOR);
        userRepository.save(enumerator);

        System.out.println("✅ Default users created successfully!");
    }
}