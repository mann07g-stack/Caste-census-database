package com.census.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data  
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String username;
    private String password;

    @Enumerated(EnumType.STRING)
    private Role role;
}