import 'package:flutter/material.dart';

import '../models/pokemon_detail.dart';
import '../models/pokemon_list_item.dart';
import '../services/poke_api.dart';
import '../widgets/page_transitions.dart';

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

    _load();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // fetch detail and evolutions in parallel
      final detailFuture = PokeApi.fetchPokemonDetail(widget.id);
      final evoFuture = PokeApi.fetchEvolutionChain(widget.id);
      final results = await Future.wait([detailFuture, evoFuture]);
      final d = results[0] as PokemonDetail;
      final ev = results[1] as List<PokemonListItem>;
      setState(() {
        _detail = d;
        _evolutions = ev;
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
                        child: SingleChildScrollView(
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
                                delay: const Duration(milliseconds: 400), // Más lento
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
                                delay: const Duration(milliseconds: 600), // Más lento
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
                                delay: const Duration(milliseconds: 800), // Más lento
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Text('Height'),
                                        const SizedBox(height: 4),
                                        Text('${_detail!.height / 10} m')
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text('Weight'),
                                        const SizedBox(height: 4),
                                        Text('${_detail!.weight / 10} kg')
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // stats
                              _AnimatedDetailSection(
                                delay: const Duration(milliseconds: 1000), // Más lento
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Stats',
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
                                                Text(value.toString())
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(begin: 0.0, end: pct),
                                              duration: const Duration(milliseconds: 2000), // MÁS LENTO
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
                              const SizedBox(height: 12),

                              // abilities
                              _AnimatedDetailSection(
                                delay: const Duration(milliseconds: 1200), // Más lento
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
                                delay: const Duration(milliseconds: 1400), // Más lento
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
                                        height: 120,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _evolutions.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 12),
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
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.network(
                                                      ev.imageUrl,
                                                      width: 80,
                                                      height: 80,
                                                      errorBuilder: (_, __, ___) =>
                                                          const Icon(Icons
                                                              .image_not_supported),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(_capitalize(ev.name)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // moves (first 10)
                              _AnimatedDetailSection(
                                delay: const Duration(milliseconds: 1600), // Más lento
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
                                            .map((m) => InputChip(label: Text(m)))
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
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


