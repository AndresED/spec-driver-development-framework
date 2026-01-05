# Arquitectura - User Management

## Estilo Arquitectónico

### Clean Architecture + Hexagonal + CQRS

El módulo User Management sigue los principios de Clean Architecture con patrones Hexagonales (Ports & Adapters) y CQRS para separación de responsabilidades.

## Estructura de Capas

```
src/modules/users/
├── domain/                    # Capa de Dominio (Core)
│   ├── entities/
│   │   └── User.ts
│   ├── value-objects/
│   │   ├── UserId.ts
│   │   ├── Email.ts
│   │   ├── Password.ts
│   │   ├── UserRole.ts
│   │   └── UserStatus.ts
│   ├── repositories/
│   │   └── UserRepository.ts
│   ├── services/
│   │   └── UserDomainService.ts
│   └── events/
│       ├── UserCreatedEvent.ts
│       └── UserUpdatedEvent.ts
│
├── application/               # Capa de Aplicación (Use Cases)
│   ├── commands/
│   │   ├── CreateUserCommand.ts
│   │   └── UpdateUserCommand.ts
│   ├── queries/
│   │   ├── FindUserByIdQuery.ts
│   │   └── FindUserByEmailQuery.ts
│   ├── handlers/
│   │   ├── CreateUserHandler.ts
│   │   ├── UpdateUserHandler.ts
│   │   ├── FindUserByIdHandler.ts
│   │   └── FindUserByEmailHandler.ts
│   ├── dto/
│   │   ├── CreateUserDto.ts
│   │   ├── UpdateUserDto.ts
│   │   └── UserResponseDto.ts
│   └── ports/
│       ├── input/
│       │   ├── CreateUserUseCase.ts
│       │   └── FindUserUseCase.ts
│       └── output/
│           └── UserRepository.ts
│
├── infrastructure/           # Capa de Infraestructura
│   ├── persistence/
│   │   ├── entities/
│   │   │   └── UserEntity.ts
│   │   ├── repositories/
│   │   │   └── TypeOrmUserRepository.ts
│   │   └── mappers/
│   │       └── UserMapper.ts
│   ├── external/
│   │   └── EmailService.ts
│   └── config/
│       └── UserModuleConfig.ts
│
└── presentation/             # Capa de Presentación
    ├── controllers/
    │   └── UserController.ts
    ├── middleware/
    │   └── UserValidationMiddleware.ts
    └── routes/
        └── UserRoutes.ts
```

## Patrones y Principios

### 1. Dependency Inversion
- Las capas superiores dependen de abstracciones
- La infraestructura implementa puertos de la aplicación
- El dominio no depende de nada externo

### 2. Single Responsibility
- Cada clase tiene una única responsabilidad
- Separación clara entre comandos y queries
- Los handlers solo orchestran, no contienen lógica

### 3. CQRS (Command Query Responsibility Segregation)
- **Commands**: Modifican estado (Create, Update, Delete)
- **Queries**: Leen estado (Find, Search, List)
- Separación total de modelos de lectura/escritura

### 4. Hexagonal Architecture
- **Ports**: Interfaces que definen contratos
- **Adapters**: Implementaciones concretas
- El dominio está aislado de infraestructura

## Componentes Clave

### Entidades de Dominio
```typescript
// domain/entities/User.ts
export class User {
  constructor(
    public readonly id: UserId,
    public readonly email: Email,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly password: Password,
    public readonly role: UserRoleValue,
    public readonly status: UserStatusValue,
    public readonly createdAt: Date,
    public readonly updatedAt: Date
  ) {}

  static create(params: CreateUserParams): User {
    // Lógica de creación de usuario
  }

  update(params: UpdateUserParams): User {
    // Lógica de actualización
  }
}
```

### Repositorios (Ports)
```typescript
// domain/repositories/UserRepository.ts
export interface UserRepository {
  save(user: User): Promise<void>
  findById(id: UserId): Promise<User | null>
  findByEmail(email: Email): Promise<User | null>
  findAll(): Promise<User[]>
  delete(id: UserId): Promise<void>
}
```

### Casos de Uso (Input Ports)
```typescript
// application/ports/input/CreateUserUseCase.ts
export interface CreateUserUseCase {
  execute(command: CreateUserCommand): Promise<UserCreatedResponse>
}
```

### Implementación de Repositorio (Adapter)
```typescript
// infrastructure/persistence/repositories/TypeOrmUserRepository.ts
export class TypeOrmUserRepository implements UserRepository {
  constructor(private readonly dataSource: DataSource) {}

  async save(user: User): Promise<void> {
    const entity = UserMapper.toEntity(user)
    await this.dataSource.getRepository(UserEntity).save(entity)
  }

  // ... otros métodos
}
```

## Flujo de Datos

### Creación de Usuario
```
HTTP Request → Controller → DTO Validation → Command → Handler → Domain Logic → Repository → Database
```

### Consulta de Usuario
```
HTTP Request → Controller → Query → Handler → Repository → Domain Entity → Response DTO → HTTP Response
```

## Validaciones

### DTO Validation
```typescript
// application/dto/CreateUserDto.ts
export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string

  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  firstName: string

  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  lastName: string

  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  password: string

  @IsEnum(UserRole)
  @IsNotEmpty()
  role: UserRole
}
```

### Domain Validation
```typescript
// domain/value-objects/Email.ts
export class Email {
  constructor(private readonly value: string) {
    this.validate(value)
  }

  private validate(email: string): void {
    if (!this.isValidEmail(email)) {
      throw new InvalidEmailError(email)
    }
  }

  private isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }
}
```

## Manejo de Errores

### Exception Hierarchy
```typescript
// Domain Errors
export abstract class DomainError extends Error {
  constructor(message: string) {
    super(message)
    this.name = this.constructor.name
  }
}

// Application Errors
export abstract class ApplicationError extends Error {
  constructor(message: string) {
    super(message)
    this.name = this.constructor.name
  }
}

// Infrastructure Errors
export abstract class InfrastructureError extends Error {
  constructor(message: string) {
    super(message)
    this.name = this.constructor.name
  }
}
```

### Error Mapping
```typescript
// presentation/middleware/ErrorHandlerMiddleware.ts
export class ErrorHandlerMiddleware {
  use(error: Error, req: Request, res: Response, next: NextFunction) {
    if (error instanceof DomainError) {
      res.status(400).json({ error: error.message })
    } else if (error instanceof ApplicationError) {
      res.status(422).json({ error: error.message })
    } else {
      res.status(500).json({ error: 'Internal server error' })
    }
  }
}
```

## Configuración del Módulo

### NestJS Module
```typescript
// UserModule.ts
@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity]),
  ],
  controllers: [UserController],
  providers: [
    // Use Cases
    CreateUserHandler,
    FindUserByIdHandler,
    
    // Domain Services
    UserDomainService,
    
    // Infrastructure
    {
      provide: 'UserRepository',
      useClass: TypeOrmUserRepository,
    },
    
    // Mappers
    UserMapper,
  ],
})
export class UserModule {}
```

---

**Esta arquitectura garantiza separación de responsabilidades, testabilidad y mantenibilidad del módulo User Management.**