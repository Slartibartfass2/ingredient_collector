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
import 'src/widgets/recipe_input_row.dart';

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
      _rowList.add(RecipeInputRow(_removeRow));
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
        // Get first part of local language e.g. en_US -> en
        var language = Platform.localeName.split("_")[0];

        var recipeJobs = _rowList
            .where(
              (row) =>
                  row.urlController.text.isNotEmpty &&
                  row.servingsController.text.isNotEmpty,
            )
            .map(
              (row) => RecipeParsingJob(
                url: Uri.parse(row.urlController.text),
                servings: int.parse(row.servingsController.text),
                language: language,
              ),
            )
            .toList();

        if (_formKey.currentState!.validate() && recipeJobs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(LocaleKeys.processing_recipes_text).tr(),
            ),
          );

          var parsingResults = await collectRecipes(recipeJobs, language);
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
