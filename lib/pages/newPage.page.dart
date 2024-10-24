import 'package:flutter/material.dart';

import 'package:recipes/pages/FavetPage.page.dart';
import 'package:recipes/pages/MiPaginaInicio.dart';
import 'package:recipes/services/Recipes.services.dart';

import '../widgets/custom_bottom_navbar.dart';

class NewRecipes extends StatefulWidget {
  const NewRecipes({super.key});

  @override
  State<NewRecipes> createState() => _NewRecipesState();
}

class _NewRecipesState extends State<NewRecipes> {
  String recipeName = '';
  List<String> ingredientsFood = [];
  List<String> ingredientsCantidades = [];
  late RecipesService recipesService;
  String description = '';
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    recipesService = RecipesService();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevas Recetas'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Nueva receta',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  recipeName = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Descripcion',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text('Nombre de la receta: $recipeName'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ingredientsFood.add('');
                  ingredientsCantidades.add('');
                });
              },
              child: Text('Agregar ingrediente'),
            ),
            ...ingredientsFood.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ingrediente ${index + 1}',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            ingredientsFood[index] = value;
                          });
                        },
                      ),
                    ),
                    
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cantidad en g}',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            ingredientsCantidades[index] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final List<Map<String, dynamic>> ingredients = [];
                for (int i = 0; i < ingredientsFood.length; i++) {
                  ingredients.add({
                    'food': ingredientsFood[i],
                    'amount': ingredientsCantidades[i],
                  });
                }
                final response = await RecipesService.postRecipesWithoutAuth(
                  'http://192.168.0.95:8080/api/v1/recipe/post', 
                  {
                    "name": recipeName,
                    "description": description,
                    "ingredientsDto": ingredients
                  }
                );
                print("response");
                print(response);
               
                if (response == "success") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MiPaginaInicio(),
                    ),
                  );
                }
              },
              child: Text('Guardar'),
            ),
          ],
        ),
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
