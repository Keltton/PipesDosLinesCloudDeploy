package com.unialfa.biblioteca.controller;

import com.unialfa.biblioteca.model.Autor;
import com.unialfa.biblioteca.service.AutorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("autores")
public class AutorController {

    @Autowired
    private AutorService service;

    @GetMapping
    public String listar(Model model){
        model.addAttribute("autores",service.listar());
        return "autor/list";
    }

    @GetMapping("/{id}")
    public String listar(@PathVariable Long id, Model model){
        model.addAttribute("autor",service.listar(id));
        return "autor/form";
    }

    @GetMapping("/new")
    public String abrirform(Autor autor, Model model) {
        return "autor/form";
    }

    @PostMapping("/salvar")
    public String salvar(Autor autor, Model model) {
        service.salvar(autor);
        return "redirect:/autores";
    }

    @GetMapping("/remover/{id}")
    public String remover(@PathVariable Long id, Model model){
        service.remover(id);
        return "redirect:/autores";
    }

}
