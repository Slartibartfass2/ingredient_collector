import 'package:flutter_test/flutter_test.dart';
import 'package:ingredient_collector/src/helper/levenshtein.dart';
import 'package:parameterized_test/parameterized_test.dart';

void main() {
  group("levenshtein", () {
    test("When the source and target are equal, then the distance is zero", () {
      var distance = levenshtein("helloworld", "helloworld");

      expect(distance, isZero);
    });

    test("When the source is empty, then the distance is equal to the target length", () {
      var target = "helloworld";
      var distance = levenshtein("", target);

      expect(distance, equals(target.length));
    });

    test("When the target is empty, then the distance is equal to the source length", () {
      var source = "helloworld";
      var distance = levenshtein(source, "");

      expect(distance, equals(source.length));
    });

    parameterizedTest(
      "When the source and target are different, then the distance is correct",
      [
        ["Apple", "Papple", 2, 1],
        ["Banana", "Bananas", 1, 1],
        ["Pants", "Bands", 2, 2],
        ["Hello", "World", 4, 4],
        ["SeNsiTive", "sensitive", 3, 0],
      ],
      (String source, String target, int expectedSensitive, int expectedInsensitive) {
        var distanceSensitive = levenshtein(source, target, caseSensitive: true);
        var distanceInsensitive = levenshtein(source, target, caseSensitive: false);

        var baseReason = "Expected sensitive distance of '$source' and '$target' to be";
        expect(
          distanceSensitive,
          equals(expectedSensitive),
          reason: "$baseReason $expectedSensitive",
        );
        expect(
          distanceInsensitive,
          equals(expectedInsensitive),
          reason: "$baseReason $expectedInsensitive",
        );
      },
    );
  });

  group("relativeLevenshtein", () {
    parameterizedTest(
      "When the source and target are different, then the distance is correct",
      [
        ["AppleAppleAppleAppleApple", "PappleAppleAppleAppleApple", 0.9231],
        ["Apple", "Papple", 0.6667],
        ["Hello", "World", 0.2],
        ["ABCDEF", "GHIJKL", 0.0],
        ["ABCDEF", "GHIJKLMNOPQRSTUVW", 0.0],
        ["ABCDEFGHIJKLMNOPQ", "RSTUVW", 0.0],
        ["", "", 1.0],
      ],
      (String source, String target, double expectedRelDistance) {
        var relativeDistance = relativeLevenshtein(source, target);

        expect(
          relativeDistance,
          moreOrLessEquals(expectedRelDistance, epsilon: 0.0001),
          reason:
              "Expected relative distance of '$source' and '$target' to be $expectedRelDistance",
        );
      },
    );
  });
}
