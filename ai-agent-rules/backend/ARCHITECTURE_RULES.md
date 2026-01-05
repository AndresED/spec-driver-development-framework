---
name: arch_rules
description: Enforces Clean Architecture, Hexagonal Architecture and CQRS boundaries for NestJS backend projects.
---

# BACKEND ARCHITECTURE RULES (NestJS)

These rules define mandatory architectural boundaries and structural constraints
for backend projects. They must be respected whenever architecture, structure,
or design decisions are discussed or implemented.

---

## Architecture Style

All backend implementations MUST follow:

- Clean Architecture
- Hexagonal Architecture (Ports & Adapters)
- CQRS where applicable
- Domain-Driven Design (tactical level)

---

## Layered Architecture Responsibilities

### Controllers (Interface Layer)

- Must be thin
- No business logic
- Handle HTTP concerns only (request/response)
- Delegate all logic to application layer

---

### Application Layer (Use Cases / Commands / Queries / Handlers)

- Contains business orchestration logic
- Implements use cases
- Coordinates domain services and repositories
- Independent of HTTP, Express, or NestJS internals

---

### Domain Layer

- Entities, value objects, domain services
- Pure business rules
- Framework-agnostic
- No persistence, HTTP, or logging concerns

---

### Infrastructure Layer

- Persistence implementations
- ORM models and mappings
- External service adapters
- Implements repository interfaces (ports)

---

## Dependency Rules (Non-Negotiable)

- Controllers → Application
- Application → Domain
- Infrastructure → Domain
- Domain → nothing

❌ Reverse dependencies are forbidden.

---

## DTOs & Validation

- Use DTOs for all external inputs
- Validate using `class-validator` and `class-transformer`
- Enforce a global `ValidationPipe` with:
  - `whitelist: true`
  - `forbidNonWhitelisted: true`
  - `transform: true`

---

## Error Handling

- Use centralized exception handling
- Preserve error context and stack traces
- Never throw string literals
- Do not leak sensitive information in error responses

---

## Persistence & Performance

- Paginate all list endpoints
- Avoid N+1 queries
- Add indexes for frequently queried fields
- Process large datasets using streaming or pagination
- Repositories must expose minimal, intention-revealing APIs

---

## External Boundaries

All outbound calls (HTTP, DB, FS, third-party services) MUST:

- Define explicit timeouts
- Handle retries with backoff when appropriate
- Support cancellation where possible
- Preserve error context

---

## Security

- Enable Helmet
- Configure CORS using an allowlist
- Enable rate limiting
- Sanitize all inputs
- Never build SQL queries via string concatenation
- Always use parameterized queries

---

## Domain Boundaries Enforcement

- Controllers must not contain business rules
- Application services must not depend on NestJS or Express internals
- Repositories must not leak ORM entities or persistence models

---

## Deviation Handling

If the current structure deviates from these rules:

1. Explicitly explain **WHY**
2. Describe the architectural impact
3. Propose a refactor aligned with these rules

Silent acceptance of violations is forbidden.
