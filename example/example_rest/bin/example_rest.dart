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
