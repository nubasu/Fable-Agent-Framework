---
name: test-protocol
description: Write tests that actually catch bugs — behavior over implementation, fail-first proof (never trust a test you haven't seen red), minimal mocking, mandatory boundary and error-path coverage, deterministic construction, flaky elimination, characterization tests before changing untested code. Use when writing or modifying tests, when a change needs coverage, or when a suite is green but untrustworthy.
---

# test-protocol — a test is a claim that must be able to fail

## 1. What to test, at which level

- Test the behavior a caller observes at the boundary — outcomes, not internals. Asserting "method X was called" tests your implementation, unless the call IS the contract (an email sent, a payment charged).
- Pick the lowest level that exercises the behavior naturally: pure logic → unit; component interplay → integration; user-critical flows → a few E2E. A unit test needing more than ~3 mocks is an integration test in denial.
- Coverage order, risk-first: the contract's acceptance criteria → boundaries (empty / 0 / 1 / max / duplicates) → error paths (throws, timeout, partial data) → state & concurrency where applicable. A happy-path-only suite is a demo, not tests.
- Do not test the framework or library itself — test YOUR logic around it.

## 2. Prove it can fail — the fail-first rule

- New test: watch it FAIL before making it pass. Writing the test after the fix? Temporarily revert the fix (stash) or mutate the logic, and watch the test go red once. **A test you have never seen red proves nothing** — it may be asserting nothing.
- The failure output must point at the cause: assert concrete values (`expected 3, got 0`), never bare truthiness.

## 3. Mock discipline

- Mock only what you do not own or cannot run deterministically: network, clock, randomness, external services. For your own code, use the real thing where feasible.
- If configuring the mock means re-encoding the collaborator's exact behavior, you are testing the mock — use the real collaborator, or move up a test level.
- Never assert on the internal wiring of the unit under test.

## 4. Quality bar

- Arrange-Act-Assert visible; one behavior per test; the name states behavior and condition (`rejects_expired_token`), never `test_1`.
- In tests, readability beats DRY: a reader should understand the test without chasing helpers; magic values get names.
- Deterministic by construction: control clock, randomness, and ordering. A `sleep` in a test is a race condition admitted in writing — wait on conditions, not on time.

## 5. Flaky tests

- Flaky = a real bug in the test or the code, never weather. Run it N times to measure the rate, then apply `root-cause-debug`. Retry-until-green hides real races.
- Quarantine only with a ticket and a named follow-up. "It was already flaky before my change" requires proof on a clean baseline — same rule as `finish-gate`.

## 6. Changing code that has no tests

- Write a characterization test FIRST: pin the current behavior — even if it looks wrong — then change deliberately. Pinning wrong behavior and fixing it in a separate, visible step beats changing blind.
