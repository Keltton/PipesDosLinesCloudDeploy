package com.unialfa.biblioteca.controller;

import com.unialfa.biblioteca.model.Usuario;
import com.unialfa.biblioteca.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService service;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("usuarios", service.listar());
        return "usuario/list";
    }

    @GetMapping("/{id}")
    public String listar(@PathVariable Long id, Model model) {
        model.addAttribute("usuario", service.listar(id));
        return "usuario/form";
    }

    @GetMapping("/new")
    public String abrirform(Usuario usuario, Model model) {
        return "usuario/form";
    }

    @PostMapping("/salvar")
    public String salvar(Usuario usuario, Model model) {
        service.salvar(usuario);
        return "redirect:/usuarios";
    }

    @GetMapping("/remover/{id}")
    public String remover(@PathVariable Long id, Model model) {
        service.remover(id);
        return "redirect:/usuarios";
    }
}
