package com.unialfa.biblioteca.service;

import com.unialfa.biblioteca.model.Livro;
import com.unialfa.biblioteca.repository.LivroRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LivroService {

    @Autowired
    private LivroRepository repository;

    public Livro salvar(Livro livro){
        return repository.save(livro);
    }

    public Livro listar(Long id){
        return repository.findById(id).get();
    }

    public List<Livro> listar(){
        return repository.findAll();
    }

    public void remover(Long id){
        repository.deleteById(id);
    }

}
