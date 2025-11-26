package com.example.recsys_orchestrator_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@SpringBootApplication
public class RecsysOrchestratorServiceApplication {

	@RequestMapping("/")
	public String home() {
		return "DOne 2";
	}

	public static void main(String[] args) {
		SpringApplication.run(RecsysOrchestratorServiceApplication.class, args);
	}

}
