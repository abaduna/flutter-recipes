import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:recipes/pages/FavetPage.page.dart';
import 'package:recipes/pages/MiPaginaInicio.dart';
import 'package:recipes/pages/newPage.page.dart';
import 'package:recipes/services/Recipes.services.dart';
import 'package:recipes/widgets/custom_bottom_navbar.dart';

class SelectFoodPage extends StatefulWidget {
  const SelectFoodPage({super.key});

  @override
  State<SelectFoodPage> createState() => _SelectFoodPageState();
}

class _SelectFoodPageState extends State<SelectFoodPage> {
  late RecipesService recipesService;
  List<dynamic> _Foods = [];
  int _selectedIndex = 3;
  List<dynamic> selectedFoods = [];

  @override
  void initState() {
    super.initState();
    recipesService = RecipesService();
    cargarRecetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Comida y la cantidad'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: selectedFoods.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<dynamic>(
                          isExpanded: true,
                          hint: const Text('Selecciona una comida'),
                          value: selectedFoods[index],
                          items: _Foods.map<DropdownMenuItem<dynamic>>((food) {
                            String foodName = food['nane'].toString();
                            return DropdownMenuItem<dynamic>(
                              value: food,
                              child: Text(foodName),
                            );
                          }).toList(),
                          onChanged: (dynamic newValue) {
                            setState(() {
                              selectedFoods[index] = newValue;
                              print('Valor seleccionado: $newValue');
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            if (selectedFoods.length > 1) {
                              selectedFoods.removeAt(index);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedFoods.add(null);
              });
            },
            child: const Text('Agregar otra comida'),
          ),
          ElevatedButton(
            onPressed: () {
              FoodsSelected(selectedFoods);
            },
            child: const Text('Confirmar selección'),
          ),
        ],
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
          else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectFoodPage(),
              ),
            );
          }
        },
      ),
    );
  }
  
  Future<void> cargarRecetas() async {
    String url = 'http://192.168.0.95:8080/api/v1/recipe/food';
    dynamic result = await RecipesService.postRecipesWithoutAuth(url, {});
    if (result != null) {
      if (result is String) {
        print('result');
        print(result);
        setState(() {
          _Foods = json.decode(utf8.decode(result.codeUnits));
        });
      } else if (result is List) {
        setState(() {
          _Foods = result;
        });
      }
    }
    throw Exception('No se pudieron cargar las recetas');
  }

  void FoodsSelected(List<dynamic> selectedFoods) async {
    print('selectedFoods');
    print(selectedFoods);
    dynamic result = await RecipesService.postRecipesWithoutAuth('http://192.168.0.95:8080/api/v1/recipe/posibleFood', selectedFoods);
    
    if (result != null && context.mounted) {
      // Decodificar el JSON si viene como String
      List<dynamic> recipes = result is String ? json.decode(result) : result;
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Recetas Posibles'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: recipes.map((recipe) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre: ${recipe['name']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Descripción: ${recipe['description']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }
}
