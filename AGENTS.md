# AGENTS.md

This file provides guidance to code agents when working with code in this repository.

## Project Overview

**Shelf Plus** is a quality-of-life addon for Dart's Shelf web server framework. It provides a high-level abstraction layer on top of `shelf_router` that simplifies response handling, middleware usage, and server initialization while maintaining full compatibility with the Shelf ecosystem.

## Common Development Commands

### Running Tests
```bash
dart test                    # Run all tests
dart test test/router_plus_test.dart  # Run specific test file
```

### Running Examples
```bash
dart run example/example.dart                        # Run basic example
dart run example/example_rest/bin/example_rest.dart  # Run REST API example
dart run example/example_websocket_chat/bin/example_websocket_chat.dart  # Run WebSocket chat example

# Enable hot-reload during development
dart run --enable-vm-service example/example.dart
```

### Code Generation
For examples using `json_serializable` (like the REST example with Person model):
```bash
dart run build_runner build  # Generate serialization code (creates .g.dart files)
```

### Linting
```bash
dart analyze  # Run static analysis
```

### Updating Documentation
**IMPORTANT**: The README.md file is **generated** and should NOT be edited directly.

The project uses `readme_helper` to compile the README from source files:
```bash
# Install or update readme_helper
flutter pub global activate readme_helper

# Regenerate README.md from template
flutter pub global run readme_helper
```

The README.md uses these directives:
- `<!-- #code path/to/file.dart -->` - Embeds code from `doc_files/` directory
- `<!-- #toc -->` - Auto-generates table of contents from headers
- `<!-- #include path/to/file.md -->` - Includes other markdown files

**To update the README:**
1. Edit the code examples in `doc_files/*.dart`
2. Edit the markdown content in README.md (between the directive blocks)
3. Run `flutter pub global run readme_helper` to regenerate
4. Commit both the source files and the regenerated README.md

## Core Architecture

### 1. ResponseHandler System
The ResponseHandler mechanism is the heart of Shelf Plus. It's a **progressive type resolution system** that transforms any return value into a Shelf `Response` through multiple passes:

- Route handlers can return **any type** (String, Map, custom objects, Files, etc.)
- The `resolveResponse()` function iteratively applies registered `ResponseHandler` functions
- Each handler checks if it can process the current result type and transforms it
- This continues until a Shelf `Response` is produced (max 20 iterations)
- Built-in handlers (in `lib/src/router_plus/response_handler/`):
  - `string_handler.dart` - converts String to text/plain Response
  - `json_handler.dart` - converts Maps, Lists, and objects with `toJson()` to JSON
  - `binary_handler.dart` - handles Uint8List and Stream<List<int>>
  - `file_handler.dart` - serves File objects using shelf_static
  - `web_socket_handler.dart` - manages WebSocketSession upgrades
  - `shelf_handler_handler.dart` - allows returning shelf Handler/Middleware

Custom ResponseHandlers can be registered via middleware using the `.middleware` getter on a ResponseHandler function.

### 2. RouterPlus Wrapper
Located in `lib/src/router_plus/router_plus.dart`:

- **Wraps** `shelf_router` without replacing it - delegates to underlying Router
- The `_RouterPlusHandler` class adapts flexible function signatures:
  - Handlers can take zero parameters: `() => 'response'`
  - Just Request: `(Request request) => 'response'`
  - Request + route params: `(Request request, String id) => 'response: $id'`
  - Uses `Function.apply()` with reflection to match signatures
- **Middleware injection**: Both global (`use()`) and per-route (`use:` parameter)
  - Global middleware must be registered before any routes
  - Per-route middleware combines global + local middleware
  - Middleware can also be applied dynamically inside handlers using `>>` operator

### 3. Request Body Handling
Located in `lib/src/request_body_accessor.dart`:

- Extension on `Request` provides `.body` getter that returns `RequestBodyAccessor`
- Built-in accessors: `asString`, `asJson`, `asBinary`
- Generic deserializer: `as<T>(reviver)` - pass a static fromJson method
- **Extensible**: Create custom accessors by extending `RequestBodyAccessor`

### 4. Shelf Run - Zero-Config Server
Located in `lib/src/shelf_run.dart`:

- `shelfRun(init)` takes an init function that returns a Handler
- **Hot-reload support** via shelf_hotreload (enabled by default when running with vm-service)
- Environment variable configuration:
  - `SHELF_PORT` (default: 8080)
  - `SHELF_ADDRESS` (default: localhost)
  - `SHELF_HOTRELOAD` (default: true)
  - `SHELF_SHARED` (default: false) - enables multi-isolate support
- Returns `ShelfRunContext` for programmatic server control

## File Structure

**IMPORTANT**: This file structure overview must be kept up to date whenever files are added, removed, renamed, or reorganized in the project. Update this section as part of any structural changes.

```
lib/
├── shelf_plus.dart                    # Main export file
└── src/
    ├── request_body_accessor.dart     # Request body parsing
    ├── shelf_run.dart                 # Server initialization
    └── router_plus/
        ├── router_plus.dart           # RouterPlus implementation
        ├── middleware_extension.dart  # Middleware combinators (+ operator)
        ├── middlewares.dart           # Built-in middleware (setContentType, download, etc.)
        ├── cascade_helper.dart        # Cascade utility
        ├── shelf_request_extension.dart  # Request extensions (routeParameter)
        └── response_handler/
            ├── response_handler.dart      # Core ResponseHandler logic
            ├── string_handler.dart
            ├── json_handler.dart
            ├── binary_handler.dart
            ├── file_handler.dart
            ├── web_socket_handler.dart
            ├── shelf_handler_handler.dart
            └── web_socket/
                └── web_socket_session.dart

test/
├── router_plus_test.dart          # Route handling and middleware tests
├── request_body_accessor_test.dart  # Body parsing tests
├── shelf_run_test.dart            # Server initialization tests
└── util/test_helper.dart          # Test utilities (TestServer)
```

## Key Design Patterns

### The `>>` Operator Pattern
Middleware can be applied inline using the `>>` operator (defined in `middleware_extension.dart`):
```dart
app.get('/html', () => typeByExtension('html') >> '<h1>Hello</h1>');
app.get('/file', () => download(filename: 'data.pdf') >> File('doc.pdf'));
```

### Middleware Combination
The `+` operator combines middleware (also in `middleware_extension.dart`):
```dart
app.get('/route', () => 'response', use: middlewareA + middlewareB);
```

### Handler Signature Flexibility
The `_RouterPlusHandler._handler()` method uses try-catch with `NoSuchMethodError` to detect correct signature:
1. Try: `handler(request, ...routeParams)`
2. If fails, try: `handler()`
3. If fails, try: `handler(request)`

This allows users to omit parameters they don't need.

## Testing Patterns

- Tests use `TestServer` helper (in `test/util/test_helper.dart`) for server lifecycle
- Always tear down servers: `tearDown(() async => await server.stop())`
- Use `server.fetchBody<T>()` for making test requests
- WebSocket tests use `web_socket_channel` package

## Important Notes

- **Hot-reload requires an init function**: The handler must be created in a separate init function, not inline
- **Global middleware must come first**: Calling `use()` after adding routes throws an error
- **WebSocketSession subprotocol**: The `subprotocol` property is available on WebSocketSession for protocol negotiation
- **ResponseHandler ordering**: Custom handlers registered via middleware are evaluated AFTER built-in handlers
- **File serving**: Uses shelf_static internally, so File responses respect that package's behavior