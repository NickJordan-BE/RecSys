package com.example.recsys_orchestrator_service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {
    @Value("${spring.candidate.gen.container.url}")
    private String candidateGenUrl;
    
    @Value("${spring.gbdt.model.container.url}")
    private String gbdtModelUrl;

    @Value("${spring.ltr.model.container.url}")
    private String ltrModelUrl;

    @Bean
    @Qualifier("candidateGenModelServiceWebClient")
    public WebClient candidateGenWebClient(WebClient.Builder builder) {
        return builder.baseUrl(candidateGenUrl).build();
    }
    
    @Bean
    @Qualifier("gbdtModelServiceWebClient")
    public WebClient gbdtModelServiceWebClient(WebClient.Builder builder) {
        return builder.baseUrl("http://gbdt-model-service:80").build();
    }
    
    @Bean
    @Qualifier("ltrModelServiceWebClient")
    public WebClient ltrModelServiceWebClient(WebClient.Builder builder) {
        return builder.baseUrl("http://ltr-model-service:80").build();
    }
}
