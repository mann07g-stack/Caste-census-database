package com.census.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CensusRequest {

    @NotBlank
    public String householdId;

    @NotBlank
    public String caste;

    @NotBlank
    public String education;

    @NotBlank
    public String occupation;

    @NotNull
    public Integer income;

    @NotBlank
    public String region;

    @NotBlank
    public String profileImageBase64;
}
