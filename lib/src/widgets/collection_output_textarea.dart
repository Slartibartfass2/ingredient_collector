import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/locale_keys.g.dart';

/// The text area to display the collected ingredients.
///
/// The text area contains a button to copy the collected ingredients to the
/// clipboard.
class CollectionOutputTextArea extends StatelessWidget {
  /// The controller for the text area to display the collected ingredients.
  final controller = TextEditingController();

  /// Creates a new [CollectionOutputTextArea].
  CollectionOutputTextArea({super.key});

  @override
  Widget build(BuildContext context) {
    var copyButton = IconButton(
      icon: const Icon(Icons.copy),
      tooltip: LocaleKeys.collection_result_copy_tooltip.tr(),
      splashRadius: 20,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: controller.text))
            .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text(LocaleKeys.collection_result_copy_snackbar).tr(),
            ),
          );
        });
      },
    );

    var textArea = TextField(
      controller: controller,
      maxLines: 10,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: LocaleKeys.collection_result_text_hint.tr(),
      ),
    );

    return Stack(
      children: [
        textArea,
        Positioned(
          right: 0,
          child: copyButton,
        ),
      ],
    );
  }
}
