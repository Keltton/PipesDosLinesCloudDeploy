package com.unialfa.biblioteca.api;

import com.unialfa.biblioteca.model.Autor;
import com.unialfa.biblioteca.service.AutorService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/autores")
public class AutorApi {

    private final AutorService service;

    public AutorApi(AutorService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<Autor>> listar() {
        try {
            var autores = service.listar();
            if (autores.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(autores);
        } catch (Exception e) {
            return ResponseEntity.status(501).build();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<Autor> listar(@PathVariable Long id) {
        var entity = service.listar(id);
        return ResponseEntity.ok(entity);
    }

    @PostMapping
    public ResponseEntity<Autor> cadastrar(@RequestBody Autor autor) {
        var entity = service.salvar(autor);
        return ResponseEntity.ok(entity);
    }

    @PutMapping
    public ResponseEntity<Autor> alterar(@RequestBody Autor autor) {
        var entity = service.salvar(autor);
        return ResponseEntity.ok(entity);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity deletar(@PathVariable Long id) {
        service.remover(id);
        return ResponseEntity.status(204).build();
    }
}
