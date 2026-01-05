# Modelo de Dominio - User Management

## Entidades

### User
Entidad principal que representa a un usuario del sistema.

```typescript
class User {
  id: UserId
  email: Email
  firstName: string
  lastName: string
  password: Password
  role: UserRole
  status: UserStatus
  createdAt: Date
  updatedAt: Date
}
```

#### Atributos

| Atributo | Tipo | Descripción | Reglas |
|----------|------|-------------|--------|
| id | UserId | Identificador único | UUID v4, inmutable |
| email | Email | Correo electrónico | Único, case-insensitive |
| firstName | string | Nombre | Obligatorio, max 50 |
| lastName | string | Apellido | Obligatorio, max 50 |
| password | Password | Contraseña encriptada | Mínimo 8 caracteres |
| role | UserRole | Rol del usuario | ADMIN, USER, MANAGER |
| status | UserStatus | Estado del usuario | ACTIVE, INACTIVE, SUSPENDED |
| createdAt | Date | Fecha de creación | Inmutable |
| updatedAt | Date | Fecha de actualización | Automática |

## Objetos de Valor

### UserId
Identificador único de usuario.

```typescript
class UserId {
  value: string
  
  constructor(value: string) {
    if (!isValidUUID(value)) {
      throw new InvalidUserIdError(value)
    }
    this.value = value
  }
}
```

### Email
Objeto de valor para email con validación.

```typescript
class Email {
  value: string
  
  constructor(value: string) {
    const normalized = value.toLowerCase().trim()
    if (!isValidEmail(normalized)) {
      throw new InvalidEmailError(normalized)
    }
    this.value = normalized
  }
  
  equals(other: Email): boolean {
    return this.value === other.value
  }
}
```

### Password
Objeto de valor para contraseña con encriptación.

```typescript
class Password {
  private hashedValue: string
  
  constructor(plainText: string) {
    if (!isValidPassword(plainText)) {
      throw new InvalidPasswordError()
    }
    this.hashedValue = bcrypt.hash(plainText)
  }
  
  static fromHash(hashedValue: string): Password {
    const password = new Password()
    password.hashedValue = hashedValue
    return password
  }
  
  verify(plainText: string): boolean {
    return bcrypt.compare(plainText, this.hashedValue)
  }
  
  getHash(): string {
    return this.hashedValue
  }
}
```

### UserRole
Enumeración de roles de usuario.

```typescript
enum UserRole {
  ADMIN = 'ADMIN',
  USER = 'USER',
  MANAGER = 'MANAGER'
}

class UserRoleValue {
  value: UserRole
  
  constructor(value: string) {
    if (!Object.values(UserRole).includes(value as UserRole)) {
      throw new InvalidUserRoleError(value)
    }
    this.value = value as UserRole
  }
  
  canCreateRole(targetRole: UserRole): boolean {
    if (this.value === UserRole.ADMIN) return true
    if (this.value === UserRole.MANAGER && targetRole === UserRole.USER) return true
    return false
  }
}
```

### UserStatus
Enumeración de estados de usuario.

```typescript
enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED'
}

class UserStatusValue {
  value: UserStatus
  
  constructor(value: string = UserStatus.ACTIVE) {
    if (!Object.values(UserStatus).includes(value as UserStatus)) {
      throw new InvalidUserStatusError(value)
    }
    this.value = value as UserStatus
  }
  
  canAuthenticate(): boolean {
    return this.value === UserStatus.ACTIVE
  }
}
```

## Reglas de Dominio

### Unicidad de Email
- Dos usuarios no pueden tener el mismo email
- La comparación es case-insensitive
- Espacios en blanco son removidos

### Validación de Password
- Mínimo 8 caracteres
- Al menos una letra mayúscula
- Al menos un número
- Al menos un carácter especial

### Jerarquía de Roles
- ADMIN puede crear cualquier rol
- MANAGER solo puede crear USER
- USER no puede crear usuarios

### Estados y Autenticación
- Solo usuarios ACTIVE pueden autenticarse
- Usuarios INACTIVE no pueden iniciar sesión
- Usuarios SUSPENDED tienen acceso bloqueado

## Excepciones de Dominio

```typescript
class DomainError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'DomainError'
  }
}

class InvalidUserIdError extends DomainError {}
class InvalidEmailError extends DomainError {}
class InvalidPasswordError extends DomainError {}
class InvalidUserRoleError extends DomainError {}
class InvalidUserStatusError extends DomainError {}
class EmailAlreadyExistsError extends DomainError {}
```

## Servicios de Dominio

### UserDomainService
Servicio que contiene lógica de dominio compleja.

```typescript
interface UserDomainService {
  validateEmailUniqueness(email: Email, existingUsers: User[]): void
  validatePasswordStrength(password: string): void
  canCreateUser(creatorRole: UserRole, targetRole: UserRole): boolean
}
```

---

**Este modelo de dominio define las reglas de negocio y estructura de datos para User Management.**