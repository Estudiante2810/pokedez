import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/poke_api.dart';
import '../models/pokemon_list_item.dart';

final pokemonListProvider = StateNotifierProvider<PokemonListNotifier, AsyncValue<List<PokemonListItem>>>((ref) {
  return PokemonListNotifier();
});

class PokemonListNotifier extends StateNotifier<AsyncValue<List<PokemonListItem>>> {
    /// Reinicia los filtros activos
    void resetFilters() {
      _filterGeneration = null;
      _filterTypes = null;
    }
  PokemonListNotifier() : super(const AsyncValue.loading()) {
    fetchPokemons(); // Initial automatic fetch
  }



  int _offset = 0;
  final int _pageSize = 50; // Load 50 Pokémon at a time
  bool _hasMore = true;
  bool _isFetching = false; // Prevent multiple simultaneous fetches

  List<PokemonListItem> _allPokemons = [];

  // Filtros activos
  int? _filterGeneration;
  List<String>? _filterTypes;
  String? _searchQuery;

  bool get isLoadingMore => _isFetching; // Expose loading state for UI

  Future<void> fetchPokemons({
    bool isRefresh = false,
    int? generation,
    List<String>? types,
    String? searchQuery,
  }) async {
    if (_isFetching || (!isRefresh && !_hasMore)) return;

    _isFetching = true;

    // Guardar filtros activos
    _filterGeneration = generation;
    _filterTypes = types;
    _searchQuery = searchQuery;

    if (isRefresh) {
      _offset = 0;
      _allPokemons.clear();
      _hasMore = true;
      state = const AsyncValue.loading();
    } else {
      state = state;
    }

    try {
      List<PokemonListItem> filtered = [];
      int localOffset = _offset;
      bool keepFetching = true;

      while (filtered.length < _pageSize && keepFetching) {
        final newPokemons = await PokeApi.fetchAllPokemons(limit: _pageSize, offset: localOffset);
        if (newPokemons.isEmpty) {
          keepFetching = false;
          _hasMore = false;
          break;
        }
        localOffset += newPokemons.length;

        // Filtrado por generación
        List<PokemonListItem> toAdd = newPokemons;
        if (generation != null) {
          final genNames = await PokeApi.fetchPokemonNamesByGeneration(generation);
          toAdd = toAdd.where((p) => genNames.contains(p.name)).toList();
        }
        // Filtrado por tipos
        if (types != null && types.isNotEmpty) {
          for (final t in types) {
            final typeNames = await PokeApi.fetchPokemonNamesByType(t);
            toAdd = toAdd.where((p) => typeNames.contains(p.name)).toList();
          }
        }
        // Filtrado por búsqueda
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final q = searchQuery.trim().toLowerCase();
          final numericId = int.tryParse(q);
          toAdd = toAdd.where((p) {
            final matchName = p.name.toLowerCase().contains(q);
            final matchId = numericId != null && p.id == numericId;
            return matchName || matchId;
          }).toList();
        }
        filtered.addAll(toAdd);
        if (newPokemons.length < _pageSize) {
          keepFetching = false;
          _hasMore = false;
        }
      }

      _offset = localOffset;
      _allPokemons.addAll(filtered);
      state = AsyncValue.data(List.from(_allPokemons));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false;
      state = state.whenData((value) => List.from(_allPokemons));
    }
  }

  Future<void> refreshPokemons() async {
    _hasMore = true;
    await fetchPokemons(
      isRefresh: true,
      generation: _filterGeneration,
      types: _filterTypes,
      searchQuery: _searchQuery,
    );
  }

  Future<void> applyFilters({int? generation, List<String>? types, String? searchQuery}) async {
    _hasMore = true;
    _offset = 0;
    _allPokemons.clear();
    await fetchPokemons(isRefresh: true, generation: generation, types: types, searchQuery: searchQuery);
  }

  // Nuevo: aplicar solo búsqueda
  Future<void> applySearch(String? searchQuery) async {
    _hasMore = true;
    _offset = 0;
    _allPokemons.clear();
    await fetchPokemons(isRefresh: true, generation: _filterGeneration, types: _filterTypes, searchQuery: searchQuery);
  }

  /// Search globally across all pokemons (not just loaded ones)
  Future<void> globalSearch(String query) async {
    if (query.trim().isEmpty) {
      // Si la búsqueda está vacía, recarga la lista normal
      await refreshPokemons();
      return;
    }

    _isFetching = true;
    _searchQuery = query;
    state = const AsyncValue.loading();

    try {
      List<PokemonListItem> results = [];

      // Intenta búsqueda por nombre
      final nameResults = await PokeApi.searchPokemonByName(query);
      results.addAll(nameResults);

      // Si la entrada es numérica, también busca por ID
      final numericId = int.tryParse(query.trim());
      if (numericId != null) {
        final idResult = await PokeApi.searchPokemonById(numericId);
        if (idResult != null && !results.any((p) => p.id == idResult.id)) {
          results.add(idResult);
        }
      }

      _allPokemons = results;
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false;
    }
  }

  String? get searchQuery => _searchQuery;
}