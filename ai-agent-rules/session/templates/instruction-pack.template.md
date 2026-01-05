# INSTRUCTION PACK — IMPLEMENTATION

## Feature
<module> / <feature>

---

## Fuente de verdad
Este trabajo DEBE alinearse estrictamente con el SPEC referenciado
en `spec_ref.md`.

No se permite reinterpretación ni ampliación del alcance.

---

## Objetivo
Describe exactamente qué debe implementarse.

Ejemplo:
Implementar completamente el caso de uso Create User.

---

## Alcance permitido
El agente SOLO puede crear o modificar archivos dentro de:

- src/modules/<module>/**
- test/modules/<module>/**

---

## Tareas obligatorias
Enumera las tareas en orden estricto.

Ejemplo:
1. Crear la estructura del módulo siguiendo Clean Architecture
2. Implementar la entidad de dominio
3. Implementar el puerto del repositorio
4. Implementar Command y Handler
5. Implementar infraestructura de persistencia
6. Implementar controller y DTOs
7. Implementar tests unitarios con cobertura 100%

---

## Prohibiciones
Enumera explícitamente lo que el agente NO puede hacer.

Ejemplo:
- Modificar el SPEC
- Crear endpoints adicionales
- Cambiar reglas de dominio
- Introducir lógica de negocio en controllers
- Simplificar validaciones

---

## Criterio de éxito
Define cuándo el trabajo se considera completo.

Ejemplo:
- Todos los tests pasan
- Cobertura 100%
- Arquitectura respetada
- No hay archivos modificados fuera del alcance