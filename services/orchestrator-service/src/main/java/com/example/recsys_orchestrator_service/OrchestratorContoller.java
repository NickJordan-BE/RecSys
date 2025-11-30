package com.example.recsys_orchestrator_service;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import reactor.core.publisher.Mono;

@RestController
public class OrchestratorContoller {
    private final CandidateGenService candidateGenService;
    private final GbdtModelService gbdtModelService;
    private final LtrModelService ltrModelService;

    public OrchestratorContoller(CandidateGenService candidateGenService,
                                 GbdtModelService gbdtModelService,
                                 LtrModelService ltrModelService) {
        this.candidateGenService = candidateGenService;
        this.gbdtModelService = gbdtModelService;
        this.ltrModelService = ltrModelService;
    }

    @GetMapping("/candidates")
    public Mono<String> getCandidateGen() {
        return candidateGenService.candidateGenCall();
    }
    
    @GetMapping("/gbdt")
    public Mono<String> getGbdtCall() {
        return gbdtModelService.gbdtModelCall();
    }

    @GetMapping("/ltr")
    public Mono<String> getLtrCall() {
        return ltrModelService.ltrModelCall();
    }
}
