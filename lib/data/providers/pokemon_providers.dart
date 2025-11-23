import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/poke_api.dart';
import '../models/pokemon_list_item.dart';

final pokemonListProvider = StateNotifierProvider<PokemonListNotifier, AsyncValue<List<PokemonListItem>>>((ref) {
  return PokemonListNotifier();
});

class PokemonListNotifier extends StateNotifier<AsyncValue<List<PokemonListItem>>> {
  PokemonListNotifier() : super(const AsyncValue.loading()) {
    fetchPokemons(); // Initial automatic fetch
  }

  int _offset = 0;
  final int _pageSize = 50; // Load 50 Pokémon at a time
  final int _maxPokemons = 200; // Maximum of 200 Pokémon in the list
  bool _hasMore = true;
  bool _isFetching = false; // Prevent multiple simultaneous fetches

  List<PokemonListItem> _allPokemons = [];

  bool get isLoadingMore => _isFetching; // Expose loading state for UI

  Future<void> fetchPokemons({bool isRefresh = false}) async {
    if (!_hasMore || _isFetching) return; // Avoid fetching if already fetching or no more data

    _isFetching = true; // Set fetching flag

    if (isRefresh) {
      state = const AsyncValue.loading(); // Show full loading indicator on refresh
    } else {
      state = AsyncValue.data(_allPokemons); // Keep current data while loading more
    }

    try {
      final newPokemons = await PokeApi.fetchAllPokemons(limit: _pageSize, offset: _offset);

      if (newPokemons.isEmpty || newPokemons.length < _pageSize) {
        _hasMore = false; // No more Pokémon to load
      }

      if (isRefresh) {
        _allPokemons = newPokemons;
        _offset = newPokemons.length;
      } else {
        _allPokemons.addAll(newPokemons);
        _offset += newPokemons.length;

        // Ensure the list does not exceed the maximum size
        if (_allPokemons.length > _maxPokemons) {
          _allPokemons.removeRange(0, _allPokemons.length - _maxPokemons);
        }
      }

      state = AsyncValue.data(_allPokemons);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false; // Reset fetching flag
    }
  }

  Future<void> refreshPokemons() async {
    _offset = 0;
    _hasMore = true;
    _allPokemons.clear();
    await fetchPokemons(isRefresh: true);
  }
}