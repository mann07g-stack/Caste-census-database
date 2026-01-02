package com.census.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.census.model.User;
import com.census.repository.UserRepository;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") 
public class AuthController {

    private final UserRepository userRepository;

    // Constructor Injection: This connects the Repository to the Controller
    public AuthController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User loginRequest) {
        Optional<User> userOpt = userRepository.findByUsername(loginRequest.getUsername());

        if (userOpt.isPresent()) {
            User dbUser = userOpt.get();
            if (dbUser.getPassword().equals(loginRequest.getPassword())) {
                return ResponseEntity.ok("ROLE_" + dbUser.getRole().name());
            }
        }
        return ResponseEntity.status(401).body("Invalid Credentials");
    }
}