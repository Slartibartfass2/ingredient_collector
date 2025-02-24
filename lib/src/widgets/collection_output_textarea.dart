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

  Future<void> _onCopyButtonPressed(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: controller.text)).then((value) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text(LocaleKeys.collection_result_copy_snackbar).tr()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var copyButton = IconButton(
      splashRadius: 20,
      // ignore: avoid-redundant-async, async is still necessary here
      onPressed: () async => _onCopyButtonPressed(context),
      tooltip: LocaleKeys.collection_result_copy_tooltip.tr(),
      icon: const Icon(Icons.copy),
    );

    var textArea = TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: LocaleKeys.collection_result_text_hint.tr(),
        border: const OutlineInputBorder(),
      ),
      maxLines: 10,
    );

    return Stack(children: [textArea, Positioned(right: 0, child: copyButton)]);
  }
}
