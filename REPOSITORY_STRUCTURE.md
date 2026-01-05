# Estructura del Repositorio - Spec-Driven Development

## Directorio Raíz

```
project-root/
├── README.md                           # Visión general del proyecto
├── SPEC_DRIVEN_DEVELOPMENT.md          # Marco teórico y metodología
├── AGENTS.md                           # Reglas para agentes de IA
├── .gitignore
├── package.json
├── tsconfig.json
├── jest.config.js
├── .eslintrc.js
├── .prettierrc
│
├── docs/                               # Documentación del proyecto
│   ├── README.md                       # Índice de documentación
│   ├── specs/                          # SPECs del proyecto
│   │   ├── README.md                   # Guía de SPECs
│   │   ├── templates/                  # Templates de SPECs
│   │   │   ├── feature.template.md
│   │   │   ├── domain.template.md
│   │   │   ├── use-cases.template.md
│   │   │   ├── architecture.template.md
│   │   │   ├── persistence.template.md
│   │   │   └── testing.template.md
│   │   └── <module>/
│   │       └── <feature>/
│   │           ├── README.md           # Visión general
│   │           ├── domain.md            # Modelo de dominio
│   │           ├── use-cases.md         # Casos de uso
│   │           ├── architecture.md     # Arquitectura
│   │           ├── persistence.md       # Persistencia
│   │           └── testing.md           # Pruebas
│   │
│   ├── guides/                         # Guías de desarrollo
│   │   ├── getting-started.md
│   │   ├── spec-creation.md
│   │   ├── session-management.md
│   │   └── troubleshooting.md
│   │
│   └── examples/                       # Ejemplos de referencia
│       ├── user-management/
│       └── order-processing/
│
├── ai-agent-rules/                     # Reglas y configuración de agentes
│   ├── README.md                       # Descripción del sistema
│   ├── backend/                        # Reglas para backend
│   │   ├── AGENT_BASE.md
│   │   ├── ARCHITECTURE_RULES.md
│   │   ├── TESTING_RULES.md
│   │   ├── LANGUAGE_RULES.md
│   │   ├── RESPONSE_CONSTRAINTS.md
│   │   └── EXPLORATION_RULES.md
│   │
│   ├── agents/                         # Definiciones de agentes
│   │   ├── spec-agent.md               # Agente para crear SPECs
│   │   ├── implementation-agent.md     # Agente para implementar
│   │   ├── testing-agent.md            # Agente para pruebas
│   │   └── review-agent.md             # Agente para revisión
│   │
│   └── sessions/                       # Sistema de sesiones
│       ├── README.md                   # Guía de sesiones
│       ├── templates/                  # Templates de sesiones
│       │   ├── session_state.template.md
│       │   ├── spec_ref.template.md
│       │   ├── instruction-pack.template.md
│       │   ├── notes.template.md
│       │   └── status.template.md
│       │
│       └── <module>/
│           └── <feature>/
│               ├── session_state.md
│               ├── spec_ref.md
│               ├── instruction-pack.md
│               ├── notes.md
│               └── status.md
│
├── src/                                # Código fuente
│   ├── main.ts                         # Punto de entrada
│   ├── app.module.ts                   # Módulo principal
│   │
│   ├── shared/                         # Componentes compartidos
│   │   ├── domain/
│   │   ├── application/
│   │   ├── infrastructure/
│   │   └── presentation/
│   │
│   └── modules/                        # Módulos de negocio
│       └── <module>/
│           ├── domain/
│           │   ├── entities/
│           │   ├── value-objects/
│           │   ├── repositories/
│           │   └── services/
│           │
│           ├── application/
│           │   ├── commands/
│           │   ├── queries/
│           │   ├── handlers/
│           │   └── dto/
│           │
│           ├── infrastructure/
│           │   ├── persistence/
│           │   ├── external/
│           │   └── config/
│           │
│           └── presentation/
│               ├── controllers/
│               └── middleware/
│
├── test/                               # Pruebas
│   ├── shared/                         # Utilidades de prueba
│   │   ├── mocks/
│   │   ├── helpers/
│   │   └── factories/
│   │
│   └── modules/                        # Pruebas por módulo
│       └── <module>/
│           ├── domain/
│           ├── application/
│           ├── infrastructure/
│           └── presentation/
│
├── scripts/                            # Scripts de automatización
│   ├── create-spec.sh                  # Script para crear SPEC
│   ├── create-session.sh               # Script para crear sesión
│   ├── validate-architecture.sh        # Validación de arquitectura
│   └── run-tests.sh                    # Ejecución de pruebas
│
└── tools/                              # Herramientas de desarrollo
    ├── spec-validator/                 # Validador de SPECs
    ├── session-manager/                # Gestor de sesiones
    └── architecture-checker/            # Verificador de arquitectura
```

## Flujo de Trabajo Estándar

### 1. Creación de SPEC
```
docs/specs/templates/ → docs/specs/<module>/<feature>/
```

### 2. Creación de Sesión
```
ai-agent-rules/sessions/templates/ → ai-agent-rules/sessions/<module>/<feature>/
```

### 3. Implementación
```
ai-agent-rules/sessions/<module>/<feature>/ → src/modules/<module>/
```

### 4. Pruebas
```
src/modules/<module>/ → test/modules/<module>/
```

## Reglas de Estructura

### 1. Inmutabilidad
- Los SPECs no se modifican durante la ejecución
- Las sesiones son únicas y no se reutilizan
- Los templates solo se copian, nunca se editan

### 2. Consistencia
- Todos los módulos siguen la misma estructura
- Todos los SPECs siguen el mismo formato
- Todas las sesiones usan los mismos templates

### 3. Trazabilidad
- Cada implementación referencia su SPEC
- Cada prueba referencia su implementación
- Cada sesión tiene un objetivo claro

### 4. Calidad
- 100% cobertura de pruebas
- Cumplimiento de reglas de arquitectura
- Validación automática de estructura

## Herramientas de Soporte

### 1. Scripts de Automatización
- **create-spec.sh**: Crea estructura de SPEC desde template
- **create-session.sh**: Crea sesión desde template
- **validate-architecture.sh**: Verifica cumplimiento de reglas

### 2. Validadores
- **spec-validator**: Verifica completitud de SPECs
- **session-manager**: Gestiona ciclo de vida de sesiones
- **architecture-checker**: Verifica estructura de código

### 3. Agentes Especializados
- **spec-agent**: Ayuda a crear SPECs completos
- **implementation-agent**: Ejecuta implementación controlada
- **testing-agent**: Crea pruebas con cobertura 100%
- **review-agent**: Revisa y valida resultados

Esta estructura garantiza que el desarrollo sea predecible, auditable y escalable.