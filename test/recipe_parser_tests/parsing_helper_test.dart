import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/recipe_parser/parsing_helper.dart';

void main() {
  test('parse amount string with double', () {
    expect(tryParseAmountString("2.35", language: "en"), equals(2.35));
    expect(tryParseAmountString("2,35", language: "de"), equals(2.35));
  });

  test('parse amount string with range', () {
    expect(tryParseAmountString("3-4", language: "en"), equals(3.5));
  });

  test('parse amount string with fraction character', () {
    expect(tryParseAmountString("⅘", language: "en"), equals(0.8));
  });

  test('parse amount string with combined numbers', () {
    expect(tryParseAmountString("1 ⅝", language: "en"), equals(1.625));
    expect(tryParseAmountString("1 1/2", language: "en"), equals(1.5));
  });

  test('parse amount string with leading word', () {
    expect(tryParseAmountString("ca. 240", language: "en"), equals(240));
  });
}
