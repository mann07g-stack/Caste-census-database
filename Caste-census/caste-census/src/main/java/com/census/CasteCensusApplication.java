package com.census; // <--- This MUST be just 'com.census'

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

// This single annotation does ALL the scanning automatically
@SpringBootApplication(exclude = { SecurityAutoConfiguration.class })
public class CasteCensusApplication {

    public static void main(String[] args) {
        SpringApplication.run(CasteCensusApplication.class, args);
    }
    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

}