# INSTRUCTION PACK – IMPLEMENTATION
Feature: Users / Create User

---

## Fuente de verdad
Este trabajo DEBE alinearse estrictamente con el SPEC referenciado
en `spec_ref.md`.

No se permite reinterpretación ni ampliación del alcance.

---

## Objetivo
Implementar completamente el caso de uso Create User.

---

## Alcance permitido
- src/modules/users/**
- test/modules/users/**

---

## Tareas obligatorias (orden estricto)

1. Crear la estructura del módulo users siguiendo Clean Architecture
2. Implementar la entidad de dominio User
3. Implementar el puerto UserRepository
4. Implementar CreateUserCommand
5. Implementar CreateUserHandler
6. Implementar repositorio con TypeORM
7. Implementar DTO y Controller HTTP
8. Implementar tests unitarios con cobertura 100%
9. Validar logs y errores según TESTING_RULES

---

## Prohibiciones
- Modificar el SPEC
- Crear endpoints adicionales
- Introducir lógica de negocio en controllers
- Simplificar reglas de dominio
- Cambiar nombres definidos en el SPEC

---

## Criterio de éxito
- Todos los tests pasan
- Cobertura 100%
- Arquitectura respetada
- Ningún archivo fuera del alcance fue modificado
