# SPEC Template - Architecture

## Estilo Arquitectónico

### Arquitectura Principal
- **Clean Architecture**: Separación clara de responsabilidades
- **Hexagonal Architecture**: Ports & Adapters para desacoplamiento
- **CQRS**: Separación de comandos y queries
- **Domain-Driven Design**: Enfoque en el dominio del negocio

### Principios Aplicados
- **Single Responsibility Principle**: Cada clase tiene una razón para cambiar
- **Dependency Inversion**: Depender de abstracciones, no de implementaciones
- **Interface Segregation**: Interfaces específicas y cohesivas
- **Open/Closed**: Abierto a extensión, cerrado a modificación

## Estructura de Capas

```
src/modules/[module]/
├── domain/                    # Capa de Dominio (Core Business Logic)
│   ├── entities/              # Entidades del dominio
│   │   └── [EntityName].ts
│   ├── value-objects/         # Objetos de valor
│   │   ├── [VO1].ts
│   │   ├── [VO2].ts
│   │   └── [VO3].ts
│   ├── repositories/          # Puertos de repositorios
│   │   └── [RepositoryInterface].ts
│   ├── services/              # Servicios de dominio
│   │   └── [DomainService].ts
│   └── events/                # Eventos de dominio
│       ├── [Event1].ts
│       └── [Event2].ts
│
├── application/               # Capa de Aplicación (Use Cases)
│   ├── commands/              # Comandos (CQRS)
│   │   ├── [Command1].ts
│   │   └── [Command2].ts
│   ├── queries/               # Queries (CQRS)
│   │   ├── [Query1].ts
│   │   └── [Query2].ts
│   ├── handlers/              # Handlers de comandos y queries
│   │   ├── [Handler1].ts
│   │   ├── [Handler2].ts
│   │   └── [Handler3].ts
│   ├── dto/                   # Data Transfer Objects
│   │   ├── [DTO1].ts
│   │   └── [DTO2].ts
│   └── ports/                 # Puertos de aplicación
│       ├── input/             # Puertos de entrada (use cases)
│       │   ├── [UseCase1].ts
│       │   └── [UseCase2].ts
│       └── output/            # Puertos de salida (repositories)
│           └── [RepositoryInterface].ts
│
├── infrastructure/           # Capa de Infraestructura
│   ├── persistence/           # Implementación de persistencia
│   │   ├── entities/          # Entidades de base de datos
│   │   │   └── [DBEntity].ts
│   │   ├── repositories/      # Implementaciones de repositorios
│   │   │   └── [RepositoryImpl].ts
│   │   └── mappers/           # Mappers Domain ↔ Infrastructure
│   │       └── [Mapper].ts
│   ├── external/               # Servicios externos
│   │   ├── [ExternalService1].ts
│   │   └── [ExternalService2].ts
│   └── config/                # Configuración del módulo
│       └── [ModuleConfig].ts
│
└── presentation/             # Capa de Presentación
    ├── controllers/           # Controladores HTTP/REST
    │   └── [Controller].ts
    ├── middleware/            # Middleware específico del módulo
    │   ├── [Middleware1].ts
    │   └── [Middleware2].ts
    └── routes/                # Definición de rutas
        └── [Routes].ts
```

## Patrones y Principios

### 1. Dependency Inversion
```typescript
// La capa de aplicación depende de abstracciones del dominio
interface UserRepository {
  save(user: User): Promise<void>
  findById(id: UserId): Promise<User | null>
  findByEmail(email: Email): Promise<User | null>
}

// La infraestructura implementa las abstracciones
@Injectable()
export class TypeOrmUserRepository implements UserRepository {
  // Implementación concreta
}
```

### 2. CQRS Implementation
```typescript
// Commands modifican estado
export class CreateUserCommand {
  constructor(
    public readonly email: string,
    public readonly firstName: string,
    public readonly lastName: string,
    public readonly password: string,
    public readonly role: UserRole
  ) {}
}

// Queries leen estado
export class FindUserByIdQuery {
  constructor(public readonly id: string) {}
}

// Handlers separados para cada tipo
export class CreateUserHandler {
  async handle(command: CreateUserCommand): Promise<UserResponse> {
    // Lógica de modificación de estado
  }
}

export class FindUserByIdHandler {
  async handle(query: FindUserByIdQuery): Promise<UserResponse> {
    // Lógica de lectura de estado
  }
}
```

### 3. Hexagonal Architecture (Ports & Adapters)
```typescript
// Puerto (Interface) - Dentro del hexágono
export interface EmailService {
  sendWelcomeEmail(email: string, name: string): Promise<void>
  sendPasswordResetEmail(email: string, token: string): Promise<void>
}

// Adapter (Implementation) - Fuera del hexágono
@Injectable()
export class SMTPEmailService implements EmailService {
  constructor(
    private readonly emailProvider: SMTPProvider,
    private readonly templateEngine: TemplateEngine
  ) {}

  async sendWelcomeEmail(email: string, name: string): Promise<void> {
    const template = await this.templateEngine.render('welcome', { name })
    await this.emailProvider.send(email, 'Welcome!', template)
  }
}
```

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

  // Métodos de negocio puros
  updateName(firstName: string, lastName: string): User {
    // Lógica de negocio para actualizar nombre
  }

  activate(): User {
    // Lógica de negocio para activar usuario
  }

  deactivate(): User {
    // Lógica de negocio para desactivar usuario
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
  existsByEmail(email: Email): Promise<boolean>
}
```

### Casos de Uso (Input Ports)
```typescript
// application/ports/input/CreateUserUseCase.ts
export interface CreateUserUseCase {
  execute(command: CreateUserCommand): Promise<UserCreatedResponse>
}

// application/ports/input/FindUserUseCase.ts
export interface FindUserUseCase {
  execute(query: FindUserQuery): Promise<UserResponse>
}
```

### Implementación de Repositorio (Adapter)
```typescript
// infrastructure/persistence/repositories/TypeOrmUserRepository.ts
@Injectable()
export class TypeOrmUserRepository implements UserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repository: Repository<UserEntity>,
    private readonly mapper: UserMapper
  ) {}

  async save(user: User): Promise<void> {
    const entity = this.mapper.toEntity(user)
    await this.repository.save(entity)
  }

  async findById(id: UserId): Promise<User | null> {
    const entity = await this.repository.findOne({
      where: { id: id.value }
    })
    return entity ? this.mapper.toDomain(entity) : null
  }

  // ... otros métodos
}
```

## Flujo de Datos

### Creación de Usuario
```
HTTP Request
    ↓
UserController (Presentation)
    ↓
DTO Validation
    ↓
CreateUserCommand (Application)
    ↓
CreateUserHandler (Application)
    ↓
Domain Logic Validation
    ↓
User Entity Creation (Domain)
    ↓
UserRepository.save() (Application Port)
    ↓
TypeOrmUserRepository.save() (Infrastructure)
    ↓
Database
    ↓
UserCreatedEvent (Domain)
    ↓
EventBus.publish() (Infrastructure)
    ↓
External Services
```

### Consulta de Usuario
```
HTTP Request
    ↓
UserController (Presentation)
    ↓
FindUserQuery (Application)
    ↓
FindUserHandler (Application)
    ↓
UserRepository.findById() (Application Port)
    ↓
TypeOrmUserRepository.findById() (Infrastructure)
    ↓
Database
    ↓
Domain Entity (Domain)
    ↓
UserResponse DTO (Application)
    ↓
HTTP Response (Presentation)
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
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message: 'Password must contain at least one uppercase letter, one lowercase letter, one number and one special character'
  })
  password: string

  @IsEnum(UserRole)
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

  equals(other: Email): boolean {
    return this.value.toLowerCase() === other.value.toLowerCase()
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

// Specific Errors
export class UserNotFoundError extends DomainError {}
export class EmailAlreadyExistsError extends DomainError {}
export class InvalidUserDataError extends ApplicationError {}
export class DatabaseConnectionError extends InfrastructureError {}
```

### Error Mapping
```typescript
// presentation/middleware/ErrorHandlerMiddleware.ts
@Injectable()
export class ErrorHandlerMiddleware implements NestMiddleware {
  use(error: Error, req: Request, res: Response, next: NextFunction): void {
    if (error instanceof DomainError) {
      res.status(400).json({
        error: error.message,
        type: 'DomainError',
        timestamp: new Date().toISOString()
      })
    } else if (error instanceof ApplicationError) {
      res.status(422).json({
        error: error.message,
        type: 'ApplicationError',
        timestamp: new Date().toISOString()
      })
    } else if (error instanceof InfrastructureError) {
      res.status(500).json({
        error: 'Internal server error',
        type: 'InfrastructureError',
        timestamp: new Date().toISOString()
      })
    } else {
      res.status(500).json({
        error: 'Unexpected error',
        type: 'UnknownError',
        timestamp: new Date().toISOString()
      })
    }
  }
}
```

## Configuración del Módulo

### NestJS Module Configuration
```typescript
// [Module]Module.ts
@Module({
  imports: [
    TypeOrmModule.forFeature([UserEntity]),
    // otros módulos necesarios
  ],
  controllers: [UserController],
  providers: [
    // Use Cases
    CreateUserHandler,
    FindUserByIdHandler,
    UpdateUserHandler,
    
    // Domain Services
    UserDomainService,
    
    // Infrastructure Adapters
    {
      provide: 'UserRepository',
      useClass: TypeOrmUserRepository,
    },
    {
      provide: 'EmailService',
      useClass: SMTPEmailService,
    },
    
    // Mappers
    UserMapper,
    
    // External Services
    EmailProvider,
    TemplateEngine,
  ],
  exports: [
    'UserRepository',
    'EmailService',
    CreateUserHandler,
    FindUserByIdHandler,
  ],
})
export class [Module]Module {}
```

## Consideraciones de Performance

### 1. Lazy Loading
```typescript
// Carga perezosa de dependencias pesadas
@Injectable()
export class HeavyService {
  private heavyResource: Resource | null = null

  private getHeavyResource(): Resource {
    if (!this.heavyResource) {
      this.heavyResource = new Resource()
    }
    return this.heavyResource
  }
}
```

### 2. Connection Pooling
```typescript
// Configuración optimizada de pool de base de datos
const dataSource = new DataSource({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  extra: {
    max: 20,                    // Máximo de conexiones
    min: 5,                     // Mínimo de conexiones
    acquire: 30000,             // Tiempo máximo para adquirir
    idle: 10000,                // Tiempo máximo de inactividad
  },
})
```

---

**Esta arquitectura garantiza separación de responsabilidades, testabilidad, mantenibilidad y escalabilidad del módulo [Module].**