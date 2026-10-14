package com.unialfa.biblioteca.service;

import com.unialfa.biblioteca.model.Autor;
import com.unialfa.biblioteca.repository.AutorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AutorService {

    @Autowired
    private AutorRepository repository;

    public Autor salvar(Autor autor){
        return repository.save(autor);
    }

    public Autor listar(Long id){
        return repository.findById(id).get();
    }

    public List<Autor> listar(){
        return repository.findAll();
    }

    public void remover(Long id){
        repository.deleteById(id);
    }
}
