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
  bool _hasMore = true;
  bool _isFetching = false; // Prevent multiple simultaneous fetches

  List<PokemonListItem> _allPokemons = [];

  bool get isLoadingMore => _isFetching; // Expose loading state for UI

  Future<void> fetchPokemons({bool isRefresh = false}) async {
    if (_isFetching || (!isRefresh && !_hasMore)) return;

    _isFetching = true;

    // Notificar a la UI que se está cargando, pero sin cambiar los datos actuales si es "load more"
    if (isRefresh) {
      _offset = 0;
      _allPokemons.clear();
      state = const AsyncValue.loading();
    } else {
      // For loading more, we just update the fetching flag and the UI will use isLoadingMore
      // to show a spinner. We don't change the state data here.
      state = state; // This will trigger a rebuild for listeners of the notifier
    }

    try {
      final newPokemons = await PokeApi.fetchAllPokemons(limit: _pageSize, offset: _offset);

      if (newPokemons.length < _pageSize) {
        _hasMore = false;
      }

      _offset += newPokemons.length;
      _allPokemons.addAll(newPokemons);

      state = AsyncValue.data(List.from(_allPokemons));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isFetching = false;
      // Trigger a final rebuild to hide the loading indicator
      state = state.whenData((value) => List.from(_allPokemons));
    }
  }

  Future<void> refreshPokemons() async {
    _hasMore = true;
    await fetchPokemons(isRefresh: true);
  }
}