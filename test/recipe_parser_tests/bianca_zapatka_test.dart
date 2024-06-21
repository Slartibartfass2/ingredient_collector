import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/recipe_controller/recipe_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'parser_test_helper.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecipeCache().cache.clear();
  });

  test(
    'When test files are parsed, then expected results are met',
    () async => testParsingTestFiles(
      "./test/recipe_parser_tests/parser_test_files/bianca_zapatka",
    ),
    timeout: const Timeout(Duration(minutes: 5)),
    tags: ["parsing-test"],
  );
}
