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

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // La imagen del mapa
                    Image.asset(
                      'assets/images/pokearth.png', // ← tu imagen
                      fit: BoxFit.contain,
                      alignment: Alignment.topLeft,
                      // Capturamos el tamaño real renderizado
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

                    // Zonas clicables
                    if (_imageSize != null)
                      ...areas.map((area) {
                        final rect = area.coordinates;
                        final scaleX = _imageSize!.width / 1200;  // 1200px es el ancho original del mapa
                        final scaleY = _imageSize!.height / 900;  // 900px alto original (ajústalo si es diferente)

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
                              // Aquí puedes navegar a una pantalla de región, abrir URL, etc.
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