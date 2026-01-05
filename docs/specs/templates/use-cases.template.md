# SPEC Template - Use Cases

## Casos de Uso Principales

### CU-001: [Nombre del Caso de Uso Principal]
[Breve descripción del propósito y objetivo del caso de uso.]

#### Descripción
[Descripción detallada de lo que el caso de uso logra.]

#### Actores
- **[Actor1]**: [Descripción del rol y responsabilidades]
- **[Actor2]**: [Descripción del rol y responsabilidades]

#### Precondiciones
- [Condición 1 que debe cumplirse antes]
- [Condición 2 que debe cumplirse antes]
- [Recurso necesario disponible]

#### Flujo Principal
```
1. [Recibir/input inicial]
2. [Validar precondiciones]
3. [Ejecutar lógica de negocio principal]
4. [Interactuar con repositorios/servicios]
5. [Procesar resultado]
6. [Retornar respuesta]
```

#### Flujos Alternativos

**A1: [Nombre del Flujo Alternativo 1]**
```
1. [Punto de divergencia del flujo principal]
2. [Condición que activa este flujo]
3. [Manejo específico del caso]
4. [Retorno apropiado]
```

**A2: [Nombre del Flujo Alternativo 2]**
```
1. [Punto de divergencia del flujo principal]
2. [Condición que activa este flujo]
3. [Manejo específico del caso]
4. [Retorno apropiado]
```

#### Postcondiciones
- [Estado del sistema después del éxito]
- [Datos persistidos modificados]
- [Eventos emitidos]

---

### CU-002: [Otro Caso de Uso Principal]
[Repetir la estructura anterior para cada caso de uso principal]

[Continuar con todos los casos de uso principales]

## Casos de Uso de Consulta

### CQ-001: [Nombre de la Consulta]
[Descripción del propósito de la consulta.]

#### Descripción
[Qué información recupera y para qué se usa.]

#### Parámetros de Consulta
- **[Parámetro1]**: [Tipo y descripción]
- **[Parámetro2]**: [Tipo y descripción]

#### Resultado Esperado
[Descripción de la información retornada]

#### Flujo
```
1. Recibir consulta con parámetros
2. Validar parámetros
3. Ejecutar query en repositorio
4. Mapear resultados
5. Retornar respuesta
```

---

## Comandos

### [CommandName]
[Descripción del comando y qué acción dispara.]

```typescript
class [CommandName] {
  constructor(
    public readonly [param1]: [Type1],
    public readonly [param2]: [Type2],
    public readonly [param3]: [Type3]
  ) {}

  // Métodos de validación si son necesarios
  validate(): void {
    // Validaciones específicas del comando
  }
}
```

#### Parámetros
| Parámetro | Tipo | Descripción | Validación |
|-----------|------|-------------|------------|
| [param1] | [Type1] | [Descripción] | [Reglas de validación] |
| [param2] | [Type2] | [Descripción] | [Reglas de validación] |

#### Casos de Uso Asociados
- CU-[Número]: [Nombre del caso de uso]
- CU-[Número]: [Nombre del caso de uso]

[Repetir para cada comando necesario]

## Queries

### [QueryName]
[Descripción de la consulta y qué información obtiene.]

```typescript
class [QueryName] {
  constructor(
    public readonly [param1]: [Type1],
    public readonly [param2]: [Type2]
  ) {}
}
```

#### Parámetros
| Parámetro | Tipo | Descripción | Opcional |
|-----------|------|-------------|-----------|
| [param1] | [Type1] | [Descripción] | [Sí/No] |
| [param2] | [Type2] | [Descripción] | [Sí/No] |

#### Resultado Esperado
[Descripción detallada de lo que retorna la consulta]

[Repetir para cada query necesario]

## Respuestas

### [ResponseName]
[Descripción de la respuesta y cuándo se retorna.]

```typescript
class [ResponseName] {
  constructor(
    public readonly [field1]: [Type1],
    public readonly [field2]: [Type2],
    public readonly [field3]: [Type3],
    public readonly [timestamp]: Date = new Date()
  ) {}

  // Métodos de transformación si son necesarios
  toJSON(): object {
    return {
      [field1]: this.[field1],
      [field2]: this.[field2],
      [field3]: this.[field3],
      timestamp: this.[timestamp]
    }
  }
}
```

#### Campos
| Campo | Tipo | Descripción | Origen |
|-------|------|-------------|--------|
| [field1] | [Type1] | [Descripción] | [Entidad/Dominio] |
| [field2] | [Type2] | [Descripción] | [Cálculo/Transformación] |

[Repetir para cada tipo de respuesta necesario]

## Handlers

### [HandlerName]
[Descripción del handler y su responsabilidad.]

#### Responsabilidades
- [Responsabilidad 1]
- [Responsabilidad 2]
- [Responsabilidad 3]

#### Dependencias
- **[Repository1]**: [Propósito]
- **[DomainService1]**: [Propósito]
- **[EventBus]**: [Propósito]

#### Implementación
```typescript
class [HandlerName] {
  constructor(
    private readonly [repository1]: [Repository1Type],
    private readonly [domainService1]: [DomainService1Type],
    private readonly eventBus: EventBus
  ) {}

  async handle(command: [CommandType]): Promise<[ResponseType]> {
    // 1. Validar comando
    [validations]

    // 2. Verificar precondiciones
    [preconditionChecks]

    // 3. Ejecutar lógica de dominio
    const [domainObject] = await this.[domainMethod](command)

    // 4. Persistir cambios
    await this.[repository1].[method]([domainObject])

    // 5. Publicar eventos
    await this.eventBus.publish(new [DomainEvent](domainObject))

    // 6. Construir y retornar respuesta
    return new [ResponseType]([responseFields])
  }

  private async [domainMethod](command: [CommandType]): Promise<[DomainType]> {
    // Lógica de negocio específica
  }
}
```

#### Manejo de Errores
```typescript
// Errores específicos que el handler maneja
try {
  const result = await this.handle(command)
  return result
} catch (error) {
  if (error instanceof [SpecificDomainError]) {
    throw new [ApplicationError]('[Mensaje amigable]')
  }
  throw error
}
```

#### Logs y Tracing
```typescript
// Logging obligatorio según TESTING_RULES
constructor(
  // ... otras dependencias
  private readonly logger: Logger
) {}

async handle(command: [CommandType]): Promise<[ResponseType]> {
  this.logger.log(`Iniciando [operation]`, { command: command.[field1] })
  
  try {
    const result = await this.[executeMethod](command)
    this.logger.log(`[operation] completada exitosamente`, { 
      [resultField]: result.[field] 
    })
    return result
  } catch (error) {
    this.logger.error(`Error en [operation]`, { 
      error: error.message,
      command: command 
    })
    throw error
  }
}
```

[Repetir para cada handler necesario]

## Validaciones

### Validaciones de Input
```typescript
class [Command]Validator {
  static validate(command: [CommandType]): void {
    // Validación de campos requeridos
    if (!command.[field]) {
      throw new ValidationError('[field] es requerido')
    }

    // Validación de formato
    if (!this.isValid[Field](command.[field])) {
      throw new ValidationError('[field] tiene formato inválido')
    }

    // Validaciones de negocio
    if (!this.meetsBusinessRule(command.[field])) {
      throw new ValidationError('[field] no cumple regla de negocio')
    }
  }

  private static isValid[Field](value: string): boolean {
    // Lógica de validación de formato
    return [regex].test(value)
  }

  private static meetsBusinessRule(value: string): boolean {
    // Lógica de validación de negocio
    return [condition]
  }
}
```

---

**Estos casos de uso definen el comportamiento, interacciones y flujos del sistema [Module].**