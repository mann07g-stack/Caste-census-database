package com.census.model;

import java.time.LocalDateTime;
import jakarta.persistence.Lob;
import jakarta.persistence.Column;

import com.census.security.AttributeEncryptor;
import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table; 
import lombok.Data;

@Entity
@Data 
@Table(name = "census_data")
public class CensusEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String householdId;

    @Convert(converter = AttributeEncryptor.class)
    private String caste;
    
    private String education;
    private String occupation;
    private Integer income;
    private String region;

    @Lob 
    @Column(length = 1000000) 
    private String profileImageBase64;

    @Enumerated(EnumType.STRING) 
    private VerificationStatus verificationStatus;
    @JsonIgnore
    private LocalDateTime createdAt = LocalDateTime.now();
}