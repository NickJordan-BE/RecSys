package com.example.recsys_orchestrator_service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Mono;

@Service
public class GbdtModelService {
    
	private final WebClient webClient;

	public GbdtModelService(@Qualifier("gbdtModelServiceWebClient") WebClient webClient) {
		this.webClient = webClient;
	}

    public Mono<String> gbdtModelCall() {
        return this.webClient.get().uri("/").retrieve().bodyToMono(String.class); 
    }

	
}
