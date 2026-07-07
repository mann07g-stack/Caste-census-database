package com.census.controller;

import java.util.List;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.census.dto.CensusRequest;
import com.census.model.CensusEntity;
import com.census.service.CensusService;

import jakarta.validation.Valid;


@RestController
@RequestMapping("/api/census")
@CrossOrigin(origins = "http://localhost:3000")
public class CensusController {

    private final CensusService service;

    public CensusController(CensusService service) {
        this.service = service;
    }

    @PostMapping("/submit")
    public ResponseEntity<?> submit(
        @Valid @RequestBody CensusRequest request) {

    return ResponseEntity.ok(service.saveValidated(request));
}
  

    @GetMapping("/all")
    public List<CensusEntity> getAll() {
        return service.getAll();
    }
    @PostMapping("/run-ai")
    public ResponseEntity<?> runAiCheck() {
        service.runAiVerification();
        return ResponseEntity.ok("AI verification completed");
    }

    @GetMapping("/status/{householdId}")
    public ResponseEntity<?> getStatus(@PathVariable String householdId) {
        
        Optional<CensusEntity> person = service.getAll().stream()
                .filter(p -> p.getHouseholdId().equalsIgnoreCase(householdId))
                .findFirst();

        if (person.isPresent()) {
            return ResponseEntity.ok(person.get());
        } else {
            return ResponseEntity.status(404).body("Record not found");
        }
    }

}
