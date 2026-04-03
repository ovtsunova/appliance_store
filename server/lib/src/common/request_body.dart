import 'dart:convert';

Future<Map<String, dynamic>> readJsonBody(String rawBody) async {
  if (rawBody.trim().isEmpty) {
    throw const FormatException('Пустое тело запроса');
  }

  final decoded = jsonDecode(rawBody);

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Ожидался JSON-объект');
  }

  return decoded;
}

String requireString(
  Map<String, dynamic> body,
  String fieldName, {
  bool allowEmpty = false,
}) {
  final value = body[fieldName];

  if (value is! String) {
    throw FormatException('Поле "$fieldName" должно быть строкой');
  }

  final normalized = value.trim();

  if (!allowEmpty && normalized.isEmpty) {
    throw FormatException('Поле "$fieldName" обязательно для заполнения');
  }

  return normalized;
}

int requireInt(
  Map<String, dynamic> body,
  String fieldName, {
  int? min,
}) {
  final value = body[fieldName];

  int parsed;

  if (value is int) {
    parsed = value;
  } else if (value is num) {
    parsed = value.toInt();
  } else if (value is String) {
    parsed = int.tryParse(value.trim()) ??
        (throw FormatException('Поле "$fieldName" должно быть числом'));
  } else {
    throw FormatException('Поле "$fieldName" должно быть числом');
  }

  if (min != null && parsed < min) {
    throw FormatException('Поле "$fieldName" должно быть не меньше $min');
  }

  return parsed;
}