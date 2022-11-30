#!\bin\bash

# Get dependencies
flutter pub get

# Run code generator (used for Freezed)
flutter pub run build_runner build --delete-conflicting-outputs

echo "Setup done!"
