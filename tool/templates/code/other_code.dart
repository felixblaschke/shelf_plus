class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  // created with tools like @jsonSerializable
  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }
}
