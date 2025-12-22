import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;

class PokearthArea {
  final String href;
  final Rect coordinates; // left, top, right, bottom
  final String title;

  PokearthArea({
    required this.href,
    required this.coordinates,
    required this.title,
  });

  @override
  String toString() => '$title → $href ($coordinates)';
}

class PokearthMap {
  static Future<List<PokearthArea>> loadAreas() async {
    // 1. Carga el archivo HTML
    final html = await rootBundle.loadString('assets/ubicaicones.html');

    // 2. Parsea usando expresiones regulares (más tolerante con HTML)
    final areas = <PokearthArea>[];

    // Patrón para extraer etiquetas <area>
    final areaPattern = RegExp(
      r'<area\s+([^>]+)>',
      multiLine: true,
    );

    for (final match in areaPattern.allMatches(html)) {
      final attributes = match.group(1) ?? '';

      // Extraer atributos
      final hrefMatch = RegExp(r'href="([^"]*)"').firstMatch(attributes);
      final titleMatch = RegExp(r'title="([^"]*)"').firstMatch(attributes);
      final coordsMatch = RegExp(r'coords="([^"]*)"').firstMatch(attributes);

      if (hrefMatch == null || titleMatch == null || coordsMatch == null) {
        continue;
      }

      final href = hrefMatch.group(1) ?? '';
      final title = titleMatch.group(1) ?? '';
      final coordsStr = coordsMatch.group(1) ?? '';

      if (coordsStr.isEmpty) continue;

      // Parsear coordenadas
      final coords = coordsStr
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .toList();

      if (coords.length != 4 || coords.any((e) => e == null)) continue;

      final left = coords[0]!.toDouble();
      final top = coords[1]!.toDouble();
      final right = coords[2]!.toDouble();
      final bottom = coords[3]!.toDouble();

      areas.add(PokearthArea(
        href: href,
        title: title,
        coordinates: Rect.fromLTRB(left, top, right, bottom),
      ));
    }

    return areas;
  }
}