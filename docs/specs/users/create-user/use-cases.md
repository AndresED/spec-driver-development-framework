# Casos de Uso - User Management

## Casos de Uso Principales

### CU-001: CreateUser
Crear un nuevo usuario en el sistema.

#### Descripción
Permite la creación de un nuevo usuario con validación de datos y reglas de negocio.

#### Actores
- Sistema (invocado vía API)
- UserDomainService (validaciones)

#### Precondiciones
- Datos de entrada válidos
- Email no existe en el sistema
- Rol solicitado es permitido para el creador

#### Flujo Principal
```
1. Recibir CreateUserCommand
2. Validar datos de entrada (DTO)
3. Verificar unicidad de email
4. Validar reglas de dominio
5. Crear entidad User
6. Persistir usuario
7. Retornar UserCreatedResponse
```

#### Flujos Alternativos

**A1: Email ya existe**
```
1. Recibir CreateUserCommand
2. Validar datos de entrada
3. Verificar email existe
4. Lanzar EmailAlreadyExistsException
5. Retornar error 409
```

**A2: Datos inválidos**
```
1. Recibir CreateUserCommand
2. Validar datos de entrada
3. Detectar datos inválidos
4. Lanzar ValidationException
5. Retornar error 400
```

#### Postcondiciones
- Usuario creado y persistido
- ID asignado al usuario
- Password encriptado
- Evento UserCreated emitido

---

### CU-002: FindUserById
Buscar usuario por ID.

#### Descripción
Recupera información de un usuario específico por su identificador.

#### Actores
- Sistema (invocado vía API)

#### Precondiciones
- ID válido
- Usuario existe

#### Flujo Principal
```
1. Recibir FindUserByIdQuery
2. Validar ID
3. Buscar usuario en repositorio
4. Verificar usuario encontrado
5. Retornar UserResponse
```

#### Flujos Alternativos

**A1: Usuario no encontrado**
```
1. Recibir FindUserByIdQuery
2. Validar ID
3. Buscar usuario en repositorio
4. Usuario no encontrado
5. Lanzar UserNotFoundException
6. Retornar error 404
```

---

### CU-003: UpdateUser
Actualizar datos de un usuario.

#### Descripción
Modifica información de un usuario existente.

#### Actores
- Sistema (invocado vía API)

#### Precondiciones
- Usuario existe
- Datos válidos
- Permisos adecuados

#### Flujo Principal
```
1. Recibir UpdateUserCommand
2. Validar datos
3. Buscar usuario existente
4. Aplicar cambios
5. Validar reglas de dominio
6. Persistir cambios
7. Retornar UserUpdatedResponse
```

---

## Comandos y Queries

### Comandos

#### CreateUserCommand
```typescript
class CreateUserCommand {
  constructor(
    public readonly email: string,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly password: string,
    public readonly role: string,
    public readonly creatorRole: string
  ) {}
}
```

#### UpdateUserCommand
```typescript
class UpdateUserCommand {
  constructor(
    public readonly id: string,
    public readonly firstName?: string,
    public readonly lastName?: string,
    public readonly role?: string,
    public readonly status?: string
  ) {}
}
```

### Queries

#### FindUserByIdQuery
```typescript
class FindUserByIdQuery {
  constructor(public readonly id: string) {}
}
```

#### FindUserByEmailQuery
```typescript
class FindUserByEmailQuery {
  constructor(public readonly email: string) {}
}
```

---

## Respuestas

### UserCreatedResponse
```typescript
class UserCreatedResponse {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly role: string,
    public readonly status: string,
    public readonly createdAt: Date
  ) {}
}
```

### UserResponse
```typescript
class UserResponse {
  constructor(
    public readonly id: string,
    public readonly email: string,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly role: string,
    public readonly status: string,
    public readonly createdAt: Date,
    public readonly updatedAt: Date
  ) {}
}
```

---

## Handlers

### CreateUserHandler
```typescript
class CreateUserHandler {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly userDomainService: UserDomainService,
    private readonly eventBus: EventBus
  ) {}

  async handle(command: CreateUserCommand): Promise<UserCreatedResponse> {
    // 1. Validar DTO
    const email = new Email(command.email)
    const password = new Password(command.password)
    const role = new UserRoleValue(command.role)
    const status = new UserStatusValue()

    // 2. Verificar unicidad
    const existingUser = await this.userRepository.findByEmail(email)
    if (existingUser) {
      throw new EmailAlreadyExistsError(email.value)
    }

    // 3. Validar reglas de dominio
    this.userDomainService.validateEmailUniqueness(email, [])
    this.userDomainService.canCreateUser(
      new UserRoleValue(command.creatorRole),
      role.value
    )

    // 4. Crear entidad
    const user = new User(
      UserId.generate(),
      email,
      command.firstName,
      command.lastName,
      password,
      role,
      status
    )

    // 5. Persistir
    await this.userRepository.save(user)

    // 6. Emitir evento
    await this.eventBus.publish(new UserCreatedEvent(user))

    // 7. Retornar respuesta
    return new UserCreatedResponse(
      user.id.value,
      user.email.value,
      user.firstName,
      user.lastName,
      user.role.value,
      user.status.value,
      user.createdAt
    )
  }
}
```

---

## Eventos de Dominio

### UserCreatedEvent
```typescript
class UserCreatedEvent {
  constructor(
    public readonly user: User,
    public readonly occurredAt: Date = new Date()
  ) {}
}
```

### UserUpdatedEvent
```typescript
class UserUpdatedEvent {
  constructor(
    public readonly user: User,
    public readonly previousState: User,
    public readonly occurredAt: Date = new Date()
  ) {}
}
```

---

**Estos casos de uso definen el comportamiento y las interacciones del sistema User Management.**