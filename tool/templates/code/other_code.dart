class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  // created with tools like json_serializable package
  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }

  static Person fromJson(Map<String, dynamic> json) {
    return Person(name: '', age: 0);
  }
}
