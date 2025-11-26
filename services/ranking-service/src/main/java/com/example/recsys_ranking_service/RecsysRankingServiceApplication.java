package com.example.recsys_ranking_service;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@SpringBootApplication
public class RecsysRankingServiceApplication {
	@RequestMapping("/")
	public String home() {
		return "Hello world Rank";
	}
	
	public static void main(String[] args) {
		SpringApplication.run(RecsysRankingServiceApplication.class, args);
	}

}
