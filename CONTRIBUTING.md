# Contributing to Crumb

Thanks for your interest in Crumb! It's early and moving fast, so small, focused contributions are the most helpful.

## Getting set up

You need Swift 6.4 or later.

```bash
git clone https://github.com/Elliot727/Crumb.git
cd Crumb
swift build
swift test
```

### Testing on Linux

Crumb targets Linux as well as macOS. With Docker installed:

```bash
docker run --rm -v "$PWD":/code -w /code swift:6.4-jammy swift test --build-path .build-linux
```

## Workflow

1. Pick or open an issue. Work is tracked in Linear by ticket ID (for example `SWI-53`).
2. Create a branch named `swi-<id>-short-description`, for example `swi-53-contributing`.
3. Keep each PR small, with one ticket per PR.
4. Open a PR against `main`. Put the ticket ID in the title and `Closes SWI-<id>` in the description.
5. PRs are squash-merged, so the PR title becomes the commit on `main`.

## Commit messages and PR titles

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <short summary>
```

Use one of these types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`.

For example:

- `feat(server): add NIO bootstrap`
- `fix(routing): match trailing slashes`
- `docs: SWI-53 add CONTRIBUTING`

Commits on your branch can be as messy as you like. Only the PR title needs to follow this format.

## Code style

- Swift 6 language mode with strict concurrency. Don't add unsafe flags or `@unchecked Sendable` without a comment explaining why.
- Avoid Apple-only APIs (full Foundation, Combine) in the `Crumb` target, so Linux keeps working.
- Every public symbol needs a doc comment.
- No compiler warnings.
- Formatting and linting are enforced by swift-format and SwiftLint (coming in SWI-51).

## File headers

Every Swift file starts with:

```swift
// Copyright 2026 Elliot Silver
// SPDX-License-Identifier: Apache-2.0
```

## Tests

- Use Swift Testing (`import Testing`), not XCTest.
- New behaviour comes with tests, and `swift test` must pass on macOS and Linux.

## License

By contributing, you agree that your contributions are licensed under the [Apache License 2.0](LICENSE).
