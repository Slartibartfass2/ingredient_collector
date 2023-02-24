import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';

/// Data class which holds information about a single ingredient.
///
/// The information consists of the [amount], the [unit] and the [name].
@freezed
class Ingredient with _$Ingredient {
  /// Creates [Ingredient] object.
  const factory Ingredient({
    /// Amount of ingredient.
    ///
    /// e.g. "2", "3.4"
    required double amount,

    /// Unit of ingredient.
    ///
    /// e.g. "ml", "g", "oz"
    required String unit,

    /// Name of ingredient.
    ///
    /// e.g. "Carrot", "Apple"
    required String name,
  }) = _Ingredient;
}
