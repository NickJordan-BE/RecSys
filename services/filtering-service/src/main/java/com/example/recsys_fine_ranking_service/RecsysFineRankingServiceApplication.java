package com.example.recsys_fine_ranking_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
@RestController
@SpringBootApplication
public class RecsysFineRankingServiceApplication {

	@RequestMapping("/")
	public String home() {
		return "Hello World Fine";
	}

	public static void main(String[] args) {
		SpringApplication.run(RecsysFineRankingServiceApplication.class, args);
	}

}
