# Sessions – Gobierno de Ejecución con IA

Este directorio contiene el **sistema de sesiones**, el mecanismo central
para controlar cómo se ejecuta trabajo asistido por IA dentro del proyecto.

Las sesiones existen para garantizar:
- Control de alcance
- Trazabilidad
- Repetibilidad
- Disciplina arquitectónica
- Uso seguro de agentes

---

## ¿Qué es una sesión?

Una sesión es una **unidad de trabajo cerrada**, creada a partir de un
**SPEC previamente aprobado**.

Una sesión:
- Tiene un objetivo único
- Tiene reglas explícitas
- Tiene un alcance controlado
- Produce resultados verificables

Una sesión **NO es**:
- Un chat
- Un backlog
- Un lugar para experimentar
- Un espacio para improvisar

---

## Principio fundamental

> **Las sesiones no toman decisiones.  
Ejecutan decisiones ya tomadas.**

Si algo requiere decidir, **no pertenece a una sesión**.

---

├── README.md
├── _templates/
│ ├── session_state.template.md
│ ├── spec_ref.template.md
│ ├── instruction-pack.template.md
│ ├── notes.template.md
│ └── status.template.md
└── <module>/
└── <feature>/
├── session_state.md
├── spec_ref.md
├── instruction-pack.md
├── notes.md
└── status.md


---

## Rol de cada carpeta

### `_templates/`
Contiene las **plantillas oficiales** para crear nuevas sesiones.

- No se editan por sesión
- Se copian y completan
- Garantizan consistencia

### `<module>/<feature>/`
Representa una **sesión concreta**, asociada a:
- Un módulo
- Un feature
- Un SPEC cerrado

Ejemplo:


## Archivos de una sesión

### `session_state.md`
Gobierna la sesión:
- Objetivo
- Alcance
- Prohibiciones
- Reglas activas
- Fase actual

> Si algo no está permitido aquí, no está permitido en absoluto.

---

### `spec_ref.md`
Define la **fuente de verdad**:
- Referencia explícita al SPEC
- Evita duplicación
- Evita ambigüedad

---

### `instruction-pack.md`
Es el **único input permitido para el agente ejecutor**.

Contiene:
- Qué hacer
- Qué no hacer
- Dónde hacerlo
- Cuándo detenerse

> Nada de prompts largos.  
> Órdenes claras y cerradas.

---

### `notes.md`
Archivo libre para observaciones humanas.

- No afecta la ejecución
- No modifica reglas ni alcance

---

### `status.md`
Define el **estado final de la sesión**.

- OPEN
- CLOSED

Una sesión cerrada **no se reabre**.

---

## Ciclo de vida de una sesión


SPEC cerrado
↓
Crear sesión desde templates
↓
Completar session_state.md
↓
Redactar instruction-pack.md
↓
Ejecutar agente
↓
Validar resultados
↓
Cerrar sesión

No hay atajos.

---

## Reglas duras del sistema de sesiones

- Una sesión = un objetivo
- El SPEC no cambia durante la sesión
- La IA no crea ni cierra sesiones
- Las sesiones no se versionan
- Las sesiones no se reutilizan

---

## Señales de mal uso del sistema

Si detectas frases como:
- “Ya que estamos…”
- “Aprovechemos esta sesión para…”
- “Luego ajustamos el SPEC…”

Detente.  
El sistema se está rompiendo.

---

## Relación con otros componentes

| Componente | Rol |
|----------|----|
| SPEC | Fuente de verdad |
| Rules | Límites globales |
| Workflows | Orden del proceso |
| Sessions | Control de ejecución |
| Agents | Ejecución disciplinada |

---

## Objetivo final del sistema

> **Convertir el uso de IA en un proceso confiable, auditable y escalable.**

Las sesiones son el mecanismo que hace esto posible.

---

## Recomendación final

Antes de crear una sesión:
1. Asegúrate de que el SPEC esté cerrado
2. Revisa el workflow correspondiente
3. Copia las templates
4. Completa todos los archivos

Si no puedes explicar una sesión leyendo solo sus archivos,
la sesión está mal definida.


