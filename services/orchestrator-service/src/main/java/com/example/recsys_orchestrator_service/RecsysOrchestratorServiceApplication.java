package com.example.recsys_orchestrator_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;


@RestController
@SpringBootApplication
public class RecsysOrchestratorServiceApplication {
 	private WebClient webClient1;
 	private WebClient webClient2;

    public void MyService(WebClient.Builder webClientBuilder) {
        this.webClient1 = webClientBuilder.baseUrl("http://localhost:8070").build();
        this.webClient2 = webClientBuilder.baseUrl("http://localhost:8060").build();
    }

    public String callExternalApi() {
        webClient1.get()
                .uri("/")
                .retrieve()
                .bodyToMono(String.class);
		webClient2.get()
                .uri("/")
                .retrieve()
                .bodyToMono(String.class);
		return "Done";
	}


	@RequestMapping("/")
	public String home() {
		callExternalApi();
		return "DOne 2";
	}

	public static void main(String[] args) {
		SpringApplication.run(RecsysOrchestratorServiceApplication.class, args);
	}

}
