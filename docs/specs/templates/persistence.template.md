# SPEC Template - Persistence Strategy

## Tecnología de Persistencia

### Base de Datos
- **Motor**: [PostgreSQL/MySQL/MongoDB/etc.] [Versión]
- **ORM**: [TypeORM/Prisma/Mongoose/etc.]
- **Connection Pool**: [Configuración de pool]
- **Migrations**: [Herramienta y estrategia]
- **Seeders**: [Estrategia para datos iniciales]

### Configuración de Conexión
```typescript
// infrastructure/config/DatabaseConfig.ts
export const databaseConfig: TypeOrmModuleOptions = {
  type: '[database_type]',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'user',
  password: process.env.DB_PASSWORD || 'password',
  database: process.env.DB_NAME || 'database',
  
  // Configuración del pool
  extra: {
    max: 20,                    // Máximo de conexiones
    min: 5,                     // Mínimo de conexiones
    acquire: 30000,             // Tiempo máximo para adquirir conexión (ms)
    idle: 10000,                // Tiempo máximo de inactividad (ms)
    evict: 1000,                // Intervalo de revisión (ms)
    handleDisconnects: true     // Manejar desconexiones
  },
  
  // Otras configuraciones
  synchronize: process.env.NODE_ENV === 'development',
  logging: process.env.NODE_ENV === 'development',
  entities: ['dist/**/*.entity.js'],
  migrations: ['dist/migrations/*.js'],
}
```

## Diseño de Tablas

### Tabla Principal: [table_name]
```sql
CREATE TABLE [table_name] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    [field_1] [type] [constraints],
    [field_2] [type] [constraints],
    [field_3] [type] [constraints],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX idx_[table_name]_[field_1] ON [table_name]([field_1]);
CREATE INDEX idx_[table_name]_[field_2] ON [table_name]([field_2]);
CREATE INDEX idx_[table_name]_[field_3] ON [table_name]([field_3]);
CREATE INDEX idx_[table_name]_created_at ON [table_name](created_at);

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_[table_name]_updated_at 
    BEFORE UPDATE ON [table_name] 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

### Tablas Relacionadas (si aplica)
```sql
-- [related_table_1]
CREATE TABLE [related_table_1] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    [table_name]_id UUID NOT NULL REFERENCES [table_name](id) ON DELETE CASCADE,
    [field_1] [type] [constraints],
    [field_2] [type] [constraints],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- [related_table_2]
CREATE TABLE [related_table_2] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    [table_name]_id UUID NOT NULL REFERENCES [table_name](id) ON DELETE CASCADE,
    [field_1] [type] [constraints],
    [field_2] [type] [constraints],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para tablas relacionadas
CREATE INDEX idx_[related_table_1]_[table_name]_id ON [related_table_1]([table_name]_id);
CREATE INDEX idx_[related_table_2]_[table_name]_id ON [related_table_2]([table_name]_id);
```

## Entidades TypeORM

### Entidad Principal
```typescript
// infrastructure/persistence/entities/[EntityName]Entity.ts
@Entity('[table_name]')
export class [EntityName]Entity {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ type: '[type]', length: [length], unique: [true/false] })
  [field_1]: [type]

  @Column({ type: '[type]', length: [length] })
  [field_2]: [type]

  @Column({ type: '[type]', nullable: [true/false] })
  [field_3]: [type]

  @Column({
    type: 'enum',
    enum: [EnumType],
    default: [DefaultValue]
  })
  [enum_field]: [EnumType]

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date

  // Relaciones (si aplica)
  @OneToMany(() => [RelatedEntity1], entity => entity.[relation_field])
  [related_entities_1]: [RelatedEntity1][]

  @OneToMany(() => [RelatedEntity2], entity => entity.[relation_field])
  [related_entities_2]: [RelatedEntity2][]
}
```

### Entidades Relacionadas
```typescript
// infrastructure/persistence/entities/[RelatedEntity1]Entity.ts
@Entity('[related_table_1]')
export class [RelatedEntity1]Entity {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ name: '[table_name]_id' })
  [table_name]_id: string

  @Column({ type: '[type]', length: [length] })
  [field_1]: [type]

  @Column({ type: '[type]', length: [length] })
  [field_2]: [type]

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date

  // Relación inversa
  @ManyToOne(() => [EntityName]Entity, entity => entity.[related_entities_1])
  @JoinColumn({ name: '[table_name]_id', referencedColumnName: 'id' })
  [parent_entity]: [EntityName]Entity
}
```

## Mappers (Domain ↔ Infrastructure)

### Mapper Principal
```typescript
// infrastructure/persistence/mappers/[EntityName]Mapper.ts
export class [EntityName]Mapper {
  static toEntity(domain: [DomainEntity]): [EntityName]Entity {
    const entity = new [EntityName]Entity()
    entity.id = domain.id.value
    entity.[field_1] = domain.[field_1].value  // Si es Value Object
    entity.[field_2] = domain.[field_2]          // Si es tipo primitivo
    entity.[field_3] = domain.[field_3]?.getValue() // Si tiene getter especial
    entity.[enum_field] = domain.[enum_field].value
    entity.createdAt = domain.createdAt
    entity.updatedAt = domain.updatedAt
    
    // Mapear relaciones si aplica
    if (domain.[related_entities_1]) {
      entity.[related_entities_1] = domain.[related_entities_1].map(
        [RelatedEntity1]Mapper.toEntity
      )
    }
    
    return entity
  }

  static toDomain(entity: [EntityName]Entity): [DomainEntity] {
    return new [DomainEntity](
      new [IdType](entity.id),
      new [VO1Type](entity.[field_1]),           // Value Object
      entity.[field_2],                           // Primitivo
      entity.[field_3] ? new [VO3Type](entity.[field_3]) : null,
      new [EnumVOType](entity.[enum_field]),
      entity.createdAt,
      entity.updatedAt,
      // Mapear relaciones si aplica
      entity.[related_entities_1] 
        ? entity.[related_entities_1].map([RelatedEntity1]Mapper.toDomain)
        : []
    )
  }

  // Para actualizaciones parciales
  static toPartialEntity(domain: [DomainEntity]): Partial<[EntityName]Entity> {
    return {
      [field_1]: domain.[field_1]?.value,
      [field_2]: domain.[field_2],
      [field_3]: domain.[field_3]?.getValue(),
      [enum_field]: domain.[enum_field]?.value,
      updatedAt: new Date()
    }
  }
}
```

### Mapper para Entidades Relacionadas
```typescript
// infrastructure/persistence/mappers/[RelatedEntity1]Mapper.ts
export class [RelatedEntity1]Mapper {
  static toEntity(domain: [RelatedDomainEntity]): [RelatedEntity1]Entity {
    const entity = new [RelatedEntity1]Entity()
    entity.id = domain.id.value
    entity.[table_name]_id = domain.[parent_id].value
    entity.[field_1] = domain.[field_1]
    entity.[field_2] = domain.[field_2]
    entity.createdAt = domain.createdAt
    entity.updatedAt = domain.updatedAt
    return entity
  }

  static toDomain(entity: [RelatedEntity1]Entity): [RelatedDomainEntity] {
    return new [RelatedDomainEntity](
      new [IdType](entity.id),
      new [ParentIdType](entity.[table_name]_id),
      entity.[field_1],
      entity.[field_2],
      entity.createdAt,
      entity.updatedAt
    )
  }
}
```

## Implementación del Repositorio

### Repositorio Principal
```typescript
// infrastructure/persistence/repositories/[TypeOrm][RepositoryName].ts
@Injectable()
export class [TypeOrm][RepositoryName] implements [RepositoryName] {
  constructor(
    @InjectRepository([EntityName]Entity)
    private readonly repository: Repository<[EntityName]Entity>
  ) {}

  async save(domain: [DomainEntity]): Promise<void> {
    const entity = [EntityName]Mapper.toEntity(domain)
    await this.repository.save(entity)
  }

  async findById(id: [IdType]): Promise<[DomainEntity] | null> {
    const entity = await this.repository.findOne({
      where: { id: id.value },
      relations: ['[related_entities_1]', '[related_entities_2]'] // Si aplica
    })
    
    return entity ? [EntityName]Mapper.toDomain(entity) : null
  }

  async findBy[UniqueField]([uniqueField]: [VOType]): Promise<[DomainEntity] | null> {
    const entity = await this.repository.findOne({
      where: { [uniqueField]: [uniqueField].value }
    })
    
    return entity ? [EntityName]Mapper.toDomain(entity) : null
  }

  async findAll(): Promise<[DomainEntity][]> {
    const entities = await this.repository.find({
      relations: ['[related_entities_1]', '[related_entities_2]']
    })
    return entities.map(entity => [EntityName]Mapper.toDomain(entity))
  }

  async delete(id: [IdType]): Promise<void> {
    await this.repository.delete({ id: id.value })
  }

  async existsBy[UniqueField]([uniqueField]: [VOType]): Promise<boolean> {
    const count = await this.repository.count({
      where: { [uniqueField]: [uniqueField].value }
    })
    return count > 0
  }

  // Métodos específicos del dominio si son necesarios
  async findBy[CustomField]([field]: [Type]): Promise<[DomainEntity][]> {
    const entities = await this.repository.find({
      where: { [field]: [field] }
    })
    return entities.map(entity => [EntityName]Mapper.toDomain(entity))
  }

  // Paginación
  async findAllPaginated(page: number, limit: number): Promise<{
    data: [DomainEntity][]
    total: number
    page: number
    limit: number
  }> {
    const [data, total] = await this.repository.findAndCount({
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' }
    })

    return {
      data: data.map(entity => [EntityName]Mapper.toDomain(entity)),
      total,
      page,
      limit
    }
  }
}
```

## Migraciones

### Migration Inicial
```typescript
// migrations/[timestamp]_create_[table_name]_table.ts
import { MigrationInterface, QueryRunner, Table, Index } from 'typeorm'

export class Create[TableName]Table1640000000001 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: '[table_name]',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'gen_random_uuid()'
          },
          {
            name: '[field_1]',
            type: 'varchar',
            length: '255',
            isUnique: true
          },
          {
            name: '[field_2]',
            type: 'varchar',
            length: '50'
          },
          {
            name: '[enum_field]',
            type: 'enum',
            enum: ['[VALUE1]', '[VALUE2]', '[VALUE3]'],
            default: '("[VALUE1]")'
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
            name: 'IDX_[TABLE_NAME]_[FIELD_1]',
            columnNames: ['[field_1]']
          },
          {
            name: 'IDX_[TABLE_NAME]_[FIELD_2]',
            columnNames: ['[field_2]']
          },
          {
            name: 'IDX_[TABLE_NAME]_CREATED_AT',
            columnNames: ['created_at']
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
      CREATE TRIGGER update_[table_name]_updated_at 
          BEFORE UPDATE ON [table_name] 
          FOR EACH ROW 
          EXECUTE FUNCTION update_updated_at_column();
    `)
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('[table_name]')
  }
}
```

### Migration para Tablas Relacionadas
```typescript
// migrations/[timestamp]_create_[related_table]_table.ts
export class Create[RelatedTable]Table1640000000002 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: '[related_table]',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'gen_random_uuid()'
          },
          {
            name: '[table_name]_id',
            type: 'uuid',
            isNullable: false
          },
          // ... otros campos
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
        foreignKeys: [
          {
            columnNames: ['[table_name]_id'],
            referencedTableName: '[table_name]',
            referencedColumnNames: ['id'],
            onDelete: 'CASCADE'
          }
        ]
      }),
      true
    )
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('[related_table]')
  }
}
```

## Seeders

### Seeder Principal
```typescript
// infrastructure/seeders/[EntityName]Seeder.ts
export class [EntityName]Seeder {
  constructor(
    private readonly repository: [TypeOrm][RepositoryName],
    private readonly [relatedService]: [RelatedService] // Si aplica
  ) {}

  async seed(): Promise<void> {
    const [entities] = [
      // Datos de prueba
    ]

    for (const [entityData] of [entities]) {
      const [entity] = [DomainEntity].create([entityData])
      await this.repository.save([entity])
    }
  }

  async clear(): Promise<void> {
    await this.repository.delete({})
  }
}
```

## Performance y Optimización

### Queries Optimizadas
```typescript
// Query con campos específicos
async findByIdOptimized(id: [IdType]): Promise<[DomainEntity] | null> {
  const entity = await this.repository.findOne({
    where: { id: id.value },
    select: [
      'id', '[field_1]', '[field_2]', '[enum_field]', 
      'createdAt', 'updatedAt'
    ]
  })
  
  return entity ? [EntityName]Mapper.toDomain(entity) : null
}

// Query con joins optimizados
async findWith[Related](id: [IdType]): Promise<[DomainEntity] | null> {
  const entity = await this.repository
    .createQueryBuilder('entity')
    .leftJoinAndSelect('entity.[related_entities_1]', 'related1')
    .leftJoinAndSelect('entity.[related_entities_2]', 'related2')
    .where('entity.id = :id', { id: id.value })
    .getOne()
  
  return entity ? [EntityName]Mapper.toDomain(entity) : null
}
```

### Transacciones
```typescript
async createWithTransaction(command: [CommandType]): Promise<[DomainEntity]> {
  return await this.repository.manager.transaction(async manager => {
    // Validar unicidad
    const existing = await manager.findOne([EntityName]Entity, {
      where: { [uniqueField]: command.[uniqueField] }
    })
    
    if (existing) {
      throw new [DomainException]('[uniqueField] already exists')
    }

    // Crear entidad principal
    const [domainEntity] = [DomainEntity].create(command)
    const entity = [EntityName]Mapper.toEntity([domainEntity])
    
    const savedEntity = await manager.save([EntityName]Entity, entity)
    
    // Crear entidades relacionadas si aplica
    if (command.[related_entities]) {
      const [relatedEntities] = command.[related_entities].map(([relatedData]) => 
        [RelatedDomainEntity].create({
          ...[relatedData],
          [parent_id]: new [ParentIdType](savedEntity.id)
        })
      )

      for (const [relatedEntity] of [relatedEntities]) {
        const [relatedEntityDB] = [RelatedEntity1]Mapper.toEntity([relatedEntity])
        await manager.save([RelatedEntity1]Entity, [relatedEntityDB])
      }
    }
    
    return [domainEntity]
  })
}
```

## Backup y Recovery

### Strategy de Backup
```typescript
// infrastructure/backup/BackupStrategy.ts
export class BackupStrategy {
  async createBackup(): Promise<string> {
    // Lógica para crear backup
  }

  async restoreBackup(backupId: string): Promise<void> {
    // Lógica para restaurar backup
  }

  async verifyBackup(backupId: string): Promise<boolean> {
    // Lógica para verificar integridad del backup
  }
}
```

---

**Esta estrategia de persistencia garantiza performance, escalabilidad y consistencia de datos para [Module].**