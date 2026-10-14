package com.unialfa.biblioteca;

import com.unialfa.biblioteca.model.Usuario;
import com.unialfa.biblioteca.repository.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.Arrays;

@SpringBootApplication
public class BibliotecaApplication {

	public static void main(String[] args) {
		SpringApplication.run(BibliotecaApplication.class, args);
	}


	@Bean
	public CommandLineRunner initDataBase(UsuarioRepository usuarioRepository) {
		return args -> {


			usuarioRepository.save(new Usuario(null, "admin", new BCryptPasswordEncoder().encode("admin"), "Admin", "ADMIN"));
			usuarioRepository.save(new Usuario(null, "user", new BCryptPasswordEncoder().encode("user"), "user", "USER"));
		};
	}
}
