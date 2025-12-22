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
  late TransformationController _transformationController;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _areas = PokearthMap.loadAreas();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _onImageTap(Offset tapPosition, List<PokearthArea> areas) {
    // Ajustar la posición del toque según el zoom actual
    final adjustedPosition = Offset(
      tapPosition.dx / _currentScale,
      tapPosition.dy / _currentScale,
    );

    // Buscar si el toque cae dentro de algún área
    for (final area in areas) {
      if (area.coordinates.contains(adjustedPosition)) {
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

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale + 0.2).clamp(1.0, 4.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale - 0.2).clamp(1.0, 4.0);
      _transformationController.value = Matrix4.identity()..scale(_currentScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _currentScale = 1.0;
      _transformationController.value = Matrix4.identity();
    });
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

          return Stack(
            children: [
              InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 1.0,
                maxScale: 4.0,
                panEnabled: _currentScale > 1.0, // Solo permitir pan si hay zoom
                scaleEnabled: false, // Desabilitar zoom por gesto
                child: GestureDetector(
                  onTapDown: (details) => _onImageTap(details.localPosition, areas),
                  child: Center(
                    child: Image.asset(
                      'assets/images/pokearth.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Botón de zoom in (abajo a la derecha)
              Positioned(
                bottom: 80,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _zoomIn,
                  mini: true,
                  child: const Icon(Icons.zoom_in),
                ),
              ),
              // Botón de zoom out (arriba del anterior)
              Positioned(
                bottom: 20,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _zoomOut,
                  mini: true,
                  child: const Icon(Icons.zoom_out),
                ),
              ),
              // Botón de reset zoom
              if (_currentScale > 1.0)
                Positioned(
                  bottom: 140,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _resetZoom,
                    mini: true,
                    child: const Icon(Icons.restart_alt),
                  ),
                ),
            ],
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