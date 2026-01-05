# Estrategia de Persistencia - User Management

## Tecnología de Persistencia

### Base de Datos Relacional (PostgreSQL)
- **Motor**: PostgreSQL 14+
- **ORM**: TypeORM
- **Pool**: pg-pool con configuración optimizada
- **Migraciones**: TypeORM Migrations
- **Seeders**: Datos iniciales para desarrollo

## Diseño de Tablas

### Tabla: users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'USER', 'MANAGER')),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Entidades TypeORM

### UserEntity
```typescript
// infrastructure/persistence/entities/UserEntity.ts
@Entity('users')
export class UserEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ type: 'varchar', length: 255, unique: true })
  email: string

  @Column({ type: 'varchar', length: 50 })
  firstName: string

  @Column({ type: 'varchar', length: 50 })
  lastName: string

  @Column({ type: 'varchar', length: 255, name: 'password_hash' })
  passwordHash: string

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.USER
  })
  role: UserRole

  @Column({
    type: 'enum',
    enum: UserStatus,
    default: UserStatus.ACTIVE
  })
  status: UserStatus

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date
}
```

## Mappers (Domain ↔ Infrastructure)

### UserMapper
```typescript
// infrastructure/persistence/mappers/UserMapper.ts
export class UserMapper {
  static toEntity(user: User): UserEntity {
    const entity = new UserEntity()
    entity.id = user.id.value
    entity.email = user.email.value
    entity.firstName = user.firstName
    entity.lastName = user.lastName
    entity.passwordHash = user.password.getHash()
    entity.role = user.role.value
    entity.status = user.status.value
    entity.createdAt = user.createdAt
    entity.updatedAt = user.updatedAt
    return entity
  }

  static toDomain(entity: UserEntity): User {
    return new User(
      new UserId(entity.id),
      new Email(entity.email),
      entity.firstName,
      entity.lastName,
      Password.fromHash(entity.passwordHash),
      new UserRoleValue(entity.role),
      new UserStatusValue(entity.status),
      entity.createdAt,
      entity.updatedAt
    )
  }
}
```

## Implementación del Repositorio

### TypeOrmUserRepository
```typescript
// infrastructure/persistence/repositories/TypeOrmUserRepository.ts
@Injectable()
export class TypeOrmUserRepository implements UserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repository: Repository<UserEntity>
  ) {}

  async save(user: User): Promise<void> {
    const entity = UserMapper.toEntity(user)
    await this.repository.save(entity)
  }

  async findById(id: UserId): Promise<User | null> {
    const entity = await this.repository.findOne({
      where: { id: id.value }
    })
    
    return entity ? UserMapper.toDomain(entity) : null
  }

  async findByEmail(email: Email): Promise<User | null> {
    const entity = await this.repository.findOne({
      where: { email: email.value }
    })
    
    return entity ? UserMapper.toDomain(entity) : null
  }

  async findAll(): Promise<User[]> {
    const entities = await this.repository.find()
    return entities.map(entity => UserMapper.toDomain(entity))
  }

  async delete(id: UserId): Promise<void> {
    await this.repository.delete({ id: id.value })
  }

  async existsByEmail(email: Email): Promise<boolean> {
    const count = await this.repository.count({
      where: { email: email.value }
    })
    return count > 0
  }
}
```

## Configuración de TypeORM

### Database Configuration
```typescript
// infrastructure/config/DatabaseConfig.ts
export const databaseConfig: TypeOrmModuleOptions = {
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'user_management',
  entities: [UserEntity],
  migrations: ['dist/migrations/*.js'],
  synchronize: process.env.NODE_ENV === 'development',
  logging: process.env.NODE_ENV === 'development',
  extra: {
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  }
}
```

## Migraciones

### Initial Migration
```typescript
// migrations/001_create_users_table.ts
import { MigrationInterface, QueryRunner, Table } from 'typeorm'

export class CreateUsersTable1640000000001 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'users',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'gen_random_uuid()'
          },
          {
            name: 'email',
            type: 'varchar',
            length: '255',
            isUnique: true
          },
          {
            name: 'first_name',
            type: 'varchar',
            length: '50'
          },
          {
            name: 'last_name',
            type: 'varchar',
            length: '50'
          },
          {
            name: 'password_hash',
            type: 'varchar',
            length: '255'
          },
          {
            name: 'role',
            type: 'enum',
            enum: ['ADMIN', 'USER', 'MANAGER'],
            default: '"USER"'
          },
          {
            name: 'status',
            type: 'enum',
            enum: ['ACTIVE', 'INACTIVE', 'SUSPENDED'],
            default: '"ACTIVE"'
          },
          {
            name: 'created_at',
            type: 'timestamp with time zone',
            default: 'now()'
          },
          {
            name: 'updated_at',
            type: 'timestamp with time zone',
            default: 'now()'
          }
        ],
        indices: [
          {
            name: 'IDX_USERS_EMAIL',
            columnNames: ['email']
          },
          {
            name: 'IDX_USERS_ROLE',
            columnNames: ['role']
          },
          {
            name: 'IDX_USERS_STATUS',
            columnNames: ['status']
          }
        ]
      }),
      true
    )

    // Crear trigger para updated_at
    await queryRunner.query(`
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW.updated_at = NOW();
          RETURN NEW;
      END;
      $$ language 'plpgsql';
    `)

    await queryRunner.query(`
      CREATE TRIGGER update_users_updated_at 
          BEFORE UPDATE ON users 
          FOR EACH ROW 
          EXECUTE FUNCTION update_updated_at_column();
    `)
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('users')
  }
}
```

## Seeders

### UserSeeder
```typescript
// infrastructure/seeders/UserSeeder.ts
export class UserSeeder {
  constructor(
    private readonly repository: TypeOrmUserRepository,
    private readonly passwordService: PasswordService
  ) {}

  async seed(): Promise<void> {
    const adminPassword = new Password('Admin123!')
    const userPassword = new Password('User123!')

    const admin = User.create({
      email: new Email('admin@example.com'),
      firstName: 'System',
      lastName: 'Administrator',
      password: adminPassword,
      role: new UserRoleValue(UserRole.ADMIN),
      status: new UserStatusValue(UserStatus.ACTIVE)
    })

    const user = User.create({
      email: new Email('user@example.com'),
      firstName: 'Regular',
      lastName: 'User',
      password: userPassword,
      role: new UserRoleValue(UserRole.USER),
      status: new UserStatusValue(UserStatus.ACTIVE)
    })

    await this.repository.save(admin)
    await this.repository.save(user)
  }
}
```

## Performance y Optimización

### Connection Pool
```typescript
// Configuración optimizada de pool
const poolConfig = {
  max: 20,                    // Máximo de conexiones
  min: 5,                     // Mínimo de conexiones
  acquire: 30000,             // Tiempo máximo para adquirir conexión
  idle: 10000,                // Tiempo máximo de inactividad
  evict: 1000,                // Intervalo de revisión
  handleDisconnects: true     // Manejar desconexiones
}
```

### Query Optimization
```typescript
// Queries optimizadas con índices
async findByEmailOptimized(email: Email): Promise<User | null> {
  const entity = await this.repository.findOne({
    where: { email: email.value },
    select: ['id', 'email', 'firstName', 'lastName', 'role', 'status', 'createdAt', 'updatedAt']
  })
  
  return entity ? UserMapper.toDomain(entity) : null
}
```

### Transacciones
```typescript
async createUserWithTransaction(command: CreateUserCommand): Promise<User> {
  return await this.repository.manager.transaction(async manager => {
    // Validar email único
    const existing = await manager.findOne(UserEntity, {
      where: { email: command.email }
    })
    
    if (existing) {
      throw new EmailAlreadyExistsError(command.email)
    }

    // Crear usuario
    const user = User.create(command)
    const entity = UserMapper.toEntity(user)
    
    await manager.save(UserEntity, entity)
    
    return user
  })
}
```

## Backup y Recovery

### Backup Strategy
- **Daily Backups**: Full backup diario
- **Point-in-Time Recovery**: WAL logs para recuperación precisa
- **Retention**: 30 días de backups
- **Testing**: Tests mensuales de restauración

### Monitoring
- **Connection Pool**: Monitoreo de conexiones activas
- **Query Performance**: Logs de consultas lentas (>500ms)
- **Disk Space**: Alertas de espacio en disco
- **Replication Lag**: Si se usa replicación

---

**Esta estrategia de persistencia garantiza performance, escalabilidad y consistencia de datos para User Management.**