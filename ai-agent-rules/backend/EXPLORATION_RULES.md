---
id: exploration_rules
apply_when:
  - user_message_contains:
      - "exploration_rules"
      - "explora"
      - "analiza"
      - "analiza repo"
      - "estructura del proyecto"
      - "repository"
      - "repo"
priority: high
---

# EXPLORATION & REPOSITORY ANALYSIS RULES

These rules define how the agent MUST explore, analyze, and understand an existing codebase
BEFORE proposing changes, writing code, or creating tests.

Skipping this phase is strictly forbidden.

---

## 1. Mandatory Exploration Phase

Before generating any code, tests, or refactors, the agent MUST:

1. Inspect the folder structure
2. Identify:
   - Framework (e.g. NestJS)
   - Architecture style (Clean, Hexagonal, etc.)
3. Detect existing conventions and patterns
4. Locate reusable utilities, helpers, and mocks
5. Identify testing strategy already in use

If any of these steps are skipped → the response is invalid.

---

## 2. Files and Folders to Identify First

The agent MUST actively search for and understand:

- `src/`
- `test/` or `__tests__/`
- `*.spec.ts`
- `shared-mocks.ts`
- `test-helpers.ts`
- `mock-factories.ts`
- `jest.config.*`
- `tsconfig.json`
- `.eslintrc*`
- `.prettierrc*`

If these files exist, they MUST be reused.

---

## 3. Architecture Awareness

The agent MUST infer and respect:

- Layered architecture:
  - Controllers
  - Services / Use Cases
  - Repositories
- NestJS module boundaries
- Dependency Injection patterns
- Providers and injection tokens
- Existing error-handling strategies

The agent MUST NOT:
- Invent new layers
- Move responsibilities arbitrarily
- Break architectural boundaries

---

## 4. Analysis Before Action

Before proposing a solution, the agent MUST analyze:

- Code smells
- Architectural violations
- Performance risks
- Security risks
- Responsibility leaks between layers

All suggestions MUST be grounded in observed code.

---

## 5. Refactoring Rules

Refactors may be proposed ONLY when:

- Complexity limits are exceeded
- Responsibilities are mixed
- Architectural boundaries are violated
- Duplication is clearly identified

Refactors MUST be:
- Incremental
- Justified
- Aligned with existing architecture

Avoid over-engineering.

---

## 6. Testing Awareness

Before writing tests, the agent MUST:

- Search for existing tests for the same module
- Reuse existing mocks, spies, and helpers
- Match existing test structure and naming conventions
- Identify how logging, tracing, and external services are mocked

If a testing pattern exists → it MUST be reused.

---

## 7. Test Coverage Guidance

When suggesting or writing tests, consider:

- Happy path
- Main error path
- Edge and boundary cases

Always distinguish clearly between:
- Unit tests
- Integration tests
- e2e tests

---

## 8. Mocking Rules

- Never redefine mocks that already exist
- Never mock the same dependency differently across tests
- Centralize mocks when possible
- Prefer factory functions for test data

---

## 9. Import and Path Rules

- Respect existing path aliases (`@app/*`, `@domain/*`, etc.)
- Do NOT introduce new aliases without justification
- Follow existing import ordering and style

---

## 10. Questions & Assumptions

- Ask
