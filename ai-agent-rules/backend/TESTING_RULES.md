---
name: testing_rules
description: Mandatory rules for unit and integration testing in NestJS projects using Jest and TypeScript.
priority: highest
---
# TESTING RULES (NestJS + Jest + TypeScript)

These rules define **how tests MUST be written**.
They are mandatory whenever generating, modifying, or reviewing `*.spec.ts` files.

These rules apply regardless of the current session phase if tests are involved.

---

## 🎯 Primary Objective

The objective is to achieve **100% test coverage** for the specified function, class, or use case in:

- Statements
- Branches
- Functions
- Lines

Coverage MUST be achieved **exclusively through tests**.

❌ Source files (`*.ts`) MUST NOT be modified to increase coverage.
❌ Disabling coverage rules is forbidden.

---

## 🧱 Source Code Integrity

- NEVER modify production source files to satisfy coverage.
- ALL changes must be done in the corresponding `*.spec.ts`.
- Do NOT suggest refactors or code changes to “make testing easier”.
- Tests must adapt to the code, not the other way around.

---

## 🧪 Test Scope (Mandatory Coverage)

Tests MUST cover **all execution paths**, including:

### ✅ Happy Path

- Valid inputs
- Expected outputs
- Normal execution flow

### ❌ Error & Exception Paths

- Thrown errors
- Domain exceptions
- Guard clause failures
- Infrastructure failures (when applicable)

### ⚠️ Edge & Boundary Cases

- `null`
- `undefined`
- Empty arrays / empty objects
- Invalid values
- Boundary numeric values
- Unexpected but valid inputs

### 🔀 Control Flow

- `if / else`
- `switch`
- ternary expressions
- early returns
- `try / catch / finally`

Every conditional branch MUST be asserted at least once.

---

## 🧠 Architectural Awareness

Tests MUST respect architectural boundaries:

### Domain

- No framework imports (NestJS, TypeORM, HTTP).
- No mocks for pure domain logic.
- Deterministic, side-effect free tests.

### Application (Use Cases / Handlers)

- Dependencies MUST be mocked.
- No real IO (DB, HTTP, FS).
- Focus on orchestration and decision logic.

### Infrastructure

- Can use integration tests.
- Explicit setup and teardown required.
- No hidden dependencies.

---

## 🧰 Mocking Rules

- Reuse existing mocks and helpers if present:
  - `shared-mocks.ts`
  - `test-helpers.ts`
  - `mock-factories.ts`
- NEVER duplicate mock logic across tests.
- NEVER redefine the same dependency differently in multiple tests.
- Prefer factory functions for test data.

If no shared utilities exist:

- Create reusable helper functions **inside the spec file**.
- Do NOT inline complex mocks.

---

## 🧾 Logging & Tracing Validation

If the tested code performs logging or tracing:

### Logging

- Spy on logger methods using `jest.spyOn`
- Explicitly assert calls, including payloads:

```ts
expect(logger.log).toHaveBeenCalledWith(
  JSON.stringify(expectedObject, null, 2)
);
```

* NEVER ignore logging side effects.

### Tracing

If tracing is used (`tracer`, `span`, etc.):

* Assert span creation
* Assert span closure
* Assert error tagging when applicable

---

## 🧪 Test Structure & Style

### Structure

* Follow **Arrange – Act – Assert (AAA)** strictly.
* One main assertion per test whenever possible.
* Test names MUST describe business behavior, not implementation.

### Naming

* Test files: `*.spec.ts`
* Describe blocks reflect the unit under test.
* Avoid generic names like “should work”.

---

## 🧪 Promise & Async Safety

* NEVER leave floating promises.
* Always `await` async calls.
* Explicitly assert rejected promises using:

<pre class="overflow-visible! px-0!" data-start="3813" data-end="3863"><div class="contain-inline-size rounded-2xl corner-superellipse/1.1 relative bg-token-sidebar-surface-primary"><div class="sticky top-[calc(--spacing(9)+var(--header-height))] @w-xl/main:top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span><span class="hljs-keyword">await</span></span><span> </span><span><span class="hljs-title function_">expect</span></span><span>(promise).</span><span><span class="hljs-property">rejects</span></span><span>.</span><span><span class="hljs-title function_">toThrow</span></span><span>();
</span></span></code></div></div></pre>

---

## 📊 Coverage Expectations

* Minimum target: **100%** for the specified unit.
* Coverage must include:
  * Happy path
  * Main error path
  * Boundary conditions

Tests that only increase coverage numbers without asserting behavior are invalid.

---

## ❌ Anti-Patterns (Forbidden)

* ❌ Snapshot tests for business logic
* ❌ Testing private methods directly
* ❌ Mocking the unit under test
* ❌ Real network, filesystem, or database access in unit tests
* ❌ Disabling ESLint or Jest rules without justification

---

## ✅ Definition of Done (Testing)

A test suite is considered DONE only if:

* All tests pass
* Coverage is 100% for the target
* Architectural boundaries are respected
* Logs and traces are asserted when present
* Tests are readable and maintainable
* No production code was modified

---

## 🛑 Failure Handling

If achieving 100% coverage is not possible:

* Explicitly state WHY
* Identify the blocking condition
* Do NOT guess or fabricate tests
* Ask for clarification ONLY if execution is blocked

---

These testing rules are **non-negotiable** and override convenience or speed.
