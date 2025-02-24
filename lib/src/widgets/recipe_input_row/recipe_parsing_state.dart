/// The state of the recipe parsing process.
enum RecipeParsingState {
  /// The recipe is not parsed yet.
  notStarted,

  /// The recipe is currently parsed.
  inProgress,

  /// The recipe parsing was successful.
  successful,

  /// The recipe parsing failed.
  failed,
}
