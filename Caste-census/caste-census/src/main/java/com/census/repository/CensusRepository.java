package com.census.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.census.model.CensusEntity;
import com.census.model.VerificationStatus;
import java.util.List;

public interface CensusRepository extends JpaRepository<CensusEntity, String> {
    
    // Spring Data JPA automatically writes the SQL for this method
    List<CensusEntity> findByVerificationStatus(VerificationStatus status);
}