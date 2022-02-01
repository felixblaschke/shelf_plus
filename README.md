<!-- This file uses generated code. Visit https://pub.dev/packages/readme_helper for usage information. -->
# Shelf Plus

**Shelf Plus** is a **quality of life** addon for your server-side development within
the Shelf platform. It's a great base to **start off** your apps fast, while
**maintaining full compatibility** with the **Shelf** ecosystem.

<!-- #code doc_files/quickstart.dart -->
```dart
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  app.get('/', () => 'Hello World!');

  return app;
}
```
<!-- // end of #code -->

It comes with a lot of awesome features, like **zero-configuration** initializer, build-in **hot-reload**
and a **super powerful** and **intuitive router upgrade**. Continue reading and get to know why
you can't ever code without **Shelf Plus**.

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
<!-- #toc -->
## Table of Contents

[**Router Plus**](#router-plus)
  - [Routes API](#routes-api)
  - [Middleware](#middleware)
  - [ResponseHandler](#responsehandler)
  - [Cascading multiple routers](#cascading-multiple-routers)

[**Middleware collection**](#middleware-collection)
  - [setContentType](#setcontenttype)
  - [typeByExtension](#typebyextension)
  - [download](#download)

[**Request body handling**](#request-body-handling)
  - [Object deserialization](#object-deserialization)
  - [Custom accessors for model classes](#custom-accessors-for-model-classes)
  - [Custom accessors for third party body parser](#custom-accessors-for-third-party-body-parser)

[**Shelf Run**](#shelf-run)

[**Examples**](#examples)
  - [Rest Service](#rest-service)
  - [WebSocket chat server](#websocket-chat-server)
<!-- // end of #toc -->

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
## Router Plus

Router Plus is a **high-level abstraction layer** sitting directly on [shelf_router](https://pub.dev/packages/shelf_router). 
It **shares the same [routing logic](https://pub.dev/documentation/shelf_router/latest/shelf_router/Router-class.html)**
but allows you to handle responses in a very simple way.

<!-- #code doc_files/router_plus_intro.dart -->
```dart
var app = Router().plus;

app.use(middleware());

app.get('/text', () => 'I am a text');

app.get(
    '/html/<name>', (Request request, String name) => '<h1>Hello $name</h1>',
    use: typeByExtension('html'));

app.get('/file', () => File('path/to/file.zip'));

app.get('/person', () => Person(name: 'John', age: 42));
```
<!-- // end of #code -->

The core mechanic is called **ResponseHandler** which continuously refines a data structure,
until it resolves in a [Shelf Response](https://pub.dev/documentation/shelf/latest/shelf/Response-class.html).
This extensible system comes with support for text, json, binaries, files, json serialization and Shelf [Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html). 

You can access the **Router Plus** by calling the **`.plus`** getter on a regular Shelf Router.

<!-- #code doc_files/router_plus_upgrade.dart -->
```dart
var app = Router().plus;
```
<!-- // end of #code -->

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
### Routes API

The API mimics the [Shelf Router](https://pub.dev/documentation/shelf_router/latest/shelf_router/Router-class.html)
methods. You basically use an HTTP verb, define a route to match and specify a handler,
that generates the response.

<!-- #code doc_files/routes_api_verb.dart -->
```dart
app.get('/path/to/match', () => 'a response');
```
<!-- // end of #code -->

You can return any type, as long the **ResponseHandler** mechanism has a capable
resolver to handle that type.

If you need the [Shelf Request](https://pub.dev/documentation/shelf/latest/shelf/Request-class.html)
object, specify it as the first parameter. Any other parameter will match the
route parameters, if defined.

<!-- #code doc_files/routes_api_signature.dart -->
```dart
app.get('/minimalistic', () => 'response');

app.get('/with/request', (Request request) => 'response');

app.get('/clients/<id>', (Request request, String id) => 'response: $id');

app.get('/customer/<id>', (Request request) {
  // alternative access to route parameters
  return 'response: ${request.routeParameter('id')}';
});
```
<!-- // end of #code -->

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
### Middleware

Router Plus provides several options to place your middleware ([Shelf Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)).

<!-- #code doc_files/middleware_intro.dart -->
```dart
var app = Router().plus;

app.use(middlewareA); // apply to all routes

// apply to a single route
app.get('/request1', () => 'response', use: middlewareB);

// combine middleware with + operator
app.get('/request2', () => 'response', use: middlewareB + middlewareC);
```
<!-- // end of #code -->

You can also apply middleware dynamically inside a route handler, using the `>>` operator.

<!-- #code doc_files/middleware_in_requesthandler.dart -->
```dart
app.get('/request/<value>', (Request request, String value) {
  return middleware(value) >> 'response';
});
```
<!-- // end of #code -->

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
### ResponseHandler

ResponseHandler process the **return value** of a route handler, until it matches a
[Shelf Response](https://pub.dev/documentation/shelf/latest/shelf/Response-class.html).

#### Build-in ResponseHandler

| Return type                              | Use case                                                                                            |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `String`                                 | Respond with a text (text/plain)                                                                    |
| `Uint8List`, `Stream<List<int>>`         | Respond with binary (application/octet-stream)                                                      |
| `Map<String, dynamic>`, `List<dynamic>>` | Respond with JSON (application/json)                                                                |
| Any Type having a `toJson()` method      | Serialization support for classes                                                                   |
| `File` (dart:io)                         | Respond with file contents (using [shelf_static](https://pub.dev/packages/shelf_static))            |
| `WebSocketSession` (shelf_plus)          | Create a websocket connection (using [shelf_web_socket](https://pub.dev/packages/shelf_web_socket)) |
| `Handler` (shelf)                        | Processing Shelf-based Middleware or Handler                                                        |

*Example:*

<!-- #code doc_files/response_handler_example.dart -->
```dart
import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  app.get('/text', () => 'a text');

  app.get('/binary', () => File('data.zip').openRead());

  app.get('/json', () => {'name': 'John', 'age': 42});

  app.get('/class', () => Person('Theo'));

  app.get('/list-of-classes', () => [Person('Theo'), Person('Bob')]);

  app.get('/iterables', () => [1, 10, 100].where((n) => n > 9));

  app.get('/handler', () => typeByExtension('html') >> '<h1>Hello</h1>');

  app.get('/file', () => File('thesis.pdf'));

  app.get(
      '/websocket',
      () => WebSocketSession(
            onOpen: (ws) => ws.send('Hello!'),
            onMessage: (ws, data) => ws.send('You sent me: $data'),
            onClose: (ws) => ws.send('Bye!'),
          ));

  return app;
}

class Person {
  final String name;

  Person(this.name);

  // can be generated by tools (i.e. json_serializable package)
  Map<String, dynamic> toJson() => {'name': name};
}
```
<!-- // end of #code -->

#### Custom ResponseHandler

You can add your own ResponseHandler by using a [Shelf Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)
created with the `.middleware` getter on a ResponseHandler function. 

<!-- #code doc_files/response_handler_custom.dart -->
```dart
// define custom ResponseHandler
ResponseHandler catResponseHandler = (Request request, dynamic maybeCat) =>
    maybeCat is Cat ? maybeCat.interact() : null;

// register custom ResponseHandler as middleware
app.use(catResponseHandler.middleware);

app.get('/cat', () => Cat());
```
<!-- // end of #code -->
<!-- #code doc_files/response_handler_custom_cat.dart -->
```dart
class Cat {
  String interact() => 'Purrrrr!';
}
```
<!-- // end of #code -->

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
### Cascading multiple routers

Router Plus is compatible to a [Shelf Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html).
So, you can also use it in a [Shelf Cascade](https://pub.dev/documentation/shelf/latest/shelf/Pipeline-class.html).
This package provides a `cascade()` function, to quickly set up a cascade.

<!-- #code doc_files/cascade.dart -->
```dart
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app1 = Router().plus;
  var app2 = Router().plus;

  app1.get('/maybe', () => Response.notFound('no idea'));

  app2.get('/maybe', () => 'got it!');

  return cascade([app1, app2]);
}
```
<!-- // end of #code -->



<!-- #space 2 -->

&nbsp;

&nbsp;
<!-- // end of #space -->
## Middleware collection

This package comes with additional [Shelf Middleware](https://pub.dev/documentation/shelf/latest/shelf/Middleware.html)
to simplify common tasks.

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->
### setContentType

Sets the `content-type` header of a `Response` to the specified **mime-type**.

<!-- #code doc_files/mw_set_content_type.dart -->
```dart
app.get('/one', () => setContentType('application/json') >> '1');

app.get('/two', () => '2', use: setContentType('application/json'));
```
<!-- // end of #code -->

<!-- #space1 -->
### typeByExtension

Sets the `content-type` header of a `Response` to the **mime-type** of the
specified **file extension**.

<!-- #code doc_files/mw_type_by_extension.dart -->
```dart
app.get('/', () => '<h1>Hi!</h1>', use: typeByExtension('html'));
```
<!-- // end of #code -->

<!-- #space1 -->
### download

Sets the `content-disposition` header of a `Response`, so browsers will download the
server response instead of displaying it. Optionally you can define a specific **file name**.

<!-- #code doc_files/mw_download.dart -->
```dart
app.get('/wallpaper/download', () => File('image.jpg'), use: download());

app.get('/invoice/<id>', (Request request, String id) {
  File document = pdfService.generateInvoice(id);
  return download(filename: 'invoice_$id.pdf') >> document;
});
```
<!-- // end of #code -->


<!-- #space 2 -->

&nbsp;

&nbsp;
<!-- // end of #space -->
## Request body handling

Shelf Plus provides an extensible mechanism to process the HTTP body of a request.
You can access it by calling the `.body` getter on a [Shelf Request](https://pub.dev/documentation/shelf/latest/shelf/Request-class.html).

It comes with build-in support for text, JSON and binary.

<!-- #code doc_files/request_body_intro.dart -->
```dart
app.post('/text', (Request request) async {
  var text = await request.body.asString;
  return 'You send me: $text';
});

app.post('/json', (Request request) async {
  var person = Person.fromJson(await request.body.asJson);
  return 'You send me: ${person.name}';
});
```
<!-- // end of #code -->

<!-- #space1 -->
### Object deserialization

A recommended way to deserialize a json-encoded object is to provide a
**reviver function**, that can be generated by code generators.

<!-- #code doc_files/request_body_deserialize1.dart -->
```dart
var person = await request.body.as(Person.fromJson);
```
<!-- // end of #code -->
<!-- #code doc_files/request_body_deserialize2.dart -->
```dart
class Person {
  final String name;

  Person({required this.name});

  // created with tools like json_serializable package
  static Person fromJson(Map<String, dynamic> json) {
    return Person(name: json['name']);
  }
}
```
<!-- // end of #code -->


<!-- #space1 -->
### Custom accessors for model classes

You can add own accessors for model classes by creating an 
extension on `RequestBodyAccessor`.

<!-- #code doc_files/request_body_ext_model1.dart -->
```dart
extension PersonAccessor on RequestBodyAccessor {
  Future<Person> get asPerson async => Person.fromJson(await asJson);
}
```
<!-- // end of #code -->
<!-- #code doc_files/request_body_ext_model2.dart -->
```dart
app.post('/person', (Request request) async {
  var person = await request.body.asPerson;
  return 'You send me: ${person.name}';
});
```
<!-- // end of #code -->

<!-- #space1 -->
### Custom accessors for third party body parser

You can plug-in any other body parser by creating an
extension on `RequestBodyAccessor`.

<!-- #code doc_files/request_body_ext_third_party.dart -->
```dart
extension OtherFormatBodyParserAccessor on RequestBodyAccessor {
  Future<OtherBodyFormat> get asOtherFormat async {
    return ThirdPartyLib().process(request.read());
  }
}
```
<!-- // end of #code -->



<!-- #space 2 -->

&nbsp;

&nbsp;
<!-- // end of #space -->
## Shelf Run

Shelf Run is **zero-configuration** web-server initializer with **hot-reload** support.

<!-- #code doc_files/shelf_run_intro.dart -->
```dart
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  return (Request request) => Response.ok('Hello!');
}
```
<!-- // end of #code -->

It's important to use a dedicated `init` function, returning a [Shelf Handler](https://pub.dev/documentation/shelf/latest/shelf/Handler.html),
for hot-reload to work properly.

To enable hot-reload you need either run your app with the IDE's **debug profile**, or
enable vm-service from the command line: 

```
dart run --enable-vm-service my_app.dart
```

Shelf Run uses a default configuration, that can be modified via **environment variables**:

| Environment variable | Default value | Description                              |
| -------------------- | ------------- | ---------------------------------------- |
| SHELF_PORT           | 8080          | Port to bind the shelf application to    |
| SHELF_ADDRESS        | localhost     | Address to bind the shelf application to |
| SHELF_HOTRELOAD      | true          | Enable hot-reload                        |

You can override the default values with optional parameters in the `shelfRun()` function.

<!-- #code doc_files/shelf_run_override_default.dart -->
```dart
void main() => shelfRun(init, defaultBindPort: 3000);
```
<!-- // end of #code -->

<!-- #space 2 -->

&nbsp;

&nbsp;
<!-- // end of #space -->
## Examples

### Rest Service

Implementation of a CRUD, rest-like backend service. ([Full sources](/example/example_rest/))



**example_rest.dart**
<!-- #code example/example_rest/bin/example_rest.dart -->
```dart
import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

import 'person.dart';

void main() => shelfRun(init);

final data = <Person>[
  Person(firstName: 'John', lastName: 'Doe', age: 42),
  Person(firstName: 'Jane', lastName: 'Doe', age: 43),
];

Handler init() {
  var app = Router().plus;

  /// Serve index page of frontend
  app.get('/', () => File('frontend/page.html'));

  /// List all persons
  app.get('/person', () => data);

  /// Get specific person by id
  app.get('/person/<id>',
      (Request request, String id) => data.where((person) => person.id == id));

  /// Add a new person
  app.post('/person', (Request request) async {
    var newPerson = await request.body.as(Person.fromJson);
    data.add(newPerson);
    return {'ok': 'true', 'person': newPerson.toJson()};
  });

  /// Update an existing person by id
  app.put('/person/<id>', (Request request, String id) async {
    data.removeWhere((person) => person.id == id);
    var person = await request.body.as(Person.fromJson);
    person.id = id;
    data.add(person);
    return {'ok': 'true'};
  });

  /// Remove a specific person by id
  app.delete('/person/<id>', (Request request, String id) {
    data.removeWhere((person) => person.id == id);
    return {'ok': 'true'};
  });

  return app;
}
```
<!-- // end of #code -->

**person.dart**
<!-- #code example/example_rest/bin/person.dart -->
```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'person.g.dart';

/// run 'dart run build_runner build' to update model

@JsonSerializable()
class Person {
  String? id;
  final String firstName;
  final String lastName;
  final int age;

  Person({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.age,
  }) {
    this.id = id ?? Uuid().v4();
  }

  Map<String, dynamic> toJson() => _$PersonToJson(this);

  static Person fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}
```
<!-- // end of #code -->

<!-- #space 1 -->

&nbsp;
<!-- // end of #space -->


### WebSocket chat server

Implementation of a WebSocket-based chat application. ([Full sources](/example/example_websocket_chat/))

**example_websocket_chat.dart**
<!-- #code example/example_websocket_chat/bin/example_websocket_chat.dart -->
```dart
import 'dart:io';

import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  var app = Router().plus;

  // HTML-based web client
  app.get('/', () => File('public/html_client.html'));

  // Track connected clients
  var users = <WebSocketSession>[];

  // Web socket route
  app.get(
    '/ws',
    () => WebSocketSession(
      onOpen: (ws) {
        // Join chat
        users.add(ws);
        users
            .where((user) => user != ws)
            .forEach((user) => user.send('A new user joined the chat.'));
      },
      onClose: (ws) {
        // Leave chat
        users.remove(ws);
        for (var user in users) {
          user.send('A user has left.');
        }
      },
      onMessage: (ws, dynamic data) {
        // Deliver messages to all users
        for (var user in users) {
          user.send(data);
        }
      },
    ),
  );

  return app;
}
```
<!-- // end of #code -->
