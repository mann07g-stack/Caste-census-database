package com.census.controller;

import com.census.model.CensusEntity;
import com.census.model.VerificationStatus;
import com.census.repository.CensusRepository;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "http://localhost:3000")
public class AdminController {

    private final CensusRepository repository;

    // Constructor Injection (REQUIRED)
    public AdminController(CensusRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/flagged-records")
    public List<CensusEntity> getFlagged() {
        return repository.findByVerificationStatus(VerificationStatus.FLAGGED);
    }
    
    @PostMapping("/verify/{id}")
    public ResponseEntity<?> verifyRecord(@PathVariable String id) {
        CensusEntity entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Record not found"));
            
        entity.setVerificationStatus(VerificationStatus.VERIFIED);
        repository.save(entity);
        
        return ResponseEntity.ok("Record Verified Successfully");
    }

    // NEW: Admin manually flags a record (if AI missed it)
    @PostMapping("/flag/{id}")
    public ResponseEntity<?> flagRecord(@PathVariable String id) {
        CensusEntity entity = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Record not found"));
            
        entity.setVerificationStatus(VerificationStatus.FLAGGED);
        repository.save(entity);
        
        return ResponseEntity.ok("Record Flagged Manually");
    }
}
