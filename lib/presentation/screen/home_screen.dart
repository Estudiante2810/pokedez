import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'pokemon_list_screen.dart';
import 'pokearth_map_screen.dart';
import 'favorites_screen.dart';
import 'trivia_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el tamaño de la pantalla para el diseño responsivo
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor, //
      body: Stack(
        children: [
          // 1. Fondo Decorativo (Pokeball grande o Gradiente)
          Positioned(
            top: -50,
            right: -50,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/pokeball_A.png', 
                width: 200,
                height: 200,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // 2. Header
                  Text(
                    'Pokédex',
                    style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. Barra de Búsqueda Falsa (Botón de navegación)
                  _SearchTriggerButton(onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PokemonListScreen(),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 30),
                  
                  // 4. Sección de Filtros Rápidos (Grid 2x1)
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          title: 'Generaciones',
                          color: AppTheme.secondaryColor,
                          icon: Icons.filter_1,
                          onTap: () {
                            // Navegar a PokemonListScreen con filtro de generación pre-seleccionado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PokemonListScreen(
                                  openFiltersAutomatically: true,
                                  preSelectedFilter: 'generation',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _CategoryCard(
                          title: 'Tipos',
                          color: AppTheme.tertiaryColor,
                          icon: Icons.filter_2,
                          onTap: () {
                            // Navegar a PokemonListScreen con filtro de tipos pre-seleccionado
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PokemonListScreen(
                                  openFiltersAutomatically: true,
                                  preSelectedFilter: 'type',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 5. Botones de Funcionalidad (Mapa, Favoritos, Trivia)
                  Text(
                    'Herramientas',
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Grid de herramientas
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 2.5,
                    children: [
                      _ToolButton(
                        label: 'Mapa',
                        color: Colors.blueAccent,
                        icon: Icons.map,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PokearthMapScreen()),
                        ),
                      ),
                      _ToolButton(
                        label: 'Favoritos',
                        color: Colors.redAccent,
                        icon: Icons.favorite,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      _ToolButton(
                        label: 'Trivia',
                        color: Colors.purpleAccent,
                        icon: Icons.quiz,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TriviaScreen()),
                        ),
                      ),
                      _ToolButton(
                        label: 'Lista',
                        color: Colors.green,
                        icon: Icons.list_alt,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PokemonListScreen()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  
                  // 6. Banner "Who's that Pokemon"
                  const _TriviaBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTriggerButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchTriggerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Text(
              'Buscar Pokémon...',
              style: GoogleFonts.nunito(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({required this.title, required this.color, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.2)),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.containerColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriviaBanner extends StatelessWidget {
  const _TriviaBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TriviaScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B35FF), Color(0xFF8F65FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B35FF).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "¿Quién es ese Pokémon?",
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "¡Pon a prueba tu conocimiento!",
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TriviaScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6B35FF),
                      minimumSize: const Size(100, 30),
                    ),
                    child: const Text("JUGAR"),
                  )
                ],
              ),
            ),
            const Icon(Icons.catching_pokemon, size: 80, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}