import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../../data/models/pokemon_detail.dart';

class PokemonShareCard extends StatelessWidget {
  final PokemonDetail pokemon;
  final GlobalKey cardKey = GlobalKey(); // Para capturar el widget

  PokemonShareCard({
    super.key,
    required this.pokemon,
  });

  Future<void> shareAsImage() async {
    try {
      // Capturar el widget como imagen
      RenderRepaintBoundary boundary = 
          cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Guardar temporalmente
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${pokemon.name}_card.png');
      await file.writeAsBytes(pngBytes);

      // Compartir
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '¡Mira mi carta de ${pokemon.name}! #Pokedex',
      );
    } catch (e) {
      debugPrint('Error sharing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: cardKey,
      child: Container(
        width: 300,
        height: 500,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getTypeGradient(pokemon.types.isNotEmpty ? pokemon.types[0] : 'normal'),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Patrón de fondo sutil
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: PokeballBackgroundPainter(),
                ),
              ),
            ),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con nombre y HP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pokemon.name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          'HP ${pokemon.stats['hp'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tipos
                  Row(
                    children: pokemon.types.take(2).map((type) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Imagen del Pokémon
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            pokemon.spriteUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 80, color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stats principales
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('ATK', pokemon.stats['attack'] ?? 0),
                        const SizedBox(height: 6),
                        _buildStatRow('DEF', pokemon.stats['defense'] ?? 0),
                        const SizedBox(height: 6),
                        _buildStatRow('SPD', pokemon.stats['speed'] ?? 0),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Footer con número del Pokémon
                  Center(
                    child: Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (value / 255).clamp(0.0, 1.0),
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getStatColor(value),
                        _getStatColor(value).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> _getTypeGradient(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
      case 'water':
        return [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)];
      case 'grass':
        return [const Color(0xFF66BB6A), const Color(0xFF81C784)];
      case 'electric':
        return [const Color(0xFFFFD54F), const Color(0xFFFFA726)];
      case 'psychic':
        return [const Color(0xFFBA68C8), const Color(0xFFAB47BC)];
      case 'ice':
        return [const Color(0xFF81D4FA), const Color(0xFF4FC3F7)];
      case 'dragon':
        return [const Color(0xFF7E57C2), const Color(0xFF5E35B1)];
      case 'dark':
        return [const Color(0xFF5D4037), const Color(0xFF6D4C41)];
      case 'fairy':
        return [const Color(0xFFF48FB1), const Color(0xFFEC407A)];
      case 'fighting':
        return [const Color(0xFFE57373), const Color(0xFFEF5350)];
      case 'flying':
        return [const Color(0xFF90CAF9), const Color(0xFF64B5F6)];
      case 'poison':
        return [const Color(0xFFAB47BC), const Color(0xFF9C27B0)];
      case 'ground':
        return [const Color(0xFFD4A373), const Color(0xFFBF8F54)];
      case 'rock':
        return [const Color(0xFFA1887F), const Color(0xFF8D6E63)];
      case 'bug':
        return [const Color(0xFF9CCC65), const Color(0xFF8BC34A)];
      case 'ghost':
        return [const Color(0xFF7E57C2), const Color(0xFF673AB7)];
      case 'steel':
        return [const Color(0xFF90A4AE), const Color(0xFF78909C)];
      default:
        return [const Color(0xFF9E9E9E), const Color(0xFF757575)];
    }
  }
//mejor esto
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF6B6B);
      case 'water':
        return const Color(0xFF4FC3F7);
      case 'grass':
        return const Color(0xFF66BB6A);
      case 'electric':
        return const Color(0xFFFFD54F);
      case 'psychic':
        return const Color(0xFFBA68C8);
      case 'ice':
        return const Color(0xFF81D4FA);
      case 'dragon':
        return const Color(0xFF7E57C2);
      case 'dark':
        return const Color(0xFF5D4037);
      case 'fairy':
        return const Color(0xFFF48FB1);
      case 'fighting':
        return const Color(0xFFE57373);
      case 'flying':
        return const Color(0xFF90CAF9);
      case 'poison':
        return const Color(0xFFAB47BC);
      case 'ground':
        return const Color(0xFFD4A373);
      case 'rock':
        return const Color(0xFFA1887F);
      case 'bug':
        return const Color(0xFF9CCC65);
      case 'ghost':
        return const Color(0xFF7E57C2);
      case 'steel':
        return const Color(0xFF90A4AE);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getStatColor(int value) {
    if (value >= 120) return Colors.green.shade600;
    if (value >= 80) return Colors.blue.shade600;
    if (value >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}

// Painter para el fondo con patrón de Pokébola
class PokeballBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width * 0.8, size.height * 0.2);
    final radius = size.width * 0.3;

    // Círculo exterior
    canvas.drawCircle(center, radius, paint);

    // Línea horizontal
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Círculo central
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.2, paint);

    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
