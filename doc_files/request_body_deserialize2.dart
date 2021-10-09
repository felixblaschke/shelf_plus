class Person {
  final String name;

  Person({required this.name});

  // created with tools like json_serializable package
  static Person fromJson(Map<String, dynamic> json) {
    return Person(name: json['name']);
  }
}
