// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pokemon_list_item.dart';
import '../../data/datasources/poke_api.dart';
import '../../data/providers/pokemon_providers.dart'; // Importa el provider
import '../widgets/animated_list_item.dart';
import '../widgets/page_transitions.dart';
import '../widgets/shimmer_loading.dart';
import 'pokemon_detail_screen.dart';
import 'favorites_screen.dart';
import 'pokearth_map_screen.dart';


class PokemonListScreen extends ConsumerStatefulWidget {
  final bool openFiltersAutomatically;
  final String? preSelectedFilter; // 'generation' o 'type'
  
  const PokemonListScreen({
    super.key,
    this.openFiltersAutomatically = false,
    this.preSelectedFilter,
  });

  @override
  ConsumerState<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends ConsumerState<PokemonListScreen> {
 
  List<PokemonListItem> _filtered = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<int, List<String>> _typesCache = {};

  static const _prefsKeyGen = 'pokedez_filter_generation';
  static const _prefsKeyTypes = 'pokedez_filter_types';

  @override
  void initState() {
    super.initState();
    // Ya no se llama a _load() aquí. El provider se carga automáticamente.
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
    // Si se solicitó abrir filtros automáticamente, hacerlo después del primer frame
    if (widget.openFiltersAutomatically) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openFilters();
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // La lógica de búsqueda ahora filtra sobre la lista que provee Riverpod.
    final allPokemons = ref.read(pokemonListProvider).asData?.value ?? [];
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.of(allPokemons));
    } else {
      final numericId = int.tryParse(q);
      setState(() {
        _filtered = allPokemons.where((p) {
          final matchName = p.name.toLowerCase().contains(q);
          final matchId = numericId != null && p.id == numericId;
          return matchName || matchId;
        }).toList();
      });
    }
  }

  void _onScroll() {
    // Obtenemos el notifier para llamar a fetchPokemons (load more)
    final notifier = ref.read(pokemonListProvider.notifier);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !notifier.isLoadingMore) {
      notifier.fetchPokemons(); // Llama al método del notifier para cargar más.
    }
  }

  // Se eliminan _load(), _loadMore() y _refresh(). Ahora se usa el notifier.
  // Ejemplo: para refrescar, se llamaría a ref.read(pokemonListProvider.notifier).refreshPokemons()

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el provider
    final pokemonListAsync = ref.watch(pokemonListProvider);

    // Sincronizamos la lista filtrada cuando los datos del provider cambian
    ref.listen<AsyncValue<List<PokemonListItem>>>(pokemonListProvider, (_, next) {
      next.whenData((pokemons) {
        // Si no hay búsqueda activa, actualizamos la lista filtrada.
        if (_searchController.text.isEmpty) {
          if (mounted) {
            setState(() {
              _filtered = pokemons;
            });
          }
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
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
              hintText: 'Buscar Pokémon...',
              hintStyle: GoogleFonts.nunito(color: Colors.grey, fontSize: 16),
              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            style: GoogleFonts.nunito(color: Colors.black87, fontSize: 16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _openFilters,
          ),
        ],
      ),
      body: pokemonListAsync.when(
        loading: () => const ShimmerLoading(itemCount: 15),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allPokemons) {
          // La UI ahora se construye a partir de `_filtered`
          // que se actualiza con la búsqueda y los datos del provider.
          if (_filtered.isEmpty && _searchController.text.isNotEmpty) {
            return const Center(child: Text('No se encontraron Pokémon.'));
          }
          
          final notifier = ref.watch(pokemonListProvider.notifier);

          return RefreshIndicator(
            onRefresh: () => ref.read(pokemonListProvider.notifier).refreshPokemons(),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final pokemon = _filtered[index];
                      return AnimatedListItem(
                        index: index,
                        child: _PokemonCard(
                          pokemon: pokemon,
                          typesCache: _typesCache,
                          onUpdateCache: (id, types) {
                            setState(() => _typesCache[id] = types);
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Muestra un indicador de carga al final de la lista si se están cargando más.
                if (notifier.isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Selecciona el índice de la lista
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(context, PageTransitions.fade(const FavoritesScreen()));
          }
          if (index == 2) {
            Navigator.pushReplacement(context, PageTransitions.fade(const PokearthMapScreen()));
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
            label: 'Pokéarth',
          ),
        ],
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Generación', style: Theme.of(context).textTheme.titleMedium),
                  DropdownButton<String>(
                    value: selectedGeneration,
                    isExpanded: true,
                    hint: const Text('Seleccionar generación'),
                    items: generations.map((g) => DropdownMenuItem(value: g, child: Text('Generación $g'))).toList(),
                    onChanged: (val) {
                      setModalState(() {
                        selectedGeneration = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Tipos', style: Theme.of(context).textTheme.titleMedium),
                  Wrap(
                    spacing: 8,
                    children: allTypes.map((type) {
                      final isSelected = selectedTypes.contains(type);
                      return FilterChip(
                        label: Text(type[0].toUpperCase() + type.substring(1)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedTypes.add(type);
                            } else {
                              selectedTypes.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            selectedGeneration = null;
                            selectedTypes.clear();
                          });
                        },
                        child: const Text('Limpiar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'generation': selectedGeneration,
                            'types': selectedTypes,
                          });
                        },
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // result will be a map like { 'generation': selectedGeneration, 'types': selectedTypes }
    if (result != null) {
      // Show loading animation before applying filters
      setState(() {
        // No es necesario un loading a pantalla completa, el filtrado es rápido.
        // Si fuera lento, se podría mostrar un indicador.
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
    final allPokemons = ref.read(pokemonListProvider).asData?.value ?? [];
    // If no filters, reset
    if ((selectedGeneration == null || selectedGeneration.isEmpty) && selectedTypes.isEmpty) {
      setState(() {
        _filtered = List.of(allPokemons);
      });
      return;
    }

    // El loading se maneja en la UI si es necesario, aquí solo filtramos.
    try {
      Set<String>? genNames;
      if (selectedGeneration != null && selectedGeneration.isNotEmpty) {
        final genMap = {'I': 1, 'II': 2, 'III': 3, 'IV': 4, 'V': 5, 'VI': 6, 'VII': 7, 'VIII': 8, 'IX': 9};
        final genId = genMap[selectedGeneration];
        if (genId != null) {
          genNames = await PokeApi.fetchPokemonNamesByGeneration(genId);
        }
      }

      List<Set<String>> sets = [];
      if (genNames != null) sets.add(genNames);
      for (final t in selectedTypes) {
        sets.add(await PokeApi.fetchPokemonNamesByType(t));
      }

      Set<String> finalNames;
      if (sets.isEmpty) {
        finalNames = allPokemons.map((e) => e.name).toSet();
      } else {
        finalNames = sets.reduce((a, b) => a.intersection(b));
      }

      setState(() {
        _filtered = allPokemons.where((p) => finalNames.contains(p.name)).toList();
      });
    } catch (e) {
       // Manejar el error, por ejemplo, mostrando un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aplicar filtros: $e')),
      );
    }
  }
}

/// Widget for Pokemon card in grid layout
class _PokemonCard extends StatefulWidget {
  final PokemonListItem pokemon;
  final Map<int, List<String>> typesCache;
  final Function(int, List<String>) onUpdateCache;

  const _PokemonCard({
    required this.pokemon,
    required this.typesCache,
    required this.onUpdateCache,
  });

  @override
  State<_PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<_PokemonCard>
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
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: InkWell(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.fade(PokemonDetailScreen(
                id: widget.pokemon.id,
                name: widget.pokemon.name,
              )),
            );
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[200]!, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
             /* Positioned(
                top: -40,
                right: -40,
                child: Image.asset(
                  'assets/images/pokeball_A.png',
                  width: 120,
                  height: 120,
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),*/
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'pokemon-${widget.pokemon.id}',
                      child: Image.network(
                        widget.pokemon.imageUrl,
                        fit: BoxFit.contain,
                        height: 100,
                        loadingBuilder: (context, child, progress) {
                          return progress == null ? child : const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error_outline, color: Colors.red, size: 40);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          _capitalize(widget.pokemon.name),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '#${widget.pokemon.id.toString().padLeft(3, '0')}',
                          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));
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
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: InkWell(
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          onTap: () {
            Navigator.push(
              context,
              PageTransitions.fade(PokemonDetailScreen(
                id: widget.pokemon.id,
                name: widget.pokemon.name,
              )),
            );
          },
          child: ListTile(
            leading: Hero(
              tag: 'pokemon-${widget.pokemon.id}',
              child: Image.network(
                widget.pokemon.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  return progress == null ? child : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error_outline, color: Colors.red);
                },
              ),
            ),
            title: Text(
              _capitalize(widget.pokemon.name),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '#${widget.pokemon.id.toString().padLeft(3, '0')}',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            trailing: FutureBuilder<List<String>>(
              future: Future.value(widget.typesCache[widget.pokemon.id] ?? PokeApi.fetchPokemonTypes(widget.pokemon.id)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !widget.typesCache.containsKey(widget.pokemon.id)) {
                  return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final types = snapshot.data!;
                if (!widget.typesCache.containsKey(widget.pokemon.id)) {
                  widget.onUpdateCache(widget.pokemon.id, types);
                }
                return Wrap(
                  spacing: 4,
                  children: types.map((type) => Chip(
                        label: Text(
                          _capitalize(type),
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                        ),
                        backgroundColor: Colors.black.withOpacity(0.3),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}