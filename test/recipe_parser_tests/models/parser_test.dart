import 'package:freezed_annotation/freezed_annotation.dart';

import 'parser_test_request.dart';
import 'parser_test_result.dart';

part 'parser_test.freezed.dart';
part 'parser_test.g.dart';

@freezed
class ParserTest with _$ParserTest {
  const factory ParserTest({
    required ParserTestRequest request,
    required ParserTestResult result,
  }) = _ParserTest;

  factory ParserTest.fromJson(Map<String, dynamic> json) =>
      _$ParserTestFromJson(json);
}
