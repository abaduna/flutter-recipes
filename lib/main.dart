import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipes/pages/newPage.page.dart';

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
  late Future<List<dynamic>> _recetasFuture;
  late RecipesService recipesService;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    recipesService = RecipesService();
    _recetasFuture = cargarRecetas();
  }

  Future<List<dynamic>> cargarRecetas() async {
    String url = 'http://192.168.0.95:8080/api/v1/recipe/get';
    try {
      dynamic resultado = await RecipesService.getRecipesWithoutAuth(url);
      print('resultado');
      print(resultado);
      if (resultado != null && resultado is String) {
        return json.decode(utf8.decode(resultado.codeUnits));
      } else {
        throw Exception('El resultado no es una cadena JSON válida');
      }
    } catch (e) {
      print('Error al cargar las recetas: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _recetasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final recetas = snapshot.data!;
            return ListView.builder(
              itemCount: recetas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recetas[index]['name'] ?? 'Sin nombre'),
                  subtitle: Text(recetas[index]['description'] ?? 'Sin descripción'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewRecipes(),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No hay recetas disponibles'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_label),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
             Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewRecipes(),
                      ),
                    );
          }
        },
      ),
    );
  }
}
