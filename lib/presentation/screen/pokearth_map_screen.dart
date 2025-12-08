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
  final TransformationController _transformationController = TransformationController();

  void _zoomIn() {
    final scale = _transformationController.value;
    _transformationController.value = scale.scaled(1.2);
  }

  void _zoomOut() {
    final scale = _transformationController.value;
    _transformationController.value = scale.scaled(0.8);
  }

  late Future<List<PokearthArea>> _areasFuture;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _areasFuture = PokearthMap.loadAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokéarth')),
      body: FutureBuilder<List<PokearthArea>>(
        future: _areasFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final areas = snapshot.data!;

          return Stack(
            children: [
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Image.asset(
                          'assets/images/pokearth.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.topLeft,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame == null) return const SizedBox();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _imageSize = Size(
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    ));
                              }
                            });
                            return child;
                          },
                        ),

                        if (_imageSize != null)
                          ...areas.map((area) {
                            final rect = area.coordinates;
                            final scaleX = _imageSize!.width / 1100; // Ajusta según el ancho original del mapa
                            final scaleY = _imageSize!.height / 850; // Ajusta según el alto original del mapa

                            return Positioned(
                              left: rect.left * scaleX,
                              top: rect.top * scaleY,
                              width: rect.width * scaleX,
                              height: rect.height * scaleY,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Vas a: ${area.title}')),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red.withOpacity(0.4), width: 2),
                                    color: Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      area.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        backgroundColor: Colors.black54,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: _zoomIn,
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      onPressed: _zoomOut,
                      child: const Icon(Icons.zoom_out),
                    ),
                  ],
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