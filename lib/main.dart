import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipes/pages/FavetPage.page.dart';
import 'package:recipes/pages/newPage.page.dart';

import 'pages/MiPaginaInicio.dart';
import 'services/Recipes.services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MiPaginaInicio(),
    );
  }
}
