# Shelf Plus

**Shelf Plus** is a **quality of life** addon for your server-side development within
the Shelf platform. It's a great base to **start off** your apps fast, while
**maintaining full compatibility** with the **Shelf** ecosystem.

@code tool/templates/code/quickstart.dart

It comes with a lot of awesome features, like **zero-configuration** initializer, build-in **hot-reload**
and a **super powerful** and **intuitive router upgrade**. Continue reading and get to know why
you can't ever code without **Shelf Plus**.

@gap 1
@index

@gap 1
## Router Plus

Router Plus is a **high-level abstraction layer** sitting directly on [shelf_router](https://pub.dev/packages/shelf_router). 
It **shares the same [routing logic](https://pub.dev/documentation/shelf_router/latest/shelf_router/Router-class.html)**
but allows you to handle responses in a very simple way.

@code tool/templates/code/router_plus_intro.dart

The core mechanic is called **ResponseHandler** which continuously refines a data structure,
until it resolves in a [Shelf Response](https://pub.dev/documentation/shelf/latest/shelf/Response-class.html).
This extensible system comes with support for text, json, binaries, files, json serialization and Shelf [Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html). 

You can access the **Router Plus** by calling the **`.plus`** getter on a regular Shelf Router.

@code tool/templates/code/router_plus_upgrade.dart

@gap 1
### Routes API

The API mimics the [Shelf Router](https://pub.dev/documentation/shelf_router/latest/shelf_router/Router-class.html)
methods. You basically use an HTTP verb, define a route to match and specify a handler,
that generates the response.

@code tool/templates/code/routes_api_verb.dart

You can return any type, as long the **ResponseHandler** mechanism has a capable
resolver to handle that type.

If you need the [Shelf Request](https://pub.dev/documentation/shelf/latest/shelf/Request-class.html)
object, specify it as the first parameter. Any other parameter will match the
route parameters, if defined.

@code tool/templates/code/routes_api_signature.dart

@gap 1
### Middleware

Router Plus provides several options to place your middleware ([Shelf Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)).

@code tool/templates/code/middleware_intro.dart

You can also apply middleware dynamically inside a route handler, using the `>>` operator.

@code tool/templates/code/middleware_in_requesthandler.dart

@gap 1
### ResponseHandler

ResponseHandler process the **return value** of a route handler, until it matches a
[Shelf Response](https://pub.dev/documentation/shelf/latest/shelf/Response-class.html).

#### Build-in ResponseHandler

| Source                                   | Result                                                | Use case                                                                                 |
| ---------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `String`                                 | Shelf `Response`                                      | Respond with a text (text/plain)                                                         |
| `Uint8List`, `Stream<List<int>>`         | Shelf `Response`                                      | Respond with binary (application/octet-stream)                                           |
| `Map<String, dynamic>`, `List<dynamic>>` | Shelf `Response`                                      | Respond with JSON (application/json)                                                     |
| Any Type having a `toJson()` method      | `Map<String, dynamic>`, `List<dynamic>>` *(expected)* | Provide serialization support for classes                                                |
| Shelf `Handler`                          | Shelf `Response`                                      | Processing Shelf-based Middleware or Handler                                             |
| `File` (dart:io)                         | Shelf `Response`                                      | Respond with file contents (using [shelf_static](https://pub.dev/packages/shelf_static)) |

*Example:*

@code tool/templates/code/response_handler_example.dart

#### Custom ResponseHandler

You can add your own ResponseHandler by using a [Shelf Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)
created with the `.middleware` getter on a ResponseHandler function. 

@code tool/templates/code/response_handler_custom.dart
@code tool/templates/code/response_handler_custom_cat.dart

@gap 1
### Cascading multiple routers

Router Plus is compatible to a [Shelf Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html).
So, you can also use it in a [Shelf Cascade](https://pub.dev/documentation/shelf/latest/shelf/Pipeline-class.html).
This package provides a `cascade()` function, to quickly set up a cascade.

@code tool/templates/code/cascade.dart



@gap 2
## Middleware collection

This package comes with additional [Shelf Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)
to simplify common tasks.

@gap 1
### setContentType

Sets the `content-type` header of a `Response` to the specified **mime-type**.

@code tool/templates/code/mw_set_content_type.dart

@gap1
### typeByExtension

Sets the `content-type` header of a `Response` to the **mime-type** of the
specified **file extension**.

@code tool/templates/code/mw_type_by_extension.dart

@gap1
### download

Sets the `content-disposition` header of a `Response`, so browsers will download the
server response instead of displaying it. Optionally you can define a specific **file name**.

@code tool/templates/code/mw_download.dart


@gap 2
## Request body handling

Shelf Plus provides an extensible mechanism to process the HTTP body of a request.
You can access it by calling the `.body` getter on a [Shelf Request](https://pub.dev/documentation/shelf/latest/shelf/Request-class.html).

It comes with build-in support for text, JSON and binary.

@code tool/templates/code/request_body_intro.dart

@gap1
### Object deserialization

A recommended way to deserialize a json-encoded object is to provide a
**reviver function**, that can be generated by code generators.

@code tool/templates/code/request_body_deserialize1.dart
@code tool/templates/code/request_body_deserialize2.dart


@gap1
### Custom accessors for model classes

You can add own accessors for model classes by creating an 
extension on `RequestBodyAccessor`.

@code tool/templates/code/request_body_ext_model1.dart
@code tool/templates/code/request_body_ext_model2.dart

@gap1
### Custom accessors for third party body parser

You can plug-in any other body parser by creating an
extension on `RequestBodyAccessor`.

@code tool/templates/code/request_body_ext_third_party.dart



@gap 2
## Shelf Run

Shelf Run is **zero-configuration** web-server initializer with **hot-reload** support.

@code tool/templates/code/shelf_run_intro.dart

It's important to use a dedicated `init` function, returning a [Shelf Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html),
for hot-reload to work properly.

To enable hot-reload you need either run your app with the IDE's **debug profile**, or
enable vm-service from the command line: 

```dart run --enable-vm-service my_app.dart```

Shelf Run uses a default configuration, that can be modified via **environment variables**:

| Environment variable | Default value | Description                              |
| -------------------- | ------------- | ---------------------------------------- |
| SHELF_PORT           | 8080          | Port to bind the shelf application to    |
| SHELF_ADDRESS        | localhost     | Address to bind the shelf application to |
| SHELF_HOTRELOAD      | true          | Enable hot-reload                        |

You can override the default values with optional parameters in the `shelfRun()` function.

@code tool/templates/code/shelf_run_override_default.dart


@gap2
## Examples

### Rest Service

Implementation of a CRUD, rest-like backend service. ([Full sources](/example/example_rest/))



**example_rest.dart**
@code example/example_rest/bin/example_rest.dart

**person.dart**
@code example/example_rest/bin/person.dart
