package com.unialfa.biblioteca;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Abre um Pull Request. O pipeline deve parar no job 2, não gerar o JAR e não construir nem publicar a imagem.
 *
 * NÃO fazer merge desta branch.
 */
class FalhaPropositalTest {

    @Test
    void prazoDeEmprestimoDeveSerSeteDias() {
        int prazoCalculado = 10; // simula regressão no cálculo de empréstimo
        assertEquals(7, prazoCalculado, "Prazo de empréstimo divergente do requisito");
    }
}
