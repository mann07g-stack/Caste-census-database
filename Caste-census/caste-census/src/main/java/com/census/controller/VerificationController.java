package com.census.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.census.service.CensusService;

@RestController
@RequestMapping("/api/verify")
public class VerificationController {

    private final CensusService service;

    // Constructor Injection
    public VerificationController(CensusService service) {
        this.service = service;
    }

    @PostMapping("/{id}/flag")
    public ResponseEntity<?> flag(@PathVariable String id) {
        service.markFlagged(id);
        return ResponseEntity.ok("Record flagged for review");
    }

}