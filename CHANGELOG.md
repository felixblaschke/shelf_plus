## 1.10.0

- Upgraded dependencies (thanks to [pulyaevskiy](https://github.com/pulyaevskiy))
- Update code in examples

## 1.9.2

- Use thread-safe `print` on startup (thanks to [0rzech](https://github.com/0rzech))

## 1.9.1

- Fixed CORS example (thanks to [kliuchev](https://github.com/kliuchev))

## 1.9.0

- Upgrade dependencies

## 1.8.0

- `shelfRun()` lifecycle hooks `onWillClose` and `onClosed` supports asynchronous execution
- Fixed: server does not stop, when hotreload is set to false

## 1.7.0

- Added `onWillClose` to `shelfRun()` lifecycle hook.
- Added `onClosed` to `shelfRun()` lifecycle hook.

## 1.6.0

- Added `onStartFailed` to `shelfRun()` to react on server startup failures.

## 1.5.1

- Update dependencies

## 1.5.0

- Changed way of applying global middleware. Middlewares are now scoped to routers that can be composed by using `mount()`.

## 1.4.1

- Added `onStarted` to `shelfRun()` to specify alternative / custom startup logging.

## 1.4.0

- Change type of `defaultBindAddress` to `Object` to mirror the `dart_io` API

## 1.3.0

- Add optional `SecurityContext` property to `shelfRun()`
- Upgrade code base and update dependencies

## 1.2.3

- Fixed middleware handling for undefined routes (e.g. CORS handling)

## 1.2.2

- Add cors example

## 1.2.1

- Fixed link in README.md

## 1.2.0

- Added multithreading / isolates support

## 1.1.0

- Added WebSocket support

## 1.0.2

- Fix error in response_handler when returning an empty list

## 1.0.1

- Upgrade `shelf_hotreload` package

## 1.0.0

- Raise Dart minimum SDK version 2.14
- Changed from `pedantic` to `lints`
- Updated documentation

## 0.0.2

- Added mechanism for request body handling
- JSON handler can now process `Iterable`s and serialize model classes of `Iterable`s
- Added example for a rest-service

## 0.0.1

- Initial version
