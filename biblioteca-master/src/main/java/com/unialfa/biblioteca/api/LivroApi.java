package com.unialfa.biblioteca.api;

import com.unialfa.biblioteca.model.Livro;
import com.unialfa.biblioteca.service.LivroService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/livros")
public class LivroApi {

    private final LivroService service;

    public LivroApi(LivroService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<Livro>> listar() {
        try {
            var livros = service.listar();
            if (livros.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(livros);
        } catch (Exception e) {
            return ResponseEntity.status(501).build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Livro> listar(@PathVariable Long id) {
        var entity = service.listar(id);
        return ResponseEntity.ok(entity);
    }

    @PostMapping
    public ResponseEntity<Livro> cadastrar(@RequestBody Livro livro) {
        var entity = service.salvar(livro);
        return ResponseEntity.ok(entity);
    }

    @PutMapping
    public ResponseEntity<Livro> alterar(@RequestBody Livro livro) {
        var entity = service.salvar(livro);
        return ResponseEntity.ok(entity);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity deletar(@PathVariable Long id) {
        service.remover(id);
        return ResponseEntity.status(204).build();
    }
}
