import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipes/pages/newPage.page.dart';
import 'package:recipes/services/Recipes.services.dart';
import 'package:recipes/widgets/custom_bottom_navbar.dart';

import 'FavetPage.page.dart';

class MiPaginaInicio extends StatefulWidget {
  const MiPaginaInicio({Key? key}) : super(key: key);

  @override
  _MiPaginaInicioState createState() => _MiPaginaInicioState();
}

class _MiPaginaInicioState extends State<MiPaginaInicio> {
  late Future<List<dynamic>> _recetasFuture;
  late RecipesService recipesService;
  int _selectedIndex = 0;
  List<dynamic> favRicipes = []; // Asegúrate de que esté inicializada
  
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
        backgroundColor: Colors.teal,
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
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: recetas[index]['imageUrl'] != null
                        ? Image.network(
                            recetas[index]['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.fastfood),
                    title: Text(recetas[index]['name'] ?? 'Sin nombre'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(recetas[index]['description'] ?? 'Sin descripción'),
                        const SizedBox(height: 8.0),
                        Text('Ingredientes:'),
                        ...?recetas[index]['ingredientsDto']?.map<Widget>((ingrediente) {
                          return Row(
                            children: [
                              Text(ingrediente['food'] ?? 'Ingrediente desconocido'),
                              const SizedBox(width: 8.0),
                              Text(ingrediente['amount'] ?? 'Cantidad desconocida'),
                              Text("gr"),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    onTap: () {
                      favRicipes.add(recetas[index]);
                      print(favRicipes);
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay recetas disponibles'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewRecipes(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: CustomBottomNavbar(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MiPaginaInicio(),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavPage(favRicipes: []),
            ),
          );
        } else if (index == 1) {
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
