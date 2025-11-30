package com.example.recsys_orchestrator_service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Mono;

@Service
public class LtrModelService {
    
	private final WebClient webClient;

	public LtrModelService(@Qualifier("ltrModelServiceWebClient") WebClient webClient) {
		this.webClient = webClient;
	}

    public Mono<String> ltrModelCall() {
        return this.webClient.get().uri("/").retrieve().bodyToMono(String.class); 
    }

	
}
