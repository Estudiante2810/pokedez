// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon_list_item.dart';
import '../services/poke_api.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/page_transitions.dart';
import '../widgets/shimmer_loading.dart';
import 'pokemon_detail_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<PokemonListItem> _all = [];
  List<PokemonListItem> _filtered = [];
  bool _loading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  final Map<int, List<String>> _typesCache = {};

  static const _prefsKeyGen = 'pokedez_filter_generation';
  static const _prefsKeyTypes = 'pokedez_filter_types';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.of(_all));
    } else {
      setState(() => _filtered = _all.where((p) => p.name.contains(q)).toList());
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await PokeApi.fetchAllPokemons();
      setState(() { _all = list; });

      // Check saved filters and apply if present
      final prefs = await SharedPreferences.getInstance();
      final savedGen = prefs.getString(_prefsKeyGen);
      final savedTypes = prefs.getStringList(_prefsKeyTypes) ?? [];
      if ((savedGen == null || savedGen.isEmpty) && savedTypes.isEmpty) {
        setState(() { _filtered = List.of(list); _loading = false; });
      } else {
        // apply saved filters (this will update _filtered and loading state)
        await _applyFilters(savedGen, savedTypes);
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar Pokémon por nombre',
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF00D9FF)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: _loading
          ? const ShimmerLoading(itemCount: 15)
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
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: _filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No se encontraron Pokémon')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final p = _filtered[index];
                            return AnimatedListItem(
                              index: index,
                              delay: const Duration(milliseconds: 30),
                              child: _PokemonListTile(
                                pokemon: p,
                                typesCache: _typesCache,
                                onUpdateCache: (id, types) {
                                  if (mounted) {
                                    setState(() {
                                      _typesCache[id] = types;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Future<void> _openFilters() async {
    // Local state for filters inside the modal
    final List<String> selectedTypes = [];

    // fixed list of common types (can be extended or fetched later)
    const allTypes = [
      'normal', 'fire', 'water', 'grass', 'electric', 'ice', 'fighting', 'poison', 'ground', 'flying',
      'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
    ];

    // generations sample
    const generations = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];

  // Load saved filters to prefill modal
  final prefs = await SharedPreferences.getInstance();
  final savedGen = prefs.getString(_prefsKeyGen);
  final savedTypes = prefs.getStringList(_prefsKeyTypes) ?? [];
  String? selectedGeneration = savedGen != null && savedGen.isNotEmpty ? savedGen : null;
  selectedTypes.addAll(savedTypes);

    final result = await showModalBottomSheet<Map<String, dynamic>?> (
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          void toggleType(String t) {
            setModalState(() {
              if (selectedTypes.contains(t)) {
                selectedTypes.remove(t);
              } else {
                selectedTypes.add(t);
              }
            });
          }

          // abilities removed from filters (feature removed)

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Generación
                    Text('Generación', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: generations.map((g) {
                        final selected = selectedGeneration == g;
                        return FilterChip(
                          label: Text('Gen $g'),
                          selected: selected,
                          onSelected: (_) => setModalState(() => selectedGeneration = selected ? null : g),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Tipo
                    Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: allTypes.map((t) {
                        final selected = selectedTypes.contains(t);
                        return FilterChip(
                          label: Text(t),
                          selected: selected,
                          onSelected: (_) => toggleType(t),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Clear all filters and close
                              Navigator.of(context).pop({'generation': null, 'types': []});
                            },
                            icon: const Icon(Icons.clear_all),
                            label: const Text('Sin filtro'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE63946)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Return the selected filters to the caller
                              Navigator.of(context).pop({'generation': selectedGeneration, 'types': selectedTypes});
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Aplicar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );

    // result will be a map like { 'generation': selectedGeneration, 'types': selectedTypes }
    if (result != null) {
      // Show loading animation before applying filters
      setState(() {
        _loading = true;
      });

      // Animate transition
      await Future.delayed(const Duration(milliseconds: 300));

      // Save filters to prefs
      final gen = result['generation'] as String?;
      final types = (result['types'] as List<dynamic>?)?.cast<String>() ?? [];
      if (gen == null || gen.isEmpty) {
        await prefs.remove(_prefsKeyGen);
      } else {
        await prefs.setString(_prefsKeyGen, gen);
      }
      await prefs.setStringList(_prefsKeyTypes, types);

      // Apply filters
      await _applyFilters(gen, types);
      // Removed annoying snackbar message
    }
  }

  Future<void> _applyFilters(String? selectedGeneration, List<String> selectedTypes) async {
    // If no filters, reset
    if ((selectedGeneration == null || selectedGeneration.isEmpty) && selectedTypes.isEmpty) {
      setState(() {
        _filtered = List.of(_all);
        _loading = false;
      });
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      Set<String>? genNames;
      if (selectedGeneration != null && selectedGeneration.isNotEmpty) {
        // Map roman like 'I'->1
        final roman = selectedGeneration.toUpperCase();
        final romanToInt = <String,int>{'I':1,'II':2,'III':3,'IV':4,'V':5,'VI':6,'VII':7,'VIII':8,'IX':9};
        final gid = romanToInt[roman] ?? int.tryParse(roman);
        if (gid != null) {
          genNames = await PokeApi.fetchPokemonNamesByGeneration(gid);
        }
      }

      List<Set<String>> sets = [];
      if (genNames != null) sets.add(genNames);
      for (final t in selectedTypes) {
        final s = await PokeApi.fetchPokemonNamesByType(t);
        sets.add(s);
      }

      Set<String> finalNames;
      if (sets.isEmpty) {
        finalNames = _all.map((e) => e.name).toSet();
      } else {
        finalNames = sets.reduce((value, element) => value.intersection(element));
      }

      setState(() {
        _filtered = _all.where((p) => finalNames.contains(p.name)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}

/// Widget for individual Pokemon list item with tap animation
class _PokemonListTile extends StatefulWidget {
  final PokemonListItem pokemon;
  final Map<int, List<String>> typesCache;
  final Function(int, List<String>) onUpdateCache;

  const _PokemonListTile({
    required this.pokemon,
    required this.typesCache,
    required this.onUpdateCache,
  });

  @override
  State<_PokemonListTile> createState() => _PokemonListTileState();
}

class _PokemonListTileState extends State<_PokemonListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTapDown: (_) {
            _scaleController.forward();
          },
          onTapUp: (_) {
            _scaleController.reverse();
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context).push(
                SlidePageRoute(
                  page: PokemonDetailScreen(
                    id: widget.pokemon.id,
                    name: widget.pokemon.name,
                  ),
                ),
              );
            });
          },
          onTapCancel: () => _scaleController.reverse(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Hero(
                  tag: 'pokemon_${widget.pokemon.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.pokemon.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(widget.pokemon.name),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      widget.typesCache.containsKey(widget.pokemon.id)
                          ? Text(
                              '#${widget.pokemon.id}  •  ${widget.typesCache[widget.pokemon.id]!.map(_capitalize).join(', ')}',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          : FutureBuilder<List<String>>(
                              future: PokeApi.fetchPokemonTypes(widget.pokemon.id),
                              builder: (ctx, snap) {
                                if (snap.connectionState == ConnectionState.waiting) {
                                  return Row(
                                    children: const [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ],
                                  );
                                }
                                if (snap.hasError || snap.data == null) {
                                  return Text(
                                    '#${widget.pokemon.id}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  );
                                }
                                final types = snap.data!;
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  widget.onUpdateCache(widget.pokemon.id, types);
                                });
                                return Text(
                                  '#${widget.pokemon.id}  •  ${types.map(_capitalize).join(', ')}',
                                  style: TextStyle(color: Colors.grey[600]),
                                );
                              },
                            ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

