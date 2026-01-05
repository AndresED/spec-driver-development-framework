# Guía Paso a Paso - Spec-Driven Development con Agentes de IA

## Introducción

Esta guía te llevará a través del proceso completo de implementación de Spec-Driven Development (SDD) asistido por Agentes de IA, desde la creación del SPEC hasta la implementación final.

## Requisitos Previos

### Conocimientos Necesarios
- Clean Architecture y Hexagonal Architecture
- NestJS y TypeScript
- Patrones CQRS y Domain-Driven Design
- Testing con Jest (100% cobertura)

### Herramientas Requeridas
- Node.js 18+
- NestJS CLI
- TypeORM y PostgreSQL
- Agente de IA (configurado con reglas)

---

## Paso 1: Creación del SPEC

### 1.1 Definir el Alcance
Antes de escribir el SPEC, responde:

```
¿Qué problema resuelve esta feature?
¿Quiénes son los usuarios?
¿Cuáles son los casos de uso principales?
¿Qué restricciones de negocio existen?
```

### 1.2 Crear Estructura del SPEC
```bash
# Copiar template
cp docs/specs/templates/feature.template.md docs/specs/<module>/<feature>/README.md
cp docs/specs/templates/domain.template.md docs/specs/<module>/<feature>/domain.md
cp docs/specs/templates/use-cases.template.md docs/specs/<module>/<feature>/use-cases.md
cp docs/specs/templates/architecture.template.md docs/specs/<module>/<feature>/architecture.md
cp docs/specs/templates/persistence.template.md docs/specs/<module>/<feature>/persistence.md
cp docs/specs/templates/testing.template.md docs/specs/<module>/<feature>/testing.md
```

### 1.3 Completar README.md
Define la visión general y requisitos:

```markdown
# <Module> - <Feature>

## Visión General
[Breve descripción del problema y solución]

## Requisitos Funcionales
### RF-001: [Nombre del requisito]
[Descripción detallada]

## Requisitos No Funcionales
### RNF-001: [Nombre del requisito]
[Descripción detallada]

## Casos de Uso
### UC-001: [Nombre del caso de uso]
[Flujo completo del caso de uso]
```

### 1.4 Definir Modelo de Dominio (domain.md)
```markdown
# Modelo de Dominio

## Entidades
### [NombreEntidad]
[Definición completa con atributos y reglas]

## Objetos de Valor
### [NombreVO]
[Definición con validaciones]

## Reglas de Dominio
### RN-001: [Nombre de regla]
[Descripción de la regla]
```

### 1.5 Especificar Casos de Uso (use-cases.md)
```markdown
# Casos de Uso

## CU-001: [Nombre]
### Descripción
### Actores
### Precondiciones
### Flujo Principal
### Flujos Alternativos
### Postcondiciones

## Comandos y Queries
### [NombreCommand]
[Definición completa]

## Handlers
### [NombreHandler]
[Lógica del handler]
```

### 1.6 Definir Arquitectura (architecture.md)
```markdown
# Arquitectura

## Estilo Arquitectónico
[Clean + Hexagonal + CQRS]

## Estructura de Capas
[Diagrama de carpetas y archivos]

## Componentes Clave
[Entidades, repositorios, casos de uso]

## Flujo de Datos
[Diagrama de flujo]
```

### 1.7 Especificar Persistencia (persistence.md)
```markdown
# Estrategia de Persistencia

## Tecnología
[Base de datos, ORM]

## Diseño de Tablas
[SQL completo]

## Entidades ORM
[TypeORM entities]

## Mappers
[Domain ↔ Infrastructure]
```

### 1.8 Definir Estrategia de Pruebas (testing.md)
```markdown
# Estrategia de Pruebas

## Filosofía
[100% coverage]

## Tipos de Pruebas
[Unit, Integration, E2E]

## Test Utilities
[Factories, Helpers]
```

---

## Paso 2: Validación del SPEC

### 2.1 Revisión Interna
Antes de continuar, verifica que el SPEC:

- ✅ Es completo y no ambiguo
- ✅ Define todos los casos de uso
- ✅ Especifica todas las reglas de negocio
- ✅ Define la arquitectura claramente
- ✅ Incluye estrategia de pruebas

### 2.2 Revisión con Stakeholders
Presenta el SPEC a:

- Product Owner (validar requisitos)
- Arquitecto (validar diseño)
- Desarrollador Senior (validar viabilidad)

### 2.3 Aprobación Final
El SPEC está **CERRADO** cuando:

- Todos los stakeholders están de acuerdo
- No hay ambigüedades
- El alcance está claramente definido
- Los casos de uso están completos

---

## Paso 3: Creación de la Sesión

### 3.1 Crear Directorio de Sesión
```bash
mkdir -p ai-agent-rules/sessions/<module>/<feature>
```

### 3.2 Copiar Templates
```bash
cp ai-agent-rules/sessions/templates/session_state.template.md ai-agent-rules/sessions/<module>/<feature>/session_state.md
cp ai-agent-rules/sessions/templates/spec_ref.template.md ai-agent-rules/sessions/<module>/<feature>/spec_ref.md
cp ai-agent-rules/sessions/templates/instruction-pack.template.md ai-agent-rules/sessions/<module>/<feature>/instruction-pack.md
cp ai-agent-rules/sessions/templates/notes.template.md ai-agent-rules/sessions/<module>/<feature>/notes.md
cp ai-agent-rules/sessions/templates/status.template.md ai-agent-rules/sessions/<module>/<feature>/status.md
```

### 3.3 Completar session_state.md
```markdown
# SESSION STATE

## Objetivo
Implementar completamente <module>/<feature> según SPEC

## Alcance
- src/modules/<module>/**
- test/modules/<module>/**

## Reglas Activas
- ARCHITECTURE_RULES.md
- TESTING_RULES.md
- LANGUAGE_RULES.md
- RESPONSE_CONSTRAINTS.md

## Prohibiciones
- Modificar el SPEC
- Crear archivos fuera del alcance
- Simplificar validaciones
- Introducir lógica en controllers

## Fase Actual
IMPLEMENTATION

## Criterio de Éxito
- 100% cobertura de pruebas
- Arquitectura respetada
- Todos los tests pasan
- Ningún archivo fuera del alcance modificado
```

### 3.4 Completar spec_ref.md
```markdown
# SPEC REFERENCE

Esta sesión se rige EXCLUSIVAMENTE por el siguiente SPEC:

- docs/specs/<module>/<feature>/README.md
- docs/specs/<module>/<feature>/domain.md
- docs/specs/<module>/<feature>/use-cases.md
- docs/specs/<module>/<feature>/architecture.md
- docs/specs/<module>/<feature>/persistence.md
- docs/specs/<module>/<feature>/testing.md

Cualquier desviación invalida esta sesión.
```

### 3.5 Completar instruction-pack.md
```markdown
# INSTRUCTION PACK

## Feature
<module> / <feature>

## Objetivo
Implementar completamente <feature> según SPEC

## Alcance Permitido
- src/modules/<module>/**
- test/modules/<module>/**

## Tareas Obligatorias (Orden Estricto)
1. Crear estructura del módulo siguiendo Clean Architecture
2. Implementar entidades de dominio
3. Implementar objetos de valor
4. Implementar puertos de repositorio
5. Implementar comandos y queries
6. Implementar handlers
7. Implementar infraestructura de persistencia
8. Implementar controllers y DTOs
9. Implementar tests unitarios con 100% cobertura
10. Validar arquitectura y reglas

## Prohibiciones
- Modificar el SPEC
- Crear endpoints adicionales
- Introducir lógica de negocio en controllers
- Simplificar validaciones del dominio
- Cambiar nombres definidos en el SPEC

## Criterio de Éxito
- Todos los tests pasan
- 100% cobertura
- Arquitectura respetada
- Ningún archivo fuera del alcance modificado
- Logs y errores validados según TESTING_RULES
```

---

## Paso 4: Ejecución con Agente de IA

### 4.1 Preparar el Agente
Asegúrate que el agente tenga:

- ✅ Reglas cargadas (AGENT_BASE.md, ARCHITECTURE_RULES.md, etc.)
- ✅ Contexto del proyecto
- ✅ Acceso a los archivos de la sesión

### 4.2 Invocar al Agente
```bash
# Usar el instruction-pack como input
cat ai-agent-rules/sessions/<module>/<feature>/instruction-pack.md | agente-ia
```

### 4.3 Monitorear la Ejecución
Durante la ejecución, verifica:

- ✅ El agente sigue el orden de tareas
- ✅ Respeta las prohibiciones
- ✅ Crea tests con 100% cobertura
- ✅ Mantiene la arquitectura

### 4.4 Validación Continua
Ejecuta validaciones periódicas:

```bash
# Validar arquitectura
npm run validate:architecture

# Validar cobertura
npm run test:coverage

# Validar linting
npm run lint
```

---

## Paso 5: Revisión y Validación

### 5.1 Revisión de Código
Verifica que el código generado:

- ✅ Sigue Clean Architecture
- ✅ Implementa todos los casos de uso
- ✅ Tiene 100% cobertura de pruebas
- ✅ Respeta las reglas de negocio

### 5.2 Ejecución de Pruebas
```bash
# Ejecutar todas las pruebas
npm run test

# Verificar cobertura
npm run test:coverage

# Ejecutar pruebas de integración
npm run test:integration

# Ejecutar pruebas E2E
npm run test:e2e
```

### 5.3 Validación de Arquitectura
```bash
# Validar estructura de carpetas
npm run validate:structure

# Validar dependencias
npm run validate:dependencies

# Validar reglas de negocio
npm run validate:domain
```

---

## Paso 6: Cierre de la Sesión

### 6.1 Actualizar status.md
```markdown
# STATUS

## Estado
CLOSED

## Fecha de Cierre
[Fecha actual]

## Resultados
- ✅ Implementación completada
- ✅ 100% cobertura de pruebas
- ✅ Arquitectura respetada
- ✅ Todos los tests pasan

## Archivos Creados/Modificados
[Listar todos los archivos]

## Próximos Pasos
- Deploy a staging
- Pruebas de aceptación
- Documentación de API
```

### 6.2 Actualizar notes.md
```markdown
# NOTES

## Observaciones
[Notas sobre el proceso]

## Lecciones Aprendidas
[Qué funcionó bien, qué mejorar]

## Problemas Encontrados
[Problemas y soluciones]

## Recomendaciones
[Mejoras para futuras sesiones]
```

### 6.3 Archivar la Sesión
```bash
# Mover a archivo
mv ai-agent-rules/sessions/<module>/<feature> ai-agent-rules/sessions/archive/<module>/<feature>-$(date +%Y%m%d)
```

---

## Paso 7: Integración y Deploy

### 7.1 Integración Continua
```bash
# Ejecutar pipeline completo
npm run ci:build
npm run ci:test
npm run ci:lint
npm run ci:security
```

### 7.2 Deploy a Staging
```bash
# Deploy a ambiente de staging
npm run deploy:staging
```

### 7.3 Pruebas de Aceptación
- ✅ Pruebas manuales en staging
- ✅ Validación con stakeholders
- ✅ Pruebas de performance
- ✅ Pruebas de seguridad

### 7.4 Deploy a Producción
```bash
# Deploy a producción
npm run deploy:production
```

---

## Troubleshooting

### Problemas Comunes

#### 1. El Agente se Desvía del SPEC
**Solución**: Detener la sesión y crear una nueva con instruction-pack más específico.

#### 2. Cobertura de Pruebas < 100%
**Solución**: Revisar TESTING_RULES.md y asegurar que el agente siga todas las reglas.

#### 3. Arquitectura Incorrecta
**Solución**: Validar ARCHITECTURE_RULES.md y reforzar las reglas en el instruction-pack.

#### 4. Tests Fallando
**Solución**: Revisar los mocks y asegurar que sigan los patrones definidos.

### Herramientas de Debug

#### 1. Validador de SPEC
```bash
npm run validate:spec <module>/<feature>
```

#### 2. Verificador de Sesión
```bash
npm run validate:session <module>/<feature>
```

#### 3. Analizador de Cobertura
```bash
npm run analyze:coverage <module>
```

---

## Mejores Prácticas

### 1. SPECs de Calidad
- Ser específico y no ambiguo
- Incluir todos los casos de uso
- Definir todas las reglas de negocio
- Especificar la arquitectura completa

### 2. Sesiones Bien Definidas
- Objetivo claro y medible
- Alcance bien delimitado
- Prohibiciones explícitas
- Criterios de éxito específicos

### 3. Comunicación Efectiva
- Revisar SPECs con stakeholders
- Documentar decisiones importantes
- Compartir lecciones aprendidas

### 4. Mejora Continua
- Analizar métricas de éxito
- Identificar patrones de falla
- Optimizar templates y reglas

---

## Métricas de Éxito

### Calidad
- ✅ 100% cobertura de pruebas
- ✅ Cero bugs en producción
- ✅ Arquitectura respetada

### Eficiencia
- ✅ Tiempo de SPEC a producción predecible
- ✅ < 5% de retrabajo
- ✅ Alta autonomía del equipo

### Gobernanza
- ✅ 100% de trazabilidad
- ✅ Auditoría completa
- ✅ Cumplimiento normativo

---

**Siguiendo esta guía, podrás implementar Spec-Driven Development con Agentes de IA de manera consistente, predecible y escalable.**