
import 'dart:convert';

import 'package:shelf_plus/shelf_plus.dart';

extension RequestBodyAccessorExtension on Request {
  /// Getter that provides access to the [RequestBodyAccessor].
  RequestBodyAccessor get body => RequestBodyAccessor(this);
}

/// Reference class for different request body accessors.
/// Provides basic accessors like [asString] or [asJson].
///
/// You can extend on this class to add your own body parser.
///
/// Example:
/// ```dart
/// extension PersonAccessor on RequestBodyAccessor {
///   Future<Person> get asPerson async => Person.fromJson(await asJson);
/// }
/// ```
class RequestBodyAccessor {
  Request request;

  RequestBodyAccessor(this.request);

  /// Returns the request body as a utf8 string
  Future<String> get asString async => request.readAsString();

  /// Returns the request body as json-decoded object, that can be either
  /// `Map<String, dynamic>` or `List<dynamic>`
  ///
  /// Example:
  /// ```dart
  /// var person = Person.fromJson(await request.body.asJson);
  /// ```
  Future<dynamic> get asJson async => jsonDecode(await asString);

  /// Returns the request body as a class instance that is
  /// initialized by the provided [reviver].
  ///
  /// Example:
  /// ```dart
  /// var person = await request.body.as(Person.fromJson);
  /// ```
  /// *Hint: The reviver function can't be factory constructor*
  Future<T> as<T>(T Function(Map<String, dynamic>) reviver) async =>
      Function.apply(reviver, [(await asJson)]) as T;

  /// Returns the request body as a binary stream.
  Stream<List<int>> get asBinary => request.read();
}
