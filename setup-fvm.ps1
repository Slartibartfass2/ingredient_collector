#!\bin\bash

# Get dependencies
fvm flutter pub get

# Run code generator (used for Freezed)
echo "Generating freezed files"
fvm dart run build_runner build --delete-conflicting-outputs

# Run locale keys file code generator
echo "Generating locale keys file"
fvm dart run easy_localization:generate --format keys --output-dir lib/l10n --output-file locale_keys.g.dart

echo "Setup done!"
