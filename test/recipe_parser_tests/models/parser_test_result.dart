import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ingredient_collector/src/models/ingredient.dart';

part 'parser_test_result.freezed.dart';
part 'parser_test_result.g.dart';

@freezed
class ParserTestResult with _$ParserTestResult {
  const factory ParserTestResult({required String name, required List<Ingredient> ingredients}) =
      _ParserTestResult;

  factory ParserTestResult.fromJson(Map<String, dynamic> json) => _$ParserTestResultFromJson(json);
}
