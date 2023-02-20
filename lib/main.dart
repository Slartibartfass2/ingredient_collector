// ignore_for_file: public_member_api_docs

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_io/io.dart' show Platform;

import 'l10n/locale_keys.g.dart';
import 'src/ingredient_output_generator.dart';
import 'src/models/meta_data_log.dart';
import 'src/models/recipe_parsing_job.dart';
import 'src/recipe_controller.dart';
import 'src/widgets/message_box.dart';

const _title = 'Ingredient Collector';
const recipeRowsAtBeginning = 2;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
      ],
      useOnlyLangCode: true,
      fallbackLocale: const Locale('en', ''),
      path: 'resources/langs',
      child: const IngredientCollectorApp(),
    ),
  );
}

class IngredientCollectorApp extends StatelessWidget {
  const IngredientCollectorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(_title),
          ),
          body: Container(
            alignment: Alignment.center,
            child: const AppBody(),
          ),
        ),
      );
}

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  double _getContainerWidth(double width) {
    if (width >= 1400) return 1320;
    if (width >= 1200) return 1140;
    if (width >= 992) return 960;
    if (width >= 768) return 720;
    if (width >= 576) return 540;
    return width - 20;
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var deviceWidth = queryData.size.width;
    var containerWidth = _getContainerWidth(deviceWidth);

    return Container(
      alignment: Alignment.center,
      width: containerWidth,
      margin: const EdgeInsets.only(top: 30, bottom: 10),
      child: const RecipeInputForm(),
    );
  }
}

class RecipeInputForm extends StatefulWidget {
  const RecipeInputForm({super.key});

  @override
  State<StatefulWidget> createState() => RecipeInputFormState();
}

class RecipeInputFormState extends State<RecipeInputForm> {
  final _formKey = GlobalKey<FormState>();

  int _id = 0;
  final _rowList = <RecipeInputRow>[];
  final _collectionResultController = TextEditingController();
  List<MessageBox> _messageBoxes = [];

  void _removeRow(RecipeInputRow row) {
    setState(() {
      _rowList.remove(row);
    });
  }

  void _addRow() {
    setState(() {
      _rowList.add(RecipeInputRow(_removeRow, _id++));
    });
  }

  MessageBox _createMessageBox(MetaDataLog log) {
    MessageBox box;
    switch (log.type) {
      case MetaDataLogType.error:
        box = ErrorMessageBox(
          title: log.title,
          message: log.message,
        );
        break;
      case MetaDataLogType.warning:
        box = WarningMessageBox(
          title: log.title,
          message: log.message,
        );
        break;
    }
    return box;
  }

  @override
  void initState() {
    for (var i = 0; i < recipeRowsAtBeginning; i++) {
      _addRow();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var submitButton = ElevatedButton(
      child: const Text(LocaleKeys.submit_button_text).tr(),
      onPressed: () async {
        var recipeInfos = _rowList
            .where(
              (row) =>
                  row.urlController.text.isNotEmpty &&
                  row.servingsController.text.isNotEmpty,
            )
            .map((row) => row.getData())
            .toList();

        if (_formKey.currentState!.validate() && recipeInfos.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(LocaleKeys.processing_recipes_text).tr(),
            ),
          );

          // Get first part of local language e.g. en_US -> en
          var language = Platform.localeName.split("_")[0];
          var parsingResults = await collectRecipes(recipeInfos, language);
          var metaDataLogs = parsingResults
              .map((result) => result.metaDataLogs)
              .expand((log) => log)
              .toList();
          var parsedRecipes = parsingResults
              .where((result) => result.recipe != null)
              .map((result) => result.recipe!)
              .toList();
          var collectionResult =
              createCollectionResultFromRecipes(parsedRecipes);

          setState(() {
            _messageBoxes = metaDataLogs.map(_createMessageBox).toList();
          });

          _collectionResultController.text =
              collectionResult.resultSortedByAmount;
        }
      },
    );

    var addRowButton = ElevatedButton(
      onPressed: _addRow,
      child: const Text(LocaleKeys.add_recipe_button_text).tr(),
    );

    var buttonPadding = const EdgeInsets.symmetric(
      vertical: 10,
    );

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          ..._messageBoxes,
          ..._rowList,
          Padding(
            padding: buttonPadding,
            child: addRowButton,
          ),
          Padding(
            padding: buttonPadding,
            child: submitButton,
          ),
          TextField(
            controller: _collectionResultController,
            maxLines: 10,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: LocaleKeys.collection_result_text_hint.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeInputRow extends StatelessWidget {
  final int index;
  final void Function(RecipeInputRow) removeRow;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController servingsController = TextEditingController();

  RecipeInputRow(this.removeRow, this.index, {super.key});

  RecipeParsingJob getData() {
    var url = Uri.parse(urlController.text);
    var servings = int.parse(servingsController.text);
    return RecipeParsingJob(url: url, servings: servings);
  }

  @override
  Widget build(BuildContext context) {
    var urlField = Expanded(
      child: UrlInputField(controller: urlController),
    );

    var servingsField = Padding(
      padding: const EdgeInsets.only(left: 10, right: 2),
      child: SizedBox(
        width: 100,
        child: ServingsInputField(controller: servingsController),
      ),
    );

    var closeButton = IconButton(
      icon: const Icon(Icons.close),
      tooltip: LocaleKeys.recipe_row_close_button_text.tr(),
      splashRadius: 20,
      onPressed: () {
        removeRow(this);
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          urlField,
          servingsField,
          closeButton,
        ],
      ),
    );
  }
}

class UrlInputField extends StatelessWidget {
  final TextEditingController controller;

  const UrlInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: LocaleKeys.url_input_field_label.tr(),
        ),
        keyboardType: TextInputType.url,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }

          var url = Uri.tryParse(value);

          var isUrl = url?.hasAbsolutePath ?? false;
          if (!isUrl) {
            return LocaleKeys.url_input_field_invalid_url_text.tr();
          }

          if (url != null && !isUrlSupported(url)) {
            return LocaleKeys.url_input_field_unsupported_url_text.tr();
          }

          return null;
        },
      );
}

class ServingsInputField extends StatelessWidget {
  final TextEditingController controller;

  const ServingsInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: LocaleKeys.servings_field_label.tr(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[1-9][0-9]*')),
        ],
      );
}
