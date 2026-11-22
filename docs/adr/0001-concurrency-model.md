# ADR 0001: Concurrency model

- **Status:** Accepted
- **Date:** 2026-11-22
- **Ticket:** SWI-50

## Context

Crumb is an HTTP framework built on SwiftNIO and written in Swift 6 language mode with strict concurrency. Before writing the server bootstrap (SWI-6), we need to decide how network I/O meets user code.

SwiftNIO offers two models:

- **`ChannelHandler`**: event-driven callbacks (`channelRead`, `write`, `errorCaught`) that run on an `EventLoop` inside a `ChannelPipeline`.
- **`NIOAsyncChannel`**: wraps a `Channel` and exposes inbound data as an `AsyncSequence` and outbound data as an async writer, so code runs in Swift Concurrency.

These are not alternatives. `NIOAsyncChannel` installs bridge handlers into the pipeline and sits on top of it. SwiftNIO's guidance is to use handlers for protocol work and `NIOAsyncChannel` for application logic.

Requirements that matter for Crumb:

1. Users write handlers with `async`/`await` and never see `EventLoop`, `EventLoopFuture`, `NIOAny` or `ChannelHandlerContext`.
2. Everything public is `Sendable` and compiles cleanly under Swift 6 strict concurrency.
3. Backpressure works end to end, so a slow handler slows reading instead of buffering without limit.
4. Graceful shutdown can stop accepting connections, let in-flight requests finish, then exit.
5. It works the same on macOS and Linux.

## Decision

Crumb uses **ChannelHandlers for protocol work** and **`NIOAsyncChannel` at the boundary to application code**. Everything users write is async/await.

### Layers

```
User route handlers         async (Request) throws -> Response
Crumb router / middleware   async, Sendable
Connection loop             NIOAsyncChannel<HTTPServerRequestPart, HTTPServerResponsePart>
ChannelPipeline             NIO HTTP/1.1 handlers (decoder, encoder, pipelining, error handling)
Socket                      NIOPosix ServerBootstrap
```

### Details

- **Bootstrap.** `ServerBootstrap` from NIOPosix binds the listening socket and uses `bind(host:port:childChannelInitializer:)` to configure each child channel and wrap it as an `NIOAsyncChannel`. The server channel itself is consumed as an async sequence of connections.
- **Protocol handling.** Each connection's pipeline uses `configureHTTPServerPipeline()` from NIOHTTP1. Crumb writes no HTTP parser.
- **One task per connection.** The server runs a `withThrowingDiscardingTaskGroup`, and every accepted connection gets a child task. A failure in one connection is caught and logged inside its task and never cancels the group.
- **Request loop.** Inside the connection task, `executeThenClose { inbound, outbound in ... }` iterates `HTTPServerRequestPart`s, assembles a `Request` (head, then body, then end), calls the router, and writes the `Response` as `.head`, `.body`, `.end`. Requests on one connection are handled in order (HTTP/1.1 pipelining stays sequential).
- **Backpressure.** We rely on `NIOAsyncChannel`'s built-in backpressure. Reading only continues while the loop is consuming, and writes suspend while the writer is busy. Body size limits (Security project) are enforced while the body is assembled.
- **Sendability.** `Request`, `Response`, `Router` and middleware are `Sendable` value types or immutable final classes. No `@unchecked Sendable` without a comment explaining why. No user code runs on an EventLoop.
- **Shutdown.** Cancelling the task group stops accepting connections. Graceful shutdown (Reliability project) adds a drain phase on top of this structure. Wiring `swift-service-lifecycle` is out of scope here.
- **Logging.** A `Logger` from swift-log is attached per connection and per request with metadata (connection id, request id).

## Consequences

### Positive

- Users only write async/await code, and the API surface never exposes NIO types.
- Structured concurrency gives clear lifetimes: a connection's work ends when its task ends, and shutdown is cancellation.
- Strict concurrency checking covers user code and Crumb's code.
- NIO's battle-tested HTTP/1.1 handlers do the parsing, so there's less code to get wrong.
- The same shape as Hummingbird 2 and newer Vapor internals, so there's prior art to learn from.

### Negative / trade-offs

- `NIOAsyncChannel` hides writability changes and arbitrary user events. Features that need them (fine-grained streaming, WebSocket upgrades, idle timeouts) must add a custom `ChannelHandler` to the pipeline or use NIO's upgrade APIs.
- Hopping between the EventLoop and Swift Concurrency costs some performance compared with pure handlers. That's acceptable for v0.1. The Performance project will measure it before anything is tuned.
- One task per connection means many idle keep-alive connections each hold a task. That's cheap, but idle timeouts are needed (Reliability project).

## Alternatives considered

1. **Pure ChannelHandlers with EventLoopFuture-based user handlers.** Fastest, but it exposes futures and EventLoops to users and conflicts with the Swift 6 async-first goal. Rejected.
2. **Pure ChannelHandlers internally, bridging each request to async with `Task {}`.** Unstructured tasks lose cancellation and backpressure and make shutdown hard. Rejected.
3. **Building on Hummingbird or Vapor.** Defeats the purpose of Crumb being a small, readable framework of its own. Rejected.

## References

- [SwiftNIO: Public async APIs](https://github.com/apple/swift-nio/blob/main/docs/public-async-nio-apis.md)
- [SwiftNIO repository](https://github.com/apple/swift-nio)
- Swift 6 strict concurrency (SE-0337, SE-0412)
