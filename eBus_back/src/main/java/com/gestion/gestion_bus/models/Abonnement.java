package com.gestion.gestion_bus.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Abonnement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String type; // mensuel, hebdomadaire
    private double prix;
    private LocalDate dateDebut;
    private LocalDate dateFin;

    @ManyToOne
    private User user;

    @OneToOne(mappedBy = "abonnement")
    private Payment payment;
}
