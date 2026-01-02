package com.census.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.census.model.CensusEntity;

@Service
public class SchemeService {

    public List<String> determineSchemes(CensusEntity person) {
        List<String> schemes = new ArrayList<>();
        
        long income = person.getIncome();
        // String caste = person.getCaste(); // Note: This might be encrypted!
        if (income < 50000) {
            schemes.add("Ayushman Bharat (Health)");
            schemes.add("PM Awas Yojana (Housing)");
        }

        if (income < 100000 && "Student".equalsIgnoreCase(person.getOccupation())) {
            schemes.add("National Scholarship Portal");
        }

        return schemes;
    }
}