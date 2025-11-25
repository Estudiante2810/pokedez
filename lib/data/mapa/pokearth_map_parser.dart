import 'dart:ui';
import 'package:xml/xml.dart';
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

    // 2. Parsea el XML/HTML
    final document = XmlDocument.parse(html);

    // 3. Busca todos los <area>
    final areas = <PokearthArea>[];

    for (final areaNode in document.findAllElements('area')) {
      final href = areaNode.getAttribute('href') ?? '';
      final title = areaNode.getAttribute('title') ?? '';
      final coordsStr = areaNode.getAttribute('coords') ?? '';

      // Solo soportamos rectángulos (todos en tu mapa lo son)
      if (coordsStr.isEmpty) continue;

      final coords = coordsStr.split(',').map(int.tryParse).toList();
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