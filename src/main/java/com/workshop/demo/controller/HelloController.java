package com.workshop.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@RestController
public class HelloController {

    @GetMapping("/")
    public Map<String, Object> home() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "GitHub Actions Workshop - Java Spring Boot Demo");
        response.put("status", "running");
        response.put("timestamp", LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
        response.put("version", "1.0.0");
        response.put("endpoints", new String[]{
            "GET / - Diese Nachricht",
            "GET /hello - Einfache Begrüßung",
            "GET /hello/{name} - Personalisierte Begrüßung",
            "GET /actuator/health - Health Check"
        });
        return response;
    }

    @GetMapping("/hello")
    public Map<String, String> hello() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello from Spring Boot!");
        response.put("deployed_via", "GitHub Actions + Terraform");
        return response;
    }

    @GetMapping("/hello/{name}")
    public Map<String, String> helloName(@PathVariable String name) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello, " + name + "!");
        response.put("greeting", "Welcome to the GitHub Actions Workshop!");
        return response;
    }
}
