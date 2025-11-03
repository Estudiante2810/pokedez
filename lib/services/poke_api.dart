import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/pokemon_list_item.dart';
import '../models/pokemon_detail.dart';

class PokeApi {
  static const _base = 'https://pokeapi.co/api/v2';

  /// Fetch the full list of pokemons (name + url). This uses a large limit
  /// to get all entries. The result is cached by the caller if needed.
  static Future<List<PokemonListItem>> fetchAllPokemons() async {
    final uri = Uri.parse('$_base/pokemon?limit=100000&offset=0');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error fetching pokemon list: ${res.statusCode}');
    }
    final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results.map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch detailed info for a single pokemon by id.
  static Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final uri = Uri.parse('$_base/pokemon/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error fetching pokemon detail: ${res.statusCode}');
    }
    final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
    return PokemonDetail.fromJson(data);
  }

  /// Fetch the evolution chain for a pokemon by its id. Returns a list of
  /// PokemonListItem representing each species in the chain (in order).
  static Future<List<PokemonListItem>> fetchEvolutionChain(int pokemonId) async {
    // First fetch species info to get evolution_chain.url
    final speciesUri = Uri.parse('$_base/pokemon-species/$pokemonId');
    final speciesRes = await http.get(speciesUri);
    if (speciesRes.statusCode != 200) {
      throw Exception('Error fetching species info: ${speciesRes.statusCode}');
    }
    final Map<String, dynamic> speciesData = json.decode(speciesRes.body) as Map<String, dynamic>;
    final evo = (speciesData['evolution_chain'] as Map<String, dynamic>?)?['url'] as String?;
    if (evo == null || evo.isEmpty) return [];

    final evoRes = await http.get(Uri.parse(evo));
    if (evoRes.statusCode != 200) {
      throw Exception('Error fetching evolution chain: ${evoRes.statusCode}');
    }
    final Map<String, dynamic> evoData = json.decode(evoRes.body) as Map<String, dynamic>;

    final List<PokemonListItem> result = [];

    void parseNode(Map<String, dynamic> node) {
      final species = node['species'] as Map<String, dynamic>;
      final name = species['name'] as String;
      final url = species['url'] as String;
      result.add(PokemonListItem.fromJson({'name': name, 'url': url}));
      final evolvesTo = node['evolves_to'] as List<dynamic>;
      for (final child in evolvesTo) {
        parseNode(child as Map<String, dynamic>);
      }
    }

    final chain = evoData['chain'] as Map<String, dynamic>;
    parseNode(chain);
    return result;
  }

  /// Return a set of pokemon names that have the given type (e.g. 'fire').
  static Future<Set<String>> fetchPokemonNamesByType(String type) async {
    final uri = Uri.parse('$_base/type/$type');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error fetching type $type: ${res.statusCode}');
    }
    final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
    final List<dynamic> poks = data['pokemon'] as List<dynamic>;
    final names = <String>{};
    for (final p in poks) {
      final m = p as Map<String, dynamic>;
      final pokemon = m['pokemon'] as Map<String, dynamic>;
      final name = pokemon['name'] as String;
      names.add(name);
    }
    return names;
  }

  /// Return a set of pokemon species names that belong to the given generation id (1-based).
  static Future<Set<String>> fetchPokemonNamesByGeneration(int generationId) async {
    final uri = Uri.parse('$_base/generation/$generationId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error fetching generation $generationId: ${res.statusCode}');
    }
    final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
    final List<dynamic> species = data['pokemon_species'] as List<dynamic>;
    final names = <String>{};
    for (final s in species) {
      final m = s as Map<String, dynamic>;
      final name = m['name'] as String;
      names.add(name);
    }
    return names;
  }
}
