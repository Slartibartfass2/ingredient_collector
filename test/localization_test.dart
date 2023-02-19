import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test localization', () async {
    WidgetsFlutterBinding.ensureInitialized();

    var json = await readJsonFile('resources/langs/en.json');

    var files = io.Directory('resources/langs').listSync();

    for (var file in files) {
      if (file.path.contains('en.json')) {
        continue;
      }

      var filePath = file.path.replaceAll(r'\', '/');
      var jsonToValidate = await readJsonFile(filePath);
      validateJsonEqualty(json, jsonToValidate, filePath);
    }
  });
}

Future<Map> readJsonFile(String path) async {
  var response = await rootBundle.loadString(path);
  return await json.decode(response);
}

void validateJsonEqualty(Map json, Map jsonToValidate, String validateFile) {
  expect(
    json.length,
    equals(jsonToValidate.length),
    reason: 'both json strings must have the same number of keys',
  );
  for (var key in json.keys) {
    expect(
      jsonToValidate.containsKey(key),
      isTrue,
      reason: '\'$validateFile\' must contain the key \'${key.toString()}\'',
    );
    expect(
      json[key].runtimeType,
      equals(jsonToValidate[key].runtimeType),
      reason: 'The values with the key \'$key\' must have the same type',
    );
    if (json[key] is Map) {
      validateJsonEqualty(json[key], jsonToValidate[key], validateFile);
    }
  }
}