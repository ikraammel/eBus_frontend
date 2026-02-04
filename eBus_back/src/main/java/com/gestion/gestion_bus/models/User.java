package com.gestion.gestion_bus.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;

import java.util.List;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nom;
    @NonNull
    @Column(unique = true)
    private String email;

    @NonNull
    private String password;

    @ManyToOne
    @JoinColumn(name = "role_id")
    private Role role;

    @OneToMany
    private List<Ticket> tickets;

    @OneToMany
    private List<Abonnement> abonnements;

    @OneToMany
    private List<Reclamation> reclamations;

    @OneToMany
    private List<ObjetPerdu> objetsPerdus;
}
