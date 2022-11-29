// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

void main() => runApp(const IngredientCollectorApp());

class IngredientCollectorApp extends StatelessWidget {
  const IngredientCollectorApp({super.key});

  final _title = 'Ingredient Collector';

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: _title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(_title),
          ),
          body: const Center(),
        ),
      );
}
