// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pokemon_list_item.dart';
import '../services/poke_api.dart';
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

  String _capitalize(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar Pokémon por nombre',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        actions: [
          // Filtros button - abre una "cajita" (modal bottom sheet) con opciones placeholder
          TextButton.icon(
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            label: const Text('Filtros', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                            return ListTile(
                              leading: Image.network(
                                p.imageUrl,
                                width: 56,
                                height: 56,
                                errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported),
                              ),
                              title: Text(_capitalize(p.name)),
                              subtitle: _typesCache.containsKey(p.id)
                                  ? Text('#${p.id}  •  ${_typesCache[p.id]!.map(_capitalize).join(', ')}')
                                  : FutureBuilder<List<String>>(
                                      future: PokeApi.fetchPokemonTypes(p.id),
                                      builder: (ctx, snap) {
                                        if (snap.connectionState == ConnectionState.waiting) {
                                          return Row(
                                            children: const [
                                              SizedBox(width: 6),
                                              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                                            ],
                                          );
                                        }
                                        if (snap.hasError || snap.data == null) {
                                          return Text('#${p.id}');
                                        }
                                        final types = snap.data!;
                                        // cache for future builds
                                        WidgetsBinding.instance.addPostFrameCallback((_) {
                                          if (mounted) setState(() { _typesCache[p.id] = types; });
                                        });
                                        return Text('#${p.id}  •  ${types.map(_capitalize).join(', ')}');
                                      },
                                    ),
                              onTap: () {
                                // Navigate to detail screen
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PokemonDetailScreen(id: p.id, name: p.name),
                                ));
                              },
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
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: selectedGeneration,
                      hint: const Text('Selecciona generación (opcional)'),
                      items: [null, ...generations].map((g) {
                        return DropdownMenuItem<String?>(
                          value: g,
                          child: Text(g == null ? 'Sin filtro' : 'Generación $g'),
                        );
                      }).toList(),
                      onChanged: (v) => setModalState(() => selectedGeneration = v),
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Return the selected filters to the caller
                            Navigator.of(context).pop({'generation': selectedGeneration, 'types': selectedTypes});
                          },
                          child: const Text('Aplicar filtros'),
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
      if (!mounted) return;
      final summary = 'Generación: ${gen ?? 'Sin filtro'} • Tipos: ${types.isEmpty ? 'Ninguno' : types.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Filtros aplicados — $summary')));
    }
  }

  Future<void> _applyFilters(String? selectedGeneration, List<String> selectedTypes) async {
    // If no filters, reset
    if ((selectedGeneration == null || selectedGeneration.isEmpty) && selectedTypes.isEmpty) {
      setState(() => _filtered = List.of(_all));
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
