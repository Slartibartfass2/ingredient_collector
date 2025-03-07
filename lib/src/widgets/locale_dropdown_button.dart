import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../supported_locale.dart';

/// A [DropdownButton] for selecting a [SupportedLocale].
///
/// The [onChanged] callback is called when the selected locale changes.
class LocaleDropdownButton extends StatelessWidget {
  /// The callback for when the selected locale changes.
  final void Function(SupportedLocale) onChanged;

  /// Creates a new [LocaleDropdownButton].
  const LocaleDropdownButton({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    var value = SupportedLocale.values.firstWhere(
      (supportedLocale) => supportedLocale.locale.languageCode == context.locale.languageCode,
    );

    var items =
        SupportedLocale.values
            .map(
              (supportedLocale) =>
                  DropdownMenuItem(value: supportedLocale, child: Text(supportedLocale.name)),
            )
            .toList();

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: DropdownButton(
          items: items,
          value: value,
          onChanged: (newValue) async {
            if (newValue == null) {
              return;
            }
            onChanged.call(newValue);
          },
          style: const TextStyle(color: Colors.white, fontSize: 16),
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          dropdownColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
