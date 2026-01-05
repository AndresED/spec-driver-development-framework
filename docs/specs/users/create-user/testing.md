# Estrategia de Pruebas - User Management

## Filosofía de Pruebas

### 100% Coverage Obligatorio
- **Statements**: 100%
- **Branches**: 100%
- **Functions**: 100%
- **Lines**: 100%

### Test Pyramid
```
E2E Tests (5%)
     ↑
Integration Tests (15%)
     ↑
Unit Tests (80%)
```

## Tipos de Pruebas

### 1. Unit Tests
Pruebas aisladas de unidades individuales.

#### Domain Tests
```typescript
// test/modules/users/domain/User.spec.ts
describe('User', () => {
  describe('create', () => {
    it('should create user with valid data', () => {
      // Arrange
      const params = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password123!',
        role: UserRole.USER,
        status: UserStatus.ACTIVE
      }

      // Act
      const user = User.create(params)

      // Assert
      expect(user.email.value).toBe(params.email)
      expect(user.firstName).toBe(params.firstName)
      expect(user.lastName).toBe(params.lastName)
      expect(user.role.value).toBe(params.role)
      expect(user.status.value).toBe(params.status)
      expect(user.id).toBeDefined()
      expect(user.createdAt).toBeDefined()
    })

    it('should throw InvalidEmailError with invalid email', () => {
      // Arrange
      const params = {
        email: 'invalid-email',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password123!',
        role: UserRole.USER,
        status: UserStatus.ACTIVE
      }

      // Act & Assert
      expect(() => User.create(params)).toThrow(InvalidEmailError)
    })

    it('should throw InvalidPasswordError with weak password', () => {
      // Arrange
      const params = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'weak',
        role: UserRole.USER,
        status: UserStatus.ACTIVE
      }

      // Act & Assert
      expect(() => User.create(params)).toThrow(InvalidPasswordError)
    })
  })

  describe('update', () => {
    it('should update user with valid data', () => {
      // Arrange
      const user = User.create({
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password123!',
        role: UserRole.USER,
        status: UserStatus.ACTIVE
      })

      const updateParams = {
        firstName: 'Jane',
        lastName: 'Smith'
      }

      // Act
      const updatedUser = user.update(updateParams)

      // Assert
      expect(updatedUser.firstName).toBe(updateParams.firstName)
      expect(updatedUser.lastName).toBe(updateParams.lastName)
      expect(updatedUser.email.value).toBe(user.email.value)
      expect(updatedUser.updatedAt).not.toBe(user.updatedAt)
    })
  })
})
```

#### Value Object Tests
```typescript
// test/modules/users/domain/value-objects/Email.spec.ts
describe('Email', () => {
  describe('constructor', () => {
    it('should create email with valid address', () => {
      // Arrange
      const validEmail = 'test@example.com'

      // Act
      const email = new Email(validEmail)

      // Assert
      expect(email.value).toBe(validEmail.toLowerCase().trim())
    })

    it('should normalize email case and trim', () => {
      // Arrange
      const emailInput = '  TEST@EXAMPLE.COM  '

      // Act
      const email = new Email(emailInput)

      // Assert
      expect(email.value).toBe('test@example.com')
    })

    it('should throw InvalidEmailError with invalid format', () => {
      // Arrange
      const invalidEmails = [
        'invalid',
        'test@',
        '@example.com',
        'test.example.com',
        '',
        'test@.com',
        'test@example.'
      ]

      // Act & Assert
      invalidEmails.forEach(email => {
        expect(() => new Email(email)).toThrow(InvalidEmailError)
      })
    })
  })

  describe('equals', () => {
    it('should return true for equal emails', () => {
      // Arrange
      const email1 = new Email('test@example.com')
      const email2 = new Email('TEST@example.com')

      // Act & Assert
      expect(email1.equals(email2)).toBe(true)
    })

    it('should return false for different emails', () => {
      // Arrange
      const email1 = new Email('test1@example.com')
      const email2 = new Email('test2@example.com')

      // Act & Assert
      expect(email1.equals(email2)).toBe(false)
    })
  })
})
```

### 2. Application Tests
Pruebas de casos de uso y handlers.

#### Handler Tests
```typescript
// test/modules/users/application/handlers/CreateUserHandler.spec.ts
describe('CreateUserHandler', () => {
  let handler: CreateUserHandler
  let userRepository: jest.Mocked<UserRepository>
  let userDomainService: jest.Mocked<UserDomainService>
  let eventBus: jest.Mocked<EventBus>

  beforeEach(() => {
    userRepository = createMockUserRepository()
    userDomainService = createUserDomainService()
    eventBus = createMockEventBus()

    handler = new CreateUserHandler(userRepository, userDomainService, eventBus)
  })

  describe('handle', () => {
    it('should create user successfully', async () => {
      // Arrange
      const command = new CreateUserCommand(
        'test@example.com',
        'John',
        'Doe',
        'Password123!',
        UserRole.USER,
        UserRole.ADMIN
      )

      userRepository.findByEmail.mockResolvedValue(null)
      userDomainService.validateEmailUniqueness.mockReturnValue()
      userDomainService.canCreateUser.mockReturnValue(true)

      // Act
      const result = await handler.handle(command)

      // Assert
      expect(result).toBeInstanceOf(UserCreatedResponse)
      expect(result.email).toBe(command.email)
      expect(result.firstName).toBe(command.firstName)
      expect(result.lastName).toBe(command.lastName)
      expect(result.role).toBe(command.role)
      expect(result.status).toBe(UserStatus.ACTIVE)

      expect(userRepository.save).toHaveBeenCalledTimes(1)
      expect(eventBus.publish).toHaveBeenCalledTimes(1)
    })

    it('should throw EmailAlreadyExistsError when email exists', async () => {
      // Arrange
      const command = new CreateUserCommand(
        'existing@example.com',
        'John',
        'Doe',
        'Password123!',
        UserRole.USER,
        UserRole.ADMIN
      )

      const existingUser = User.create({
        email: 'existing@example.com',
        firstName: 'Existing',
        lastName: 'User',
        password: 'Password123!',
        role: UserRole.USER,
        status: UserStatus.ACTIVE
      })

      userRepository.findByEmail.mockResolvedValue(existingUser)

      // Act & Assert
      await expect(handler.handle(command)).rejects.toThrow(EmailAlreadyExistsError)
      expect(userRepository.save).not.toHaveBeenCalled()
      expect(eventBus.publish).not.toHaveBeenCalled()
    })

    it('should throw ValidationError when role not allowed', async () => {
      // Arrange
      const command = new CreateUserCommand(
        'test@example.com',
        'John',
        'Doe',
        'Password123!',
        UserRole.ADMIN,
        UserRole.USER
      )

      userRepository.findByEmail.mockResolvedValue(null)
      userDomainService.canCreateUser.mockReturnValue(false)

      // Act & Assert
      await expect(handler.handle(command)).rejects.toThrow(ValidationError)
      expect(userRepository.save).not.toHaveBeenCalled()
    })
  })
})
```

### 3. Infrastructure Tests
Pruebas de implementación de infraestructura.

#### Repository Tests
```typescript
// test/modules/users/infrastructure/persistence/TypeOrmUserRepository.spec.ts
describe('TypeOrmUserRepository', () => {
  let repository: TypeOrmUserRepository
  let dataSource: jest.Mocked<DataSource>

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        TypeOrmUserRepository,
        {
          provide: DataSource,
          useValue: createMockDataSource()
        }
      ]
    }).compile()

    repository = module.get(TypeOrmUserRepository)
    dataSource = module.get(DataSource)
  })

  describe('save', () => {
    it('should save user successfully', async () => {
      // Arrange
      const user = User.create({
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password123!',
        role: UserRole.USER,
        status: UserStatus.ACTIVE
      })

      const mockRepository = {
        save: jest.fn().mockResolvedValue(undefined)
      }
      dataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act
      await repository.save(user)

      // Assert
      expect(mockRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          email: user.email.value,
          firstName: user.firstName,
          lastName: user.lastName
        })
      )
    })
  })

  describe('findByEmail', () => {
    it('should return user when found', async () => {
      // Arrange
      const email = new Email('test@example.com')
      const entity = createMockUserEntity()

      const mockRepository = {
        findOne: jest.fn().mockResolvedValue(entity)
      }
      dataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act
      const result = await repository.findByEmail(email)

      // Assert
      expect(result).toBeInstanceOf(User)
      expect(result?.email.value).toBe(email.value)
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { email: email.value }
      })
    })

    it('should return null when not found', async () => {
      // Arrange
      const email = new Email('notfound@example.com')

      const mockRepository = {
        findOne: jest.fn().mockResolvedValue(null)
      }
      dataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act
      const result = await repository.findByEmail(email)

      // Assert
      expect(result).toBeNull()
    })
  })
})
```

### 4. Integration Tests
Pruebas de integración entre componentes.

#### API Integration Tests
```typescript
// test/integration/users.spec.ts
describe('Users API (Integration)', () => {
  let app: INestApplication
  let dataSource: DataSource

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule]
    }).compile()

    app = module.createNestApplication()
    dataSource = module.get(DataSource)

    await app.init()
  })

  beforeEach(async () => {
    await dataSource.synchronize(true)
  })

  afterEach(async () => {
    await dataSource.dropDatabase()
  })

  describe('POST /users', () => {
    it('should create user successfully', async () => {
      // Arrange
      const createUserDto = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password123!',
        role: UserRole.USER
      }

      // Act
      const response = await request(app.getHttpServer())
        .post('/users')
        .send(createUserDto)
        .expect(201)

      // Assert
      expect(response.body).toMatchObject({
        email: createUserDto.email,
        firstName: createUserDto.firstName,
        lastName: createUserDto.lastName,
        role: createUserDto.role,
        status: UserStatus.ACTIVE
      })
      expect(response.body.id).toBeDefined()
      expect(response.body.createdAt).toBeDefined()
    })

    it('should return 400 for invalid data', async () => {
      // Arrange
      const invalidDto = {
        email: 'invalid-email',
        firstName: '',
        lastName: 'Doe',
        password: 'weak',
        role: 'INVALID_ROLE'
      }

      // Act & Assert
      await request(app.getHttpServer())
        .post('/users')
        .send(invalidDto)
        .expect(400)
    })

    it('should return 409 for duplicate email', async () => {
      // Arrange
      const createUserDto = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'Password123!',
        role: UserRole.USER
      }

      // Create first user
      await request(app.getHttpServer())
        .post('/users')
        .send(createUserDto)
        .expect(201)

      // Act & Assert
      await request(app.getHttpServer())
        .post('/users')
        .send(createUserDto)
        .expect(409)
    })
  })
})
```

### 5. E2E Tests
Pruebas end-to-end completas.

#### E2E Test
```typescript
// test/e2e/user-management.spec.ts
describe('User Management E2E', () => {
  let app: INestApplication

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule]
    }).compile()

    app = module.createNestApplication()
    await app.init()
  })

  describe('Complete User Lifecycle', () => {
    it('should manage complete user lifecycle', async () => {
      // 1. Create user
      const createUserResponse = await request(app.getHttpServer())
        .post('/users')
        .send({
          email: 'lifecycle@example.com',
          firstName: 'Test',
          lastName: 'User',
          password: 'Password123!',
          role: UserRole.USER
        })
        .expect(201)

      const userId = createUserResponse.body.id

      // 2. Get user
      const getUserResponse = await request(app.getHttpServer())
        .get(`/users/${userId}`)
        .expect(200)

      expect(getUserResponse.body.id).toBe(userId)

      // 3. Update user
      await request(app.getHttpServer())
        .patch(`/users/${userId}`)
        .send({
          firstName: 'Updated',
          lastName: 'User'
        })
        .expect(200)

      // 4. Verify update
      const updatedUserResponse = await request(app.getHttpServer())
        .get(`/users/${userId}`)
        .expect(200)

      expect(updatedUserResponse.body.firstName).toBe('Updated')
      expect(updatedUserResponse.body.lastName).toBe('User')

      // 5. Delete user
      await request(app.getHttpServer())
        .delete(`/users/${userId}`)
        .expect(204)

      // 6. Verify deletion
      await request(app.getHttpServer())
        .get(`/users/${userId}`)
        .expect(404)
    })
  })
})
```

## Test Utilities

### Mock Factories
```typescript
// test/shared/factories/UserFactory.ts
export class UserFactory {
  static create(overrides?: Partial<UserParams>): User {
    const params: UserParams = {
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      password: 'Password123!',
      role: UserRole.USER,
      status: UserStatus.ACTIVE,
      ...overrides
    }

    return User.create(params)
  }

  static createMany(count: number, overrides?: Partial<UserParams>): User[] {
    return Array.from({ length: count }, (_, index) => 
      this.create({
        email: `test${index}@example.com`,
        ...overrides
      })
    )
  }
}
```

### Test Helpers
```typescript
// test/shared/helpers/TestHelpers.ts
export class TestHelpers {
  static async createTestUser(
    repository: UserRepository,
    overrides?: Partial<UserParams>
  ): Promise<User> {
    const user = UserFactory.create(overrides)
    await repository.save(user)
    return user
  }

  static assertUserEquals(actual: User, expected: User): void {
    expect(actual.id.value).toBe(expected.id.value)
    expect(actual.email.value).toBe(expected.email.value)
    expect(actual.firstName).toBe(expected.firstName)
    expect(actual.lastName).toBe(expected.lastName)
    expect(actual.role.value).toBe(expected.role.value)
    expect(actual.status.value).toBe(expected.status.value)
  }
}
```

## Configuración de Jest

### Jest Config
```typescript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/test'],
  testMatch: ['**/*.spec.ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/main.ts',
    '!src/**/*.module.ts'
  ],
  coverageThreshold: {
    global: {
      branches: 100,
      functions: 100,
      lines: 100,
      statements: 100
    }
  },
  setupFilesAfterEnv: ['<rootDir>/test/setup.ts'],
  moduleNameMapping: {
    '^@app/(.*)$': '<rootDir>/src/$1',
    '^@test/(.*)$': '<rootDir>/test/$1'
  }
}
```

## Scripts de Pruebas

### Package.json Scripts
```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "jest --testPathPattern=e2e",
    "test:ci": "jest --coverage --ci --watchAll=false"
  }
}
```

---

**Esta estrategia de pruebas garantiza calidad, confiabilidad y mantenimiento del código User Management.**