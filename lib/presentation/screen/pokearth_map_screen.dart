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
  final GlobalKey _imageKey = GlobalKey();

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

  void _onImageTap(TapDownDetails details, List<PokearthArea> areas) {
    // Obtener la posición global del toque
    final globalPosition = details.globalPosition;
    
    // Obtener el RenderBox de la imagen para calcular su posición
    final renderBox = _imageKey.currentContext?.findRenderObject();
    if (renderBox is! RenderBox) return;
    
    // Calcular la posición local relativa a la imagen
    final localPosition = renderBox.globalToLocal(globalPosition);
    
    // Obtener el tamaño renderizado de la imagen en el widget
    final renderedSize = renderBox.size;
    
    // Tamaño original de la imagen (según el HTML)
    const double originalWidth = 1100.0;
    const double originalHeight = 850.0;
    
    // Calcular el factor de escala (tamaño original / tamaño renderizado)
    final scaleX = originalWidth / renderedSize.width;
    final scaleY = originalHeight / renderedSize.height;
    
    // Convertir las coordenadas locales a las coordenadas originales de la imagen
    final scaledPosition = Offset(
      localPosition.dx * scaleX,
      localPosition.dy * scaleY,
    );
    
    // Ajustar la posición del toque según el zoom actual
    final adjustedPosition = Offset(
      scaledPosition.dx / _currentScale,
      scaledPosition.dy / _currentScale,
    );

    // Buscar si el toque cae dentro de algún área
    String debugMessage = 'Coordenadas globales: (${globalPosition.dx.toStringAsFixed(2)}, ${globalPosition.dy.toStringAsFixed(2)})\n'
        'Coordenadas locales (widget): (${localPosition.dx.toStringAsFixed(2)}, ${localPosition.dy.toStringAsFixed(2)})\n'
        'Tamaño renderizado: ${renderedSize.width.toStringAsFixed(2)} x ${renderedSize.height.toStringAsFixed(2)}\n'
        'Factor escala: X=${scaleX.toStringAsFixed(2)}, Y=${scaleY.toStringAsFixed(2)}\n'
        'Coordenadas escaladas (imagen original): (${scaledPosition.dx.toStringAsFixed(2)}, ${scaledPosition.dy.toStringAsFixed(2)})\n'
        'Coordenadas ajustadas (con zoom): (${adjustedPosition.dx.toStringAsFixed(2)}, ${adjustedPosition.dy.toStringAsFixed(2)})\n'
        'Zoom actual: $_currentScale\n'
        'Total de áreas: ${areas.length}\n\n';

    PokearthArea? foundArea;
    for (final area in areas) {
      if (area.coordinates.contains(adjustedPosition)) {
        foundArea = area;
        break;
      }
    }

    if (foundArea != null) {
      debugMessage += '✓ Área encontrada: ${foundArea.title}\n'
          'Coordenadas del área: ${foundArea.coordinates}';
      // Mostrar diálogo con la información del área
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(foundArea!.title),
          content: Text(debugMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } else {
      debugMessage += '✗ No se encontró ningún área en este punto\n\n'
          'Áreas cercanas (primeras 5):';
      
      // Mostrar las primeras 5 áreas como referencia
      for (int i = 0; i < (areas.length > 5 ? 5 : areas.length); i++) {
        final area = areas[i];
        debugMessage += '\n- ${area.title}: ${area.coordinates}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug: Sin área detectada'),
          content: SingleChildScrollView(
            child: Text(debugMessage),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
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
                  onTapDown: (details) => _onImageTap(details, areas),
                  child: Center(
                    child: Image.asset(
                      'assets/images/pokearth.png',
                      fit: BoxFit.contain,
                      key: _imageKey,
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