package com.census.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.census.dto.CensusRequest;
import com.census.model.CensusEntity;
import com.census.model.VerificationStatus;
import com.census.repository.CensusRepository;

@Service
public class CensusService {

    private final CensusRepository repository;
    private final AiVerificationService aiService;

    public CensusService(CensusRepository repository, AiVerificationService aiService) {
        this.repository = repository;
        this.aiService = aiService;
    }

    public CensusEntity save(CensusEntity data) {
        return repository.save(data);
    }

    public List<CensusEntity> getAll() {
        return repository.findAll();
    }

    public CensusEntity saveValidated(CensusRequest request) {
        CensusEntity entity = new CensusEntity();
        entity.setHouseholdId(request.householdId);
        entity.setCaste(request.caste);
        entity.setEducation(request.education);
        entity.setOccupation(request.occupation);
        entity.setIncome(request.income);
        entity.setRegion(request.region);
        entity.setProfileImageBase64(request.profileImageBase64);
        
        // This requires the new field in CensusEntity
        entity.setVerificationStatus(VerificationStatus.PENDING);

        return repository.save(entity);
    }

    public void markFlagged(String id) {
        CensusEntity entity = repository.findById(id).orElseThrow();
        entity.setVerificationStatus(VerificationStatus.FLAGGED);
        repository.save(entity);
    }

    public void runAiVerification() {
        List<CensusEntity> allData = repository.findAll();
        List<String> flaggedIds = aiService.getFlaggedRecords(allData);

        for (String id : flaggedIds) {
            markFlagged(id);
        }
    }

}