# Session State

## Objetivo
Describe de forma clara y concreta el objetivo único de esta sesión.

Ejemplo:
Implementar el caso de uso Create User según el SPEC aprobado.

---

## Alcance permitido
El agente SOLO puede crear o modificar archivos dentro de:

- src/modules/<module>/**
- test/modules/<module>/**

Cualquier archivo fuera de este alcance está estrictamente prohibido.

---

## Prohibiciones
Enumera explícitamente lo que NO está permitido.

Ejemplos:
- Modificar el SPEC
- Crear nuevos casos de uso
- Cambiar reglas de dominio
- Refactorizar otros módulos
- Introducir integraciones externas

---

## Reglas activas
Lista explícita de reglas que gobiernan esta sesión.

Ejemplo:
- agent_base
- language_rules
- response_constraints
- arch_rules
- testing_rules

---

## Fase actual
Indica la fase del workflow en la que se encuentra la sesión.

Valores típicos:
- Analysis
- Implementation
- Validation
- Closed

---

## Responsable humano
Nombre de la persona responsable de la sesión.

---

## Fecha de inicio
YYYY-MM-DD
