import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/recipe_parser/parsing_helper.dart';

void main() {
  test('When decimal number is parsed, then the correct value is returned', () {
    expect(tryParseAmountString("2.35", language: "en"), equals(2.35));
    expect(tryParseAmountString("2,35", language: "de"), equals(2.35));
  });

  test('When range is parsed, then the average is returned', () {
    expect(tryParseAmountString("3-4", language: "en"), equals(3.5));
  });

  test('When a fraction is parsed, then the correct value is returned', () {
    expect(tryParseAmountString("⅘", language: "en"), equals(0.8));
  });

  test('When combinations are parsed, then the correct value is returned', () {
    expect(tryParseAmountString("1 ⅝", language: "en"), equals(1.625));
    expect(tryParseAmountString("1 1/2", language: "en"), equals(1.5));
  });

  test('When amount with leading word is parsed, then correct value is returned', () {
    expect(tryParseAmountString("ca. 240", language: "en"), equals(240));
  });
}
