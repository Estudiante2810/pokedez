import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'pokemon_list_screen.dart';
import 'pokearth_map_screen.dart';
import 'favorites_screen.dart';
import 'trivia_screen.dart';
import '../widgets/language_switcher.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LanguageSwitcher(),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // 2. Header
                  Text(
                    'Pokédex',
                    style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 3. Sección de Filtros Rápidos (Grid 2x1)
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryCard(
                          title: l10n.generations,
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
                      const SizedBox(width: 20),
                      Expanded(
                        child: _CategoryCard(
                          title: l10n.types,
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

                  const SizedBox(height: 30),

                  // 4. Botones de Funcionalidad (Mapa, Favoritos, Trivia)
                  Text(
                    l10n.tools,
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Grid de herramientas
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25,
                    childAspectRatio: 2.2,
                    children: [
                      _ToolButton(
                        label: l10n.map,
                        color: Colors.blueAccent,
                        icon: Icons.map,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PokearthMapScreen()),
                        ),
                      ),
                      _ToolButton(
                        label: l10n.favorites,
                        color: Colors.redAccent,
                        icon: Icons.favorite,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      _ToolButton(
                        label: l10n.trivia,
                        color: Colors.purpleAccent,
                        icon: Icons.quiz,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TriviaScreen()),
                        ),
                      ),
                      _ToolButton(
                        label: l10n.pokemonList,
                        color: Colors.green,
                        icon: Icons.list_alt,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PokemonListScreen()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),
                  
                  // 5. Banner "Who's that Pokemon"
                  const _TriviaBanner(),
                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ],
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
        height: 120,
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
                    fontSize: 20,
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

class _TriviaBanner extends ConsumerWidget {
  const _TriviaBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
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
                    l10n.whoIsThatPokemon,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.testYourKnowledge,
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
                    child: Text(l10n.play),
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