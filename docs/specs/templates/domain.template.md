# SPEC Template - Domain Model

## Entidades

### [NombreEntidad]
[Descripción de la entidad principal y su propósito en el dominio.]

```typescript
class [NombreEntidad] {
  [atributo1]: [Tipo]
  [atributo2]: [Tipo]
  [atributo3]: [Tipo]
  // ... otros atributos
}
```

#### Atributos

| Atributo | Tipo | Descripción | Reglas |
|----------|------|-------------|--------|
| [nombre] | [tipo] | [descripción del atributo] | [reglas de validación y restricciones] |
| [nombre] | [tipo] | [descripción del atributo] | [reglas de validación y restricciones] |

#### Comportamiento
```typescript
class [NombreEntidad] {
  // Constructor
  constructor(params: [ConstructorParams]) {
    // Validaciones y asignaciones
  }

  // Métodos de negocio
  [metodo1](params: [Params]): [ReturnType] {
    // Lógica de negocio
  }

  [metodo2](params: [Params]): [ReturnType] {
    // Lógica de negocio
  }

  // Factory methods
  static create(params: [CreateParams]): [NombreEntidad] {
    // Lógica de creación
  }

  static fromSnapshot(snapshot: [SnapshotType]): [NombreEntidad] {
    // Reconstrucción desde snapshot
  }
}
```

## Objetos de Valor

### [NombreValueObject]
[Descripción del objeto de valor y su propósito.]

```typescript
class [NombreValueObject] {
  private readonly value: [Tipo]

  constructor(value: [Tipo]) {
    this.validate(value)
    this.value = this.normalize(value)
  }

  private validate(value: [Tipo]): void {
    // Reglas de validación
    if (!this.isValid(value)) {
      throw new [ErrorType](value)
    }
  }

  private normalize(value: [Tipo]): [Tipo] {
    // Normalización (ej: trim, lowercase, etc.)
    return value.[normalized]()
  }

  private isValid(value: [Tipo]): boolean {
    // Lógica de validación
    return [condition]
  }

  equals(other: [NombreValueObject]): boolean {
    return this.value === other.value
  }

  toString(): string {
    return this.value.toString()
  }

  getValue(): [Tipo] {
    return this.value
  }
}
```

#### Reglas de Validación
- [Regla 1]: [Descripción]
- [Regla 2]: [Descripción]
- [Regla 3]: [Descripción]

#### Métodos de Negocio
```typescript
// Métodos específicos del dominio
[metodoNegocio](params: [Params]): [ReturnType] {
  // Lógica de negocio específica
}
```

[Repetir para cada objeto de valor necesario]

## Enumeraciones

### [NombreEnum]
[Descripción del propósito de la enumeración.]

```typescript
enum [NombreEnum] {
  [VALOR_1] = '[valor_string]',
  [VALOR_2] = '[valor_string]',
  [VALOR_3] = '[valor_string]'
}

class [NombreEnum]Value {
  readonly value: [NombreEnum]

  constructor(value: string = [default_value]) {
    if (!Object.values([NombreEnum]).includes(value as [NombreEnum])) {
      throw new Invalid[NombreEnum]Error(value)
    }
    this.value = value as [NombreEnum]
  }

  equals(other: [NombreEnum]Value): boolean {
    return this.value === other.value
  }

  toString(): string {
    return this.value
  }

  // Métodos de negocio específicos
  [metodoEspecifico](): [ReturnType] {
    // Lógica basada en el valor del enum
  }
}
```

## Reglas de Dominio

### [NombreRegla]
[Descripción detallada de la regla de dominio.]

#### Condición
- **Criterio**: [Cuándo aplica esta regla]
- **Validación**: [Cómo se valida]
- **Excepciones**: [Cuándo no aplica]

#### Implementación
```typescript
class [DomainService] {
  validate[NombreRegla](params: [Params]): void {
    if (!this.meetsCondition(params)) {
      throw new [DomainException](message)
    }
  }

  private meetsCondition(params: [Params]): boolean {
    // Lógica de validación de la regla
    return [condition]
  }
}
```

[Repetir para cada regla de dominio]

## Servicios de Dominio

### [DomainServiceName]
[Descripción del servicio de dominio y su responsabilidad.]

```typescript
interface [DomainServiceName] {
  [method1](params: [Params]): [ReturnType]
  [method2](params: [Params]): [ReturnType]
}

class [DomainServiceName]Impl implements [DomainServiceName] {
  constructor(
    private readonly [dependency1]: [DependencyType],
    private readonly [dependency2]: [DependencyType]
  ) {}

  [method1](params: [Params]): [ReturnType] {
    // Lógica de negocio compleja que no pertenece a una entidad
  }

  [method2](params: [Params]): [ReturnType] {
    // Coordinación entre múltiples entidades
  }
}
```

## Eventos de Dominio

### [DomainEventName]
[Descripción del evento y cuándo se dispara.]

```typescript
class [DomainEventName] {
  constructor(
    public readonly [aggregate]: [AggregateType],
    public readonly occurredAt: Date = new Date(),
    public readonly metadata?: [MetadataType]
  ) {}

  get eventType(): string {
    return '[DomainEventName]'
  }

  get aggregateId(): string {
    return this.[aggregate].id.value
  }
}
```

## Excepciones de Dominio

### [DomainExceptionName]
[Descripción de la excepción y cuándo ocurre.]

```typescript
class [DomainExceptionName] extends DomainError {
  constructor(message: string, public readonly context?: any) {
    super(message)
    this.name = '[DomainExceptionName]'
  }
}
```

### Jerarquía de Excepciones
```typescript
// Error base del dominio
export abstract class DomainError extends Error {
  constructor(message: string) {
    super(message)
    this.name = this.constructor.name
  }
}

// Errores específicos
export class [Validation1]Error extends DomainError {}
export class [Validation2]Error extends DomainError {}
export class [Business1]Error extends DomainError {}
export class [Business2]Error extends DomainError {}
```

## Invariantes del Dominio

### [InvarianteNombre]
[Descripción de la regla invariante que debe mantenerse siempre verdadera.]

#### Verificación
```typescript
class [NombreEntidad] {
  private invariantCheck(): void {
    if (!this.[invarianteMetodo]()) {
      throw new [InvariantViolationError](
        `Invariante [InvarianteNombre] violado`
      )
    }
  }

  private [invarianteMetodo](): boolean {
    // Lógica de verificación del invariante
    return [condition]
  }
}
```

[Repetir para cada invariante del dominio]

---

**Este modelo de dominio define las reglas de negocio, estructura de datos y comportamiento del dominio [Module].**