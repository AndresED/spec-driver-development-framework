# User Management - Create User

## Visión General

Implementar la funcionalidad de creación de usuarios en el sistema de gestión de usuarios.

## Requisitos Funcionales

### RF-001: Creación de Usuario
- El sistema debe permitir crear nuevos usuarios
- Los usuarios deben tener email único
- Los usuarios deben tener nombre y apellido
- Los usuarios deben tener rol asignado
- Los usuarios deben tener estado (activo/inactivo)

### RF-002: Validación de Datos
- Email debe ser válido y único
- Nombre y apellido son obligatorios
- Rol debe existir en el sistema
- Estado por defecto: activo

### RF-003: Respuesta del Sistema
- Retorna usuario creado con ID
- Retorna error si email ya existe
- Retorna error si datos inválidos

## Requisitos No Funcionales

### RNF-001: Seguridad
- Password debe encriptarse
- Email no debe exponerse en logs
- Validación de entrada obligatoria

### RNF-002: Performance
- Respuesta < 500ms
- Transacción atómica
- Validación antes de persistencia

## Casos de Uso

### UC-001: Crear Usuario Exitoso
```
Actor: Sistema
Precondición: Datos válidos y email único
Pasos:
1. Recibir datos de usuario
2. Validar formato de email
3. Verificar email no existe
4. Encriptar password
5. Crear entidad usuario
6. Persistir usuario
7. Retornar usuario creado
Postcondición: Usuario creado y persistido
```

### UC-002: Email Duplicado
```
Actor: Sistema
Precondición: Email ya existe
Pasos:
1. Recibir datos de usuario
2. Validar formato de email
3. Verificar email existe
4. Lanzar excepción de email duplicado
Postcondición: Error retornado, no se crea usuario
```

### UC-003: Datos Inválidos
```
Actor: Sistema
Precondición: Datos inválidos
Pasos:
1. Recibir datos de usuario
2. Validar datos requeridos
3. Lanzar excepción de validación
Postcondición: Error retornado, no se crea usuario
```

## Reglas de Negocio

### RN-001: Unicidad de Email
- Cada email solo puede asociarse a un usuario activo
- Email case-insensitive
- Email trim automático

### RN-002: Roles de Usuario
- Roles válidos: ADMIN, USER, MANAGER
- Rol por defecto: USER
- Solo ADMIN puede crear otros ADMIN

### RN-003: Estados de Usuario
- Estados válidos: ACTIVE, INACTIVE, SUSPENDED
- Estado por defecto: ACTIVE
- Usuario INACTIVE no puede autenticarse

## Integraciones

### Base de Datos
- Tabla: users
- Índice único: email
- Campos encriptados: password

### Servicios Externos
- Email service (notificaciones)
- Audit service (logs)

---

**Este SPEC es la fuente de verdad para la implementación de Create User.**