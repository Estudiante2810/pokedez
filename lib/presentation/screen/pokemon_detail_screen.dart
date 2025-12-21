import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/pokemon_detail.dart';
import '../../data/models/pokemon_list_item.dart';
import '../../data/datasources/poke_api.dart';
import '../widgets/page_transitions.dart';
import '../widgets/radar_chart.dart';
import '../widgets/pokemon_share_card.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int id;
  final String name;

  const PokemonDetailScreen({super.key, required this.id, required this.name});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen>
    with TickerProviderStateMixin {
  PokemonDetail? _detail;
  List<PokemonListItem> _evolutions = [];
  String? _error;
  bool _loading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _tabController = TabController(length: 3, vsync: this);

    _load();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // fetch detail and evolutions individually to prevent type errors
      final detail = await PokeApi.fetchPokemonDetail(widget.id);
      final evolutions = await PokeApi.fetchEvolutionChain(widget.id);

      // Verificar si el Pokémon es favorito
      final box = await Hive.openBox<PokemonDetail>('favorites');
      if (box.containsKey(detail.id)) {
        detail.isFavorite = true;
      }

      setState(() {
        _detail = detail;
        _evolutions = evolutions;
        _loading = false;
      });

      // Start animations after data loads
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _capitalize(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo blanquecino
      appBar: AppBar(
        title: Text(_capitalize(widget.name)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_detail != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                final shareCard = PokemonShareCard(pokemon: _detail!);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    content: shareCard,
                    actions: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Cerrar'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await shareCard.shareAsImage();
                                if (context.mounted) Navigator.pop(context);
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Compartir'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
        bottom: _loading || _error != null || _detail == null
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Info Básica', icon: Icon(Icons.info_outline)),
                  Tab(text: 'Estadísticas', icon: Icon(Icons.bar_chart)),
                  Tab(text: 'Combate', icon: Icon(Icons.shield_outlined)),
                ],
              ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Reintentar'))
                    ],
                  ),
                )
              : _detail == null
                  ? const Center(child: Text('No data'))
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBasicInfoTab(),
                            _buildStatsTab(),
                            _buildCombatTab(),
                          ],
                        ),
                      ),
                    ),
      floatingActionButton: _loading || _error != null || _detail == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                setState(() {
                  _detail!.toggleFavorite();
                });

                // Guardar o eliminar en Hive
                final box = await Hive.openBox<PokemonDetail>('favorites');
                if (_detail!.isFavorite) {
                  box.put(_detail!.id, _detail!);
                } else {
                  box.delete(_detail!.id);
                }
              },
              backgroundColor: _detail!.isFavorite
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              child: Icon(
                _detail!.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_detail!.spriteUrl.isNotEmpty)
            Hero(
              tag: 'pokemon_${_detail!.id}',
              child: Center(
                child: _FloatingPokemonImage(
                  imageUrl: _detail!.spriteUrl,
                ),
              ),
            ),
          const SizedBox(height: 12),
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 400),
            child: Center(
              child: Text(
                '#${_detail!.id}  ${_capitalize(_detail!.name)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // types
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 600),
            child: Center(
              child: Wrap(
                spacing: 8,
                children: _detail!.types
                    .map((t) => Chip(label: Text(_capitalize(t))))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // basic info
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 800),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('Height',
                        style: Theme.of(context).textTheme.labelLarge),
                    Text('${_detail!.height / 10} m',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                Column(
                  children: [
                    Text('Weight',
                        style: Theme.of(context).textTheme.labelLarge),
                    Text('${_detail!.weight / 10} kg',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
                 if (_detail!.eggGroups.isNotEmpty)
                  Column(
                    children: [
                      Text('Egg Groups',
                          style: Theme.of(context).textTheme.labelLarge),
                      Text(_detail!.eggGroups.map(_capitalize).join(', '),
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // abilities
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Abilities',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _detail!.abilities
                      .map((a) => Chip(label: Text(_capitalize(a))))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // evolutions
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evolutions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_evolutions.isEmpty)
                  const Text('No evolutions found')
                else
                  SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _evolutions.length,
                      separatorBuilder: (_, i) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lv ${16 + (i * 16)}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00D9FF), // Cyan neón
                              ),
                            ),
                          ),
                        ],
                      ),
                      itemBuilder: (context, i) {
                        final ev = _evolutions[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              ScalePageRoute(
                                page: PokemonDetailScreen(
                                    id: ev.id, name: ev.name),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    ev.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.image_not_supported, size: 50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _capitalize(ev.name),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '#${ev.id}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    // Calculate total stats
    final totalStats = _detail!.stats.values.reduce((a, b) => a + b);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Radar Chart
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stats Overview',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    height: 250,
                    child: StatsRadarChart(
                      data: _detail!.stats,
                      maxValue: 255,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Total stats display
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Total Stats: $totalStats',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed stats with bars
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detailed Stats',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._detail!.stats.entries.map((e) {
                  final value = e.value;
                  final pct = (value / 255).clamp(0.0, 1.0);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_capitalize(e.key)),
                            Text('$value (${(pct * 100).toInt()}%)')
                          ],
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: pct),
                          duration: const Duration(milliseconds: 2000),
                          curve: Curves.easeOutCubic,
                          builder: (context, animValue, child) {
                            return LinearProgressIndicator(
                              value: animValue,
                              minHeight: 8,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Moves
          _AnimatedDetailSection(
            delay: const Duration(milliseconds: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moves',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (_detail!.moves.isEmpty)
                  const Text('No moves available')
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _detail!.moves
                        .take(10)
                        .map((m) => Chip(label: Text(_capitalize(m))))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombatTab() {
    final weaknesses = <String, double>{};
    final resistances = <String, double>{};
    final immunities = <String>[];

    _detail!.typeMatchups.forEach((type, factor) {
      if (factor > 1) {
        weaknesses[type] = factor;
      } else if (factor < 1 && factor > 0) {
        resistances[type] = factor;
      } else if (factor == 0) {
        immunities.add(type);
      }
    });

    // Sort by effectiveness
    final sortedWeaknesses = weaknesses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedResistances = resistances.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchupSection('Debilidades', sortedWeaknesses),
          const SizedBox(height: 24),
          _buildMatchupSection('Resistencias', sortedResistances),
          const SizedBox(height: 24),
          if (immunities.isNotEmpty)
            _buildImmunitySection('Inmunidades', immunities),
        ],
      ),
    );
  }

  Widget _buildMatchupSection(String title, List<MapEntry<String, double>> matchups) {
    if (matchups.isEmpty) return const SizedBox.shrink();

    return _AnimatedDetailSection(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: matchups.map((e) {
              return Chip(
                label: Text('${_capitalize(e.key)} (x${e.value})'),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImmunitySection(String title, List<String> immunities) {
    return _AnimatedDetailSection(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: immunities.map((type) {
              return Chip(
                label: Text(_capitalize(type)),
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Widget for animating detail sections with staggered fade and slide
class _AnimatedDetailSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedDetailSection({
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_AnimatedDetailSection> createState() => _AnimatedDetailSectionState();
}

class _AnimatedDetailSectionState extends State<_AnimatedDetailSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // Más lento
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Widget for floating Pokemon image with continuous animation
class _FloatingPokemonImage extends StatefulWidget {
  final String imageUrl;

  const _FloatingPokemonImage({required this.imageUrl});

  @override
  State<_FloatingPokemonImage> createState() => _FloatingPokemonImageState();
}

class _FloatingPokemonImageState extends State<_FloatingPokemonImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Image.network(
                widget.imageUrl,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(
                  Icons.catching_pokemon,
                  size: 180,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


