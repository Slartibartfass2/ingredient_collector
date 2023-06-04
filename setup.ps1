#!\bin\bash

# Get dependencies
flutter pub get

# Run code generator (used for Freezed)
echo "Generating freezed files"
dart run build_runner build --delete-conflicting-outputs

# Run locale keys file code generator
echo "Generating locale keys file"
dart run easy_localization:generate --format keys --output-dir lib/l10n --output-file locale_keys.g.dart

echo "Setup done!"
