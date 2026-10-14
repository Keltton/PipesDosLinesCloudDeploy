package com.unialfa.biblioteca;

import static org.junit.jupiter.api.Assertions.assertFalse;

import org.junit.jupiter.api.Test;

/**
 * Teste usado como evidência do T5: só falha quando o pipeline é executado
 * com -Dsimular.falha=true (checkbox "simular_falha" no "Run workflow").
 * Em execuções normais ele passa.
 */
class PipelineFalhaSimuladaTest {

	@Test
	void falhaSomenteQuandoSolicitada() {
		assertFalse(Boolean.getBoolean("simular.falha"),
				"Falha proposital solicitada para evidência do T5 (simular.falha=true)");
	}
}
