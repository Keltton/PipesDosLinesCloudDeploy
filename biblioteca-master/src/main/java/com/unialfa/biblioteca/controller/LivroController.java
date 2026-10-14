package com.unialfa.biblioteca.controller;

import com.unialfa.biblioteca.model.Livro;
import com.unialfa.biblioteca.service.AutorService;
import com.unialfa.biblioteca.service.LivroService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("livros")
public class LivroController {

    @Autowired
    private LivroService service;

    @Autowired
    private AutorService autorService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("livros", service.listar());
        return "livro/list";
    }

    @GetMapping("/{id}")
    public String listar(@PathVariable Long id, Model model) {
        model.addAttribute("livro", service.listar(id));
        model.addAttribute("autores", autorService.listar());
        return "livro/form";
    }

    @GetMapping("/new")
    public String abrirform(Livro livro, Model model) {
        model.addAttribute("autores", autorService.listar());
        return "livro/form";
    }

    @PostMapping("/salvar")
    public String salvar(Livro livro, Model model) {
        service.salvar(livro);
        return "redirect:/livros";
    }

    @GetMapping("/remover/{id}")
    public String remover(@PathVariable Long id, Model model) {
        service.remover(id);
        return "redirect:/livros";
    }
}
