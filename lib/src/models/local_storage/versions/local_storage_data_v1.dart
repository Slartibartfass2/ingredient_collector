import 'package:freezed_annotation/freezed_annotation.dart';

import '../additional_recipe_information.dart';

part 'local_storage_data_v1.freezed.dart';
part 'local_storage_data_v1.g.dart';

/// Data class that holds information about the data stored in local storage.
@freezed
class LocalStorageDataV1 with _$LocalStorageDataV1 {
  /// Creates [LocalStorageDataV1] object.
  @Assert("version == 1")
  const factory LocalStorageDataV1({
    /// Version of the local storage data object.
    @Default(1) int version,

    /// Additional recipe information
    required List<AdditionalRecipeInformation> additionalRecipeInformation,
  }) = _LocalStorageDataV1;

  /// Creates [LocalStorageDataV1] object from JSON.
  factory LocalStorageDataV1.fromJson(Map<String, dynamic> json) =>
      _$LocalStorageDataV1FromJson(json);
}
