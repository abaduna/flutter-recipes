import 'package:flutter/material.dart';
import 'package:recipes/pages/MiPaginaInicio.dart';
import 'package:recipes/pages/newPage.page.dart';
import 'package:recipes/widgets/custom_bottom_navbar.dart';




class FavPage extends StatefulWidget {
  final List<dynamic> favRicipes;
 

  FavPage({super.key, required this.favRicipes});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
   int _selectedIndex = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.teal, // Cambia el color de fondo
      ),
      body: widget.favRicipes.isEmpty
          ? Center(child: Text('Nada guardado'))
          : ListView.builder(
              itemCount: widget.favRicipes.length,
              itemBuilder: (context, index) {
                return Card( // Usa un Card para cada elemento
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: widget.favRicipes[index]['imageUrl'] != null
                        ? Image.network(
                            widget.favRicipes[index]['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.fastfood),
                    title: Text(widget.favRicipes[index]['name'] ?? 'Sin nombre'),
                    subtitle: Text(widget.favRicipes[index]['description'] ?? 'Sin descripción'),
                  ),
                );
              },
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
