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
