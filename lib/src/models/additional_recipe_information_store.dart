import 'package:freezed_annotation/freezed_annotation.dart';

import 'additional_recipe_information.dart';

part 'additional_recipe_information_store.freezed.dart';
part 'additional_recipe_information_store.g.dart';

/// Data class that holds [AdditionalRecipeInformation] objects.
///
/// This class is used to store the additional recipe information in the local
/// storage.
@freezed
class AdditionalRecipeInformationStore with _$AdditionalRecipeInformationStore {
  /// Creates [AdditionalRecipeInformationStore] object.
  const factory AdditionalRecipeInformationStore({
    /// List of [AdditionalRecipeInformation].
    @Default(<AdditionalRecipeInformation>[])
    List<AdditionalRecipeInformation> additionalRecipeInformations,
  }) = _AdditionalRecipeInformationStore;

  /// Creates [AdditionalRecipeInformationStore] object from JSON.
  factory AdditionalRecipeInformationStore.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$AdditionalRecipeInformationStoreFromJson(json);
}
