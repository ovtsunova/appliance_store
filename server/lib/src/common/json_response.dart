import 'dart:convert';

import 'package:shelf/shelf.dart';

const _jsonHeaders = {
  'content-type': 'application/json; charset=utf-8',
};

Response jsonOk(Object body) {
  return Response.ok(
    jsonEncode(body),
    headers: _jsonHeaders,
  );
}

Response jsonCreated(Object body) {
  return Response(
    201,
    body: jsonEncode(body),
    headers: _jsonHeaders,
  );
}

Response jsonBadRequest(String message, {Object? details}) {
  return Response(
    400,
    body: jsonEncode({
      'message': message,
      'details': ?details,
    }),
    headers: _jsonHeaders,
  );
}

Response jsonUnauthorized(String message) {
  return Response(
    401,
    body: jsonEncode({'message': message}),
    headers: _jsonHeaders,
  );
}

Response jsonForbidden(String message) {
  return Response(
    403,
    body: jsonEncode({'message': message}),
    headers: _jsonHeaders,
  );
}

Response jsonNotFound(String message) {
  return Response(
    404,
    body: jsonEncode({'message': message}),
    headers: _jsonHeaders,
  );
}

Response jsonServerError(String message, {Object? details}) {
  return Response(
    500,
    body: jsonEncode({
      'message': message,
      'details': ?details,
    }),
    headers: _jsonHeaders,
  );
}