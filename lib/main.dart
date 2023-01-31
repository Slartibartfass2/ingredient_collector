// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/ingredient_output_generator.dart';
import 'src/recipe_controller.dart';
import 'src/recipe_models.dart';

const _title = 'Ingredient Collector';
const recipeRowsAtBeginning = 4;

void main() => runApp(const IngredientCollectorApp());

class IngredientCollectorApp extends StatelessWidget {
  const IngredientCollectorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
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

  void removeRow(RecipeInputRow row) {
    setState(() {
      _rowList.remove(row);
    });
  }

  void addRow() {
    setState(() {
      _rowList.add(RecipeInputRow(removeRow, _id++));
    });
  }

  @override
  void initState() {
    for (var i = 0; i < recipeRowsAtBeginning; i++) {
      addRow();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var submitButton = ElevatedButton(
      child: const Text('Submit'),
      onPressed: () async {
        if (_formKey.currentState!.validate() && _rowList.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Processing Data'),
            ),
          );
          var recipeInfos = _rowList.map((row) => row.getData()).toList();
          var recipes = await collectRecipes(recipeInfos);
          var collectionResult = createCollectionResultFromRecipes(recipes);
          _collectionResultController.text =
              collectionResult.resultSortedByAmount;
        }
      },
    );

    var addRowButton = ElevatedButton(
      onPressed: addRow,
      child: const Text('Add recipe'),
    );

    var buttonPadding = const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 20,
    );

    return Form(
      key: _formKey,
      child: ListView(
        children: [
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
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'The collected ingredients are listed here',
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeInputRow extends StatelessWidget {
  final int index;
  final Function(RecipeInputRow) removeRow;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController servingsController = TextEditingController();

  RecipeInputRow(this.removeRow, this.index, {super.key});

  RecipeInfo getData() {
    var url = Uri.parse(urlController.text);
    var servings = int.parse(servingsController.text);
    return RecipeInfo(url: url, servings: servings);
  }

  @override
  Widget build(BuildContext context) {
    var urlField = Expanded(
      child: UrlInputField(controller: urlController),
    );

    var servingsField = Padding(
      padding: const EdgeInsets.only(left: 10, right: 2),
      child: SizedBox(
        width: 120,
        child: ServingsInputField(controller: servingsController),
      ),
    );

    var closeButton = IconButton(
      icon: const Icon(Icons.close),
      tooltip: 'Remove recipe URL',
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
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Recipe URL',
        ),
        keyboardType: TextInputType.url,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the recipe url';
          }
          var isUrl = Uri.tryParse(value)?.hasAbsolutePath ?? false;
          if (!isUrl) {
            return 'Please enter a valid url';
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
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Servings',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp('[1-9][0-9]*')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Invalid value';
          }
          return null;
        },
      );
}
