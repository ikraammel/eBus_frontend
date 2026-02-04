package com.gestion.gestion_bus.repository;

import com.gestion.gestion_bus.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User,Long> {
}
