package com.example.orchestrator;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Main application class for the Orchestrator service. */
@SpringBootApplication
public class OrchestratorApplication {

  /**
   * The entry point of the Spring Boot application.
   *
   * @param args command line arguments.
   */
  public static void main(String[] args) {
    SpringApplication.run(OrchestratorApplication.class, args);
  }
}
