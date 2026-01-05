# SPEC Template - Testing Strategy

## Filosofía de Pruebas

### Objetivo Principal
**100% Coverage Obligatorio** para:
- ✅ Statements (Sentencias)
- ✅ Branches (Ramas)
- ✅ Functions (Funciones)
- ✅ Lines (Líneas)

### Principios Fundamentales
- **Test First**: Escribir tests antes del código de producción
- **AAA Pattern**: Arrange-Act-Assert en todos los tests
- **Single Responsibility**: Un test, una afirmación
- **Deterministic**: Tests deben ser predecibles y repetibles

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
Pruebas aisladas de unidades individuales sin dependencias externas.

#### Pruebas de Entidades de Dominio
```typescript
// test/modules/[module]/domain/entities/[EntityName].spec.ts
describe('[EntityName]', () => {
  describe('create', () => {
    it('should create entity with valid data', () => {
      // Arrange
      const params = {
        [field_1]: 'valid_value_1',
        [field_2]: 'valid_value_2',
        [field_3]: 'valid_value_3'
      }

      // Act
      const entity = [EntityName].create(params)

      // Assert
      expect(entity.[field_1].value).toBe(params.[field_1])
      expect(entity.[field_2]).toBe(params.[field_2])
      expect(entity.[field_3]).toBe(params.[field_3])
      expect(entity.id).toBeDefined()
      expect(entity.createdAt).toBeDefined()
    })

    it('should throw [ValidationError] with invalid [field_1]', () => {
      // Arrange
      const params = {
        [field_1]: 'invalid_value',
        [field_2]: 'valid_value_2',
        [field_3]: 'valid_value_3'
      }

      // Act & Assert
      expect(() => [EntityName].create(params)).toThrow([ValidationError])
    })

    it('should throw [ValidationError] with missing required field', () => {
      // Arrange
      const params = {
        [field_1]: 'valid_value_1'
        // [field_2] faltante
      }

      // Act & Assert
      expect(() => [EntityName].create(params)).toThrow(ValidationError)
    })
  })

  describe('update', () => {
    it('should update entity with valid data', () => {
      // Arrange
      const entity = [EntityName].create({
        [field_1]: 'original_value',
        [field_2]: 'original_value',
        [field_3]: 'original_value'
      })

      const updateParams = {
        [field_1]: 'updated_value',
        [field_2]: 'updated_value'
      }

      // Act
      const updatedEntity = entity.update(updateParams)

      // Assert
      expect(updatedEntity.[field_1].value).toBe(updateParams.[field_1])
      expect(updatedEntity.[field_2]).toBe(updateParams.[field_2])
      expect(updatedEntity.[field_3]).toBe('original_value') // sin cambios
      expect(updatedEntity.updatedAt).not.toBe(entity.updatedAt)
    })
  })

  describe('domain methods', () => {
    it('should execute [domainMethod] correctly', () => {
      // Arrange
      const entity = [EntityName].create(/* valid params */)

      // Act
      const result = entity.[domainMethod](/* params */)

      // Assert
      expect(result).toBe(/* expected result */)
    })
  })
})
```

#### Pruebas de Objetos de Valor
```typescript
// test/modules/[module]/domain/value-objects/[ValueObject].spec.ts
describe('[ValueObject]', () => {
  describe('constructor', () => {
    it('should create value object with valid value', () => {
      // Arrange
      const validValue = 'valid_value'

      // Act
      const valueObject = new [ValueObject](validValue)

      // Assert
      expect(valueObject.value).toBe(validValue)
    })

    it('should normalize value if applicable', () => {
      // Arrange
      const inputValue = '  VALID_VALUE  '

      // Act
      const valueObject = new [ValueObject](inputValue)

      // Assert
      expect(valueObject.value).toBe('valid_value') // normalizado
    })

    it('should throw [ValidationError] with invalid value', () => {
      // Arrange
      const invalidValues = [
        'invalid1',
        'invalid2',
        '',
        null,
        undefined
      ]

      // Act & Assert
      invalidValues.forEach(invalidValue => {
        expect(() => new [ValueObject](invalidValue)).toThrow([ValidationError])
      })
    })
  })

  describe('equals', () => {
    it('should return true for equal values', () => {
      // Arrange
      const value1 = new [ValueObject]('test')
      const value2 = new [ValueObject]('test')

      // Act & Assert
      expect(value1.equals(value2)).toBe(true)
    })

    it('should return false for different values', () => {
      // Arrange
      const value1 = new [ValueObject]('test1')
      const value2 = new [ValueObject]('test2')

      // Act & Assert
      expect(value1.equals(value2)).toBe(false)
    })
  })
})
```

#### Pruebas de Servicios de Dominio
```typescript
// test/modules/[module]/domain/services/[DomainService].spec.ts
describe('[DomainService]', () => {
  let service: [DomainService]
  let mockRepository: jest.Mocked<[RepositoryInterface]>

  beforeEach(() => {
    mockRepository = createMock[RepositoryInterface]()
    service = new [DomainService](mockRepository)
  })

  describe('[methodName]', () => {
    it('should validate business rule successfully', async () => {
      // Arrange
      const params = {/* valid params */}
      mockRepository.findBy[UniqueField].mockResolvedValue(null)

      // Act
      await service.[methodName](params)

      // Assert
      expect(mockRepository.findBy[UniqueField]).toHaveBeenCalledWith(params.[field])
    })

    it('should throw [BusinessRuleError] when rule is violated', async () => {
      // Arrange
      const params = {/* params that violate rule */}
      const existingEntity = createMock[Entity]()
      mockRepository.findBy[UniqueField].mockResolvedValue(existingEntity)

      // Act & Assert
      await expect(service.[methodName](params)).rejects.toThrow([BusinessRuleError])
    })
  })
})
```

### 2. Application Tests
Pruebas de casos de uso y handlers con dependencias mockeadas.

#### Pruebas de Handlers
```typescript
// test/modules/[module]/application/handlers/[HandlerName].spec.ts
describe('[HandlerName]', () => {
  let handler: [HandlerName]
  let mockRepository: jest.Mocked<[RepositoryInterface]>
  let mockDomainService: jest.Mocked<[DomainServiceInterface]>
  let mockEventBus: jest.Mocked<EventBus>

  beforeEach(() => {
    mockRepository = createMock[RepositoryInterface]()
    mockDomainService = createMock[DomainServiceInterface]()
    mockEventBus = createMockEventBus()
    handler = new [HandlerName](mockRepository, mockDomainService, mockEventBus)
  })

  describe('handle', () => {
    it('should handle command successfully', async () => {
      // Arrange
      const command = new [CommandType](
        'valid_param1',
        'valid_param2',
        'valid_param3'
      )

      const expectedEntity = [EntityFactory].create({
        [field_1]: command.[field_1],
        [field_2]: command.[field_2],
        [field_3]: command.[field_3]
      })

      mockRepository.findBy[UniqueField].mockResolvedValue(null)
      mockDomainService.validate[Rule].mockReturnValue()
      mockRepository.save.mockResolvedValue()
      mockEventBus.publish.mockResolvedValue()

      // Act
      const result = await handler.handle(command)

      // Assert
      expect(result).toBeInstanceOf([ResponseType])
      expect(result.[field_1]).toBe(command.[field_1])
      expect(result.[field_2]).toBe(command.[field_2])
      expect(result.[field_3]).toBe(command.[field_3])

      expect(mockRepository.save).toHaveBeenCalledTimes(1)
      expect(mockEventBus.publish).toHaveBeenCalledWith(
        expect.any([DomainEvent])
      )
    })

    it('should throw [DomainException] when [condition] occurs', async () => {
      // Arrange
      const command = new [CommandType](
        'existing_value', // Este valor ya existe
        'valid_param2',
        'valid_param3'
      )

      const existingEntity = [EntityFactory].create({
        [unique_field]: 'existing_value'
      })

      mockRepository.findBy[UniqueField].mockResolvedValue(existingEntity)

      // Act & Assert
      await expect(handler.handle(command)).rejects.toThrow([DomainException])
      expect(mockRepository.save).not.toHaveBeenCalled()
      expect(mockEventBus.publish).not.toHaveBeenCalled()
    })

    it('should log appropriate messages', async () => {
      // Arrange
      const command = new [CommandType]('valid', 'valid', 'valid')
      const mockLogger = { log: jest.fn(), error: jest.fn() }

      mockRepository.findBy[UniqueField].mockResolvedValue(null)
      mockDomainService.validate[Rule].mockReturnValue()
      mockRepository.save.mockResolvedValue()

      const handlerWithLogger = new [HandlerName](
        mockRepository,
        mockDomainService,
        mockEventBus,
        mockLogger
      )

      // Act
      await handlerWithLogger.handle(command)

      // Assert
      expect(mockLogger.log).toHaveBeenCalledWith(
        expect.stringContaining('Iniciando [operation]'),
        expect.objectContaining({
          [field]: command.[field]
        })
      )
    })
  })
})
```

### 3. Infrastructure Tests
Pruebas de implementación de infraestructura con test doubles.

#### Pruebas de Repositorios
```typescript
// test/modules/[module]/infrastructure/persistence/repositories/[RepositoryImplementation].spec.ts
describe('[RepositoryImplementation]', () => {
  let repository: [RepositoryImplementation]
  let mockDataSource: jest.Mocked<DataSource>
  let mockQueryRunner: jest.Mocked<QueryRunner>

  beforeEach(async () => {
    mockDataSource = createMockDataSource()
    mockQueryRunner = createMockQueryRunner()
    
    const module = await Test.createTestingModule({
      providers: [
        [RepositoryImplementation],
        {
          provide: DataSource,
          useValue: mockDataSource
        }
      ]
    }).compile()

    repository = module.get([RepositoryImplementation])
  })

  describe('save', () => {
    it('should save entity successfully', async () => {
      // Arrange
      const domainEntity = [EntityFactory].create()
      const expectedEntity = [EntityMapper].toEntity(domainEntity)

      const mockRepository = {
        save: jest.fn().mockResolvedValue(undefined)
      }
      mockDataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act
      await repository.save(domainEntity)

      // Assert
      expect(mockRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          [field_1]: domainEntity.[field_1].value,
          [field_2]: domainEntity.[field_2]
        })
      )
    })

    it('should handle database errors', async () => {
      // Arrange
      const domainEntity = [EntityFactory].create()
      const dbError = new Error('Database connection failed')

      const mockRepository = {
        save: jest.fn().mockRejectedValue(dbError)
      }
      mockDataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act & Assert
      await expect(repository.save(domainEntity)).rejects.toThrow(
        InfrastructureError
      )
    })
  })

  describe('findBy[UniqueField]', () => {
    it('should return entity when found', async () => {
      // Arrange
      const searchValue = new [ValueObject]('search_value')
      const expectedEntity = createMock[Entity]()

      const mockRepository = {
        findOne: jest.fn().mockResolvedValue(expectedEntity)
      }
      mockDataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act
      const result = await repository.findBy[UniqueField](searchValue)

      // Assert
      expect(result).toBeInstanceOf([DomainEntity])
      expect(result?.[field].value).toBe(searchValue.value)
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { [unique_field]: searchValue.value }
      })
    })

    it('should return null when not found', async () => {
      // Arrange
      const searchValue = new [ValueObject]('notfound_value')

      const mockRepository = {
        findOne: jest.fn().mockResolvedValue(null)
      }
      mockDataSource.getRepository.mockReturnValue(mockRepository as any)

      // Act
      const result = await repository.findBy[UniqueField](searchValue)

      // Assert
      expect(result).toBeNull()
    })
  })
})
```

### 4. Integration Tests
Pruebas de integración entre múltiples componentes.

#### API Integration Tests
```typescript
// test/integration/[module].spec.ts
describe('[Module] API Integration', () => {
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
    await seedTestData(dataSource)
  })

  afterEach(async () => {
    await dataSource.dropDatabase()
  })

  afterAll(async () => {
    await app.close()
  })

  describe('POST /[endpoint]', () => {
    it('should create entity successfully', async () => {
      // Arrange
      const createDto = {
        [field_1]: 'valid_value_1',
        [field_2]: 'valid_value_2',
        [field_3]: 'valid_value_3'
      }

      // Act
      const response = await request(app.getHttpServer())
        .post('/[endpoint]')
        .send(createDto)
        .expect(201)

      // Assert
      expect(response.body).toMatchObject({
        [field_1]: createDto.[field_1],
        [field_2]: createDto.[field_2],
        [field_3]: createDto.[field_3]
      })
      expect(response.body.id).toBeDefined()
      expect(response.body.createdAt).toBeDefined()

      // Verify in database
      const entity = await dataSource.getRepository([EntityName]Entity).findOne({
        where: { id: response.body.id }
      })
      expect(entity).toBeTruthy()
    })

    it('should return 400 for invalid data', async () => {
      // Arrange
      const invalidDto = {
        [field_1]: 'invalid_value',
        [field_2]: '', // empty required field
        [field_3]: null // null required field
      }

      // Act & Assert
      await request(app.getHttpServer())
        .post('/[endpoint]')
        .send(invalidDto)
        .expect(400)
    })

    it('should return 409 for duplicate [unique_field]', async () => {
      // Arrange
      const createDto = {
        [unique_field]: 'duplicate_value',
        [field_2]: 'valid_value_2',
        [field_3]: 'valid_value_3'
      }

      // Create first entity
      await request(app.getHttpServer())
        .post('/[endpoint]')
        .send(createDto)
        .expect(201)

      // Act & Assert
      await request(app.getHttpServer())
        .post('/[endpoint]')
        .send(createDto)
        .expect(409)
    })
  })

  describe('GET /[endpoint]/:id', () => {
    it('should return entity when found', async () => {
      // Arrange
      const entity = await createTestEntity(dataSource)
      
      // Act
      const response = await request(app.getHttpServer())
        .get(`/[endpoint]/${entity.id}`)
        .expect(200)

      // Assert
      expect(response.body.id).toBe(entity.id)
      expect(response.body.[field_1]).toBe(entity.[field_1])
    })

    it('should return 404 when not found', async () => {
      // Arrange
      const nonExistentId = generateUUID()
      
      // Act & Assert
      await request(app.getHttpServer())
        .get(`/[endpoint]/${nonExistentId}`)
        .expect(404)
    })
  })
})

async function seedTestData(dataSource: DataSource): Promise<void> {
  // Crear datos de prueba consistentes
}
```

### 5. E2E Tests
Pruebas end-to-end completas del flujo de usuario.

#### E2E Test
```typescript
// test/e2e/[module]-lifecycle.spec.ts
describe('[Module] E2E Lifecycle', () => {
  let app: INestApplication

  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule]
    }).compile()

    app = module.createNestApplication()
    await app.init()
  })

  afterAll(async () => {
    await app.close()
  })

  describe('Complete Entity Lifecycle', () => {
    it('should manage complete entity lifecycle', async () => {
      let entityId: string

      // 1. Create entity
      const createResponse = await request(app.getHttpServer())
        .post('/[endpoint]')
        .send({
          [field_1]: 'lifecycle_test@example.com',
          [field_2]: 'Test',
          [field_3]: 'Entity',
          [field_4]: 'Password123!'
        })
        .expect(201)

      entityId = createResponse.body.id
      expect(entityId).toBeDefined()

      // 2. Get entity
      const getResponse = await request(app.getHttpServer())
        .get(`/[endpoint]/${entityId}`)
        .expect(200)

      expect(getResponse.body.id).toBe(entityId)
      expect(getResponse.body.[field_1]).toBe('lifecycle_test@example.com')

      // 3. Update entity
      await request(app.getHttpServer())
        .patch(`/[endpoint]/${entityId}`)
        .send({
          [field_2]: 'Updated',
          [field_3]: 'Entity'
        })
        .expect(200)

      // 4. Verify update
      const updatedResponse = await request(app.getHttpServer())
        .get(`/[endpoint]/${entityId}`)
        .expect(200)

      expect(updatedResponse.body.[field_2]).toBe('Updated')
      expect(updatedResponse.body.[field_3]).toBe('Entity')
      expect(updatedResponse.body.updatedAt).not.toBe(getResponse.body.updatedAt)

      // 5. Delete entity
      await request(app.getHttpServer())
        .delete(`/[endpoint]/${entityId}`)
        .expect(204)

      // 6. Verify deletion
      await request(app.getHttpServer())
        .get(`/[endpoint]/${entityId}`)
        .expect(404)
    })
  })
})
```

## Test Utilities

### Mock Factories
```typescript
// test/shared/factories/[EntityFactory].ts
export class [EntityFactory] {
  static create(overrides?: Partial<[CreateParams]>): [DomainEntity] {
    const params: [CreateParams] = {
      [field_1]: 'default_value_1',
      [field_2]: 'default_value_2',
      [field_3]: 'default_value_3',
      ...overrides
    }

    return [DomainEntity].create(params)
  }

  static createMany(count: number, overrides?: Partial<[CreateParams]>): [DomainEntity][] {
    return Array.from({ length: count }, (_, index) => 
      this.create({
        [field_1]: `test_${index}@example.com`,
        ...overrides
      })
    )
  }

  static withId(id: string, overrides?: Partial<[CreateParams]>): [DomainEntity] {
    const entity = this.create(overrides)
    // Usar reflexión o factory method para establecer ID
    return [DomainEntity].fromSnapshot({
      id,
      ...entity,
      ...overrides
    })
  }
}
```

### Test Helpers
```typescript
// test/shared/helpers/[TestHelpers].ts
export class [TestHelpers] {
  static async createTestEntity(
    repository: [RepositoryInterface],
    overrides?: Partial<[CreateParams]>
  ): Promise<[DomainEntity]> {
    const entity = [EntityFactory].create(overrides)
    await repository.save(entity)
    return entity
  }

  static assertEntityEquals(actual: [DomainEntity], expected: [DomainEntity]): void {
    expect(actual.id.value).toBe(expected.id.value)
    expect(actual.[field_1].value).toBe(expected.[field_1].value)
    expect(actual.[field_2]).toBe(expected.[field_2])
    expect(actual.[field_3]).toBe(expected.[field_3])
  }

  static createMock[RepositoryInterface](): jest.Mocked<[RepositoryInterface]> {
    return {
      save: jest.fn(),
      findById: jest.fn(),
      findBy[UniqueField]: jest.fn(),
      findAll: jest.fn(),
      delete: jest.fn(),
      existsBy[UniqueField]: jest.fn()
    }
  }

  static async waitForCondition(
    condition: () => Promise<boolean>,
    timeout: number = 5000,
    interval: number = 100
  ): Promise<void> {
    const startTime = Date.now()
    
    while (Date.now() - startTime < timeout) {
      if (await condition()) {
        return
      }
      await new Promise(resolve => setTimeout(resolve, interval))
    }
    
    throw new Error(`Condition not met within ${timeout}ms`)
  }
}
```

### Mock Data
```typescript
// test/shared/mocks/[MockData].ts
export const [MOCK_DATA] = {
  validEntity: {
    [field_1]: 'valid@example.com',
    [field_2]: 'John',
    [field_3]: 'Doe'
  },
  
  invalidEntity: {
    [field_1]: 'invalid-email',
    [field_2]: '',
    [field_3]: null
  },
  
  createCommands: {
    valid: {
      [field_1]: 'create@example.com',
      [field_2]: 'Jane',
      [field_3]: 'Smith'
    },
    
    duplicate: {
      [field_1]: 'duplicate@example.com',
      [field_2]: 'Duplicate',
      [field_3]: 'Test'
    }
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
    '!src/**/*.module.ts',
    '!src/**/__mocks__/**'
  ],
  coverageThreshold: {
    global: {
      branches: 100,
      functions: 100,
      lines: 100,
      statements: 100
    },
    './src/modules/[module]/': {
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
  },
  testTimeout: 10000,
  verbose: true
}
```

### Test Setup
```typescript
// test/setup.ts
import 'jest-extended'

// Configuración global de tests
beforeAll(() => {
  // Configuración previa a todos los tests
})

afterAll(() => {
  // Limpieza posterior a todos los tests
})

// Configuración de mocks globales
jest.mock('[external-service]', () => ({
  // Mock implementation
}))
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
    "test:application": "jest --testPathPattern=application",
    "test:infrastructure": "jest --testPathPattern=infrastructure",
    "test:integration": "jest --testPathPattern=integration",
    "test:e2e": "jest --testPathPattern=e2e",
    "test:ci": "jest --coverage --ci --watchAll=false --passWithNoTests",
    "test:debug": "node --inspect-brk node_modules/.bin/jest --runInBand"
  }
}
```

---

**Esta estrategia de pruebas garantiza calidad, confiabilidad y mantenimiento del código [Module] con 100% de cobertura.**