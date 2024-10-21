import 'dart:convert';

import 'package:flutter/material.dart';

import 'services/Recipes.services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MiPaginaInicio(),
    );
  }
}

class MiPaginaInicio extends StatefulWidget {
  const MiPaginaInicio({Key? key}) : super(key: key);

  @override
  _MiPaginaInicioState createState() => _MiPaginaInicioState();
}

class _MiPaginaInicioState extends State<MiPaginaInicio> {
  List<dynamic> recetas = [];
  late RecipesService recipesService;

  @override
  void initState() {
    super.initState();
    recipesService = RecipesService();
    cargarRecetas();
  }

  Future<void> cargarRecetas() async {
    String url = 'http://192.168.0.95:8080/api/v1/recipe/get';
    try {
      dynamic resultado = await RecipesService.getRecipesWithoutAuth(url);
      print('resultado');
      print(resultado);
      if (resultado != null && resultado is String) {
        setState(() {
          recetas = json.decode(utf8.decode(resultado.codeUnits));
        });
      } else {
        print('El resultado no es una cadena JSON válida');
      }
    } catch (e) {
      print('Error al cargar las recetas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi app Flutter con estado'),
      ),
      body: recetas.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recetas[index]['name'] ?? 'Sin nombre'),
                  subtitle: Text(recetas[index]['description'] ?? 'Sin descripción'),
                );
              },
            ),
    );
  }
}
