// lib/screens/pokearth_map_screen.dart

import 'package:flutter/material.dart';
import '../../data/mapa/pokearth_map_parser.dart';
import 'pokemon_list_screen.dart';
import 'favorites_screen.dart';

class PokearthMapScreen extends StatefulWidget {
  const PokearthMapScreen({super.key});
  @override State<PokearthMapScreen> createState() => _PokearthMapScreenState();
}

class _PokearthMapScreenState extends State<PokearthMapScreen> {
  late Future<List<PokearthArea>> _areas;

  @override
  void initState() {
    super.initState();
    _areas = PokearthMap.loadAreas();
  }

  void _onImageTap(TapDownDetails details, List<PokearthArea> areas, Size imageSize) {
    // Obtener la posición del toque
    final tapPosition = details.localPosition;

    // Buscar si el toque cae dentro de algún área
    for (final area in areas) {
      if (area.coordinates.contains(tapPosition)) {
        // Mostrar diálogo con la información del área
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(area.title),
            content: Text('Ubicación: ${area.href}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokéarth')),
      body: FutureBuilder<List<PokearthArea>>(
        future: _areas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar áreas: ${snapshot.error}'),
            );
          }

          final areas = snapshot.data ?? [];

          return InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.5,
            maxScale: 4.0,
            child: GestureDetector(
              onTapDown: (details) => _onImageTap(details, areas, Size.zero),
              child: Center(
                child: Image.asset(
                  'assets/images/pokearth.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Selecciona el índice del mapa
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PokemonListScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          } else if (index == 2) {
            // Ya estamos en el mapa, no hacer nada
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}