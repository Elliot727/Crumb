# Crumb

A tiny, Swift-native HTTP framework built on SwiftNIO.

Crumb aims to be small enough to read in an afternoon: async/await handlers, Swift 6 strict concurrency, and no magic.

> **Status: pre-alpha.** Crumb is not usable yet. The package builds, but there is no server code. Follow the roadmap below.

## Goals

- **Small.** A minimal core you can understand end to end.
- **Swift 6 native.** Strict concurrency, `Sendable` throughout, async/await handlers.
- **Built on SwiftNIO.** Fast, battle-tested networking underneath.
- **Linux and macOS.** Runs where Swift servers actually get deployed.

## Planned API

This is a sketch of where Crumb is heading, not working code yet.

```swift
import Crumb

let app = Crumb()

app.get("/hello/:name") { request in
    "Hello, \(request.parameters["name"] ?? "world")!"
}

try await app.run(port: 8080)
```

## Requirements

- Swift 6.4 or later
- macOS 14+ or Linux (Ubuntu 22.04 / 24.04)

## Getting started

```bash
git clone https://github.com/Elliot727/Crumb.git
cd Crumb
swift build
swift test
swift run HelloCrumb
```

## Roadmap to v0.1

- [x] Package scaffold
- [ ] HTTP server bootstrap
- [ ] Request and Response types
- [ ] Routing with path parameters
- [ ] Middleware
- [ ] Codable / JSON support
- [ ] Graceful shutdown
- [ ] CI on macOS and Linux
- [ ] Docs and examples

Work is tracked in Linear and linked to PRs by ticket ID (for example `SWI-5`).

## Estimation scale (points)

| Points | Size |
|---|---|
| 1 | Under an hour |
| 2 | An evening |
| 3 | A couple of evenings |
| 5 | About a week of evenings |
| 8 | Too big, so split it |

## Contributing

Crumb is early and moving fast. Issues and ideas are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
