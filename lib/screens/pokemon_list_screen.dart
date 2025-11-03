import 'package:flutter/material.dart';

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
    setState(() { _loading = true; _error = null; });
    try {
      final list = await PokeApi.fetchAllPokemons();
      setState(() { _all = list; _filtered = List.of(list); _loading = false; });
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
                              subtitle: Text('#${p.id}'),
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

  void _openFilters() {
    // Local state for filters inside the modal
  String? selectedGeneration;
    final List<String> selectedTypes = [];
    final List<String> enteredAbilities = [];
    final TextEditingController abilityController = TextEditingController();

    // fixed list of common types (can be extended or fetched later)
    const allTypes = [
      'normal', 'fire', 'water', 'grass', 'electric', 'ice', 'fighting', 'poison', 'ground', 'flying',
      'psychic', 'bug', 'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy',
    ];

    // generations sample
    const generations = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];

    showModalBottomSheet<void>(
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

          void addAbility() {
            final text = abilityController.text.trim().toLowerCase();
            if (text.isNotEmpty && !enteredAbilities.contains(text)) {
              setModalState(() {
                enteredAbilities.add(text);
                abilityController.clear();
              });
            }
          }

          void removeAbility(String a) {
            setModalState(() => enteredAbilities.remove(a));
          }

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

                    // Habilidad
                    Text('Habilidad', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: abilityController,
                            decoration: const InputDecoration(hintText: 'Escribe una habilidad y presiona Añadir'),
                            onSubmitted: (_) => addAbility(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: addAbility, child: const Text('Añadir')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (enteredAbilities.isEmpty)
                      const Text('No se han añadido habilidades', style: TextStyle(color: Colors.grey))
                    else
                      Wrap(
                        spacing: 8,
                        children: enteredAbilities.map((a) => InputChip(label: Text(a), onDeleted: () => removeAbility(a))).toList(),
                      ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // For now, just show selected filters as a quick feedback and close
                            final summary = 'Generación: ${selectedGeneration ?? 'Sin filtro'} • Tipos: ${selectedTypes.isEmpty ? 'Ninguno' : selectedTypes.join(', ')} • Habilidades: ${enteredAbilities.isEmpty ? 'Ninguna' : enteredAbilities.join(', ')}';
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Filtros aplicados — $summary')));
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
  }
}
