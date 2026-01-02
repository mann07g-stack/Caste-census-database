package com.census.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.census.model.CensusEntity;

@Service
public class AiVerificationService {

    private final RestTemplate restTemplate;

    public AiVerificationService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @SuppressWarnings("unchecked")
    public List<String> getFlaggedRecords(List<CensusEntity> data) {
        // CHANGE 1: Use 127.0.0.1 instead of localhost (Fixes connection errors)
        String aiUrl = "http://127.0.0.1:8001/ai/verify";

        if (data.isEmpty()) {
            return Collections.emptyList();
        }

        // CHANGE 2: Create a "Safe Payload"
        // Instead of sending the complex 'CensusEntity', we send simple text/numbers.
        List<Map<String, Object>> safePayload = new ArrayList<>();
        
        for (CensusEntity entity : data) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", entity.getId());
            map.put("householdId", entity.getHouseholdId());
            map.put("income", entity.getIncome());
            safePayload.add(map);
        }

        try {
            // Send the safePayload, NOT the raw data
            ResponseEntity<Map> response = 
                restTemplate.postForEntity(aiUrl, safePayload, Map.class);

            Map<String, Object> body = response.getBody();
            
            if (body != null && body.containsKey("flagged_records")) {
                return (List<String>) body.get("flagged_records");
            }
        } catch (Exception e) {
            System.err.println("!!! AI CONNECTION ERROR !!!");
            System.err.println("Reason: " + e.getMessage());
            e.printStackTrace(); 
        }

        return Collections.emptyList();
    }
}