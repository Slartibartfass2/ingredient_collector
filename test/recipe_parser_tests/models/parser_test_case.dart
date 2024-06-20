import 'package:freezed_annotation/freezed_annotation.dart';

import 'parser_test_request.dart';
import 'parser_test_result.dart';

part 'parser_test_case.freezed.dart';
part 'parser_test_case.g.dart';

@freezed
class ParserTestCase with _$ParserTestCase {
  const factory ParserTestCase({
    required ParserTestRequest request,
    required ParserTestResult result,
  }) = _ParserTestCase;

  factory ParserTestCase.fromJson(Map<String, dynamic> json) =>
      _$ParserTestCaseFromJson(json);
}
