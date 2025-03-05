import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingredient.freezed.dart';
part 'ingredient.g.dart';

/// Data class that holds information about a single ingredient.
///
/// The information consists of the [amount], the [unit] and the [name].
@freezed
sealed class Ingredient with _$Ingredient {
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

  /// Creates [Ingredient] object from JSON.
  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
}
