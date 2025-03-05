import 'package:freezed_annotation/freezed_annotation.dart';

part 'parser_test_request.freezed.dart';
part 'parser_test_request.g.dart';

@freezed
sealed class ParserTestRequest with _$ParserTestRequest {
  const factory ParserTestRequest({required String url, required int servings}) =
      _ParserTestRequest;

  factory ParserTestRequest.fromJson(Map<String, dynamic> json) =>
      _$ParserTestRequestFromJson(json);
}
