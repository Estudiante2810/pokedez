import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/pokemon_list_item.dart';
import '../models/pokemon_detail.dart';

class PokeApi {
  static const _graphqlEndpoint = 'https://beta.pokeapi.co/graphql/v1beta';
  static late GraphQLClient _client;

  /// Initialize the GraphQL client (call this once on app startup)
  static void initGraphQL() {
    final HttpLink httpLink = HttpLink(_graphqlEndpoint);
    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }

  /// Fetch the full list of pokemons using GraphQL with offset/limit pagination
  static Future<List<PokemonListItem>> fetchAllPokemons() async {
    const query = '''
      query GetPokemons(\$limit: Int!, \$offset: Int!) {
        pokemon_v2_pokemonspecies(limit: \$limit, offset: \$offset, order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemons {
            id
            name
          }
        }
      }
    ''';

    final List<PokemonListItem> allPokemons = [];
    int offset = 0;
    const pageSize = 50;
    bool hasMore = true;

    while (hasMore) {
      try {
        final result = await _client.query(
          QueryOptions(
            document: gql(query),
            variables: {
              'limit': pageSize,
              'offset': offset,
            },
          ),
        );

        if (result.hasException) {
          throw Exception('Error fetching pokemon list: ${result.exception}');
        }

        final species = result.data?['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [];
        
        if (species.isEmpty) {
          hasMore = false;
          break;
        }

        for (final s in species) {
          final speciesData = s as Map<String, dynamic>;
          final id = speciesData['id'] as int;
          final pokemons = speciesData['pokemon_v2_pokemons'] as List<dynamic>? ?? [];

          if (pokemons.isNotEmpty) {
            final pokemon = pokemons[0] as Map<String, dynamic>;
            final pokemonName = pokemon['name'] as String;
            allPokemons.add(
              PokemonListItem(
                name: pokemonName,
                id: id,
                imageUrl:
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/$id.png',
              ),
            );
          }
        }

        offset += pageSize;
        if (species.length < pageSize) {
          hasMore = false;
        }
      } catch (e) {
        throw Exception('Error fetching pokemon list: $e');
      }
    }

    return allPokemons;
  }

  /// Fetch detailed info for a single pokemon by id using GraphQL
  static Future<PokemonDetail> fetchPokemonDetail(int id) async {
    const query = '''
      query GetPokemonDetail(\$id: Int!) {
        pokemon_v2_pokemon(where: {id: {_eq: \$id}}) {
          id
          name
          height
          weight
          pokemon_v2_pokemonsprites {
            sprites
          }
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
          pokemon_v2_pokemonstats {
            pokemon_v2_stat {
              name
            }
            base_stat
          }
          pokemon_v2_pokemonabilities {
            pokemon_v2_ability {
              name
            }
            is_hidden
          }
          pokemon_v2_pokemonmoves {
            pokemon_v2_move {
              name
            }
          }
          pokemon_v2_pokemonspecy {
            name
          }
        }
      }
    ''';

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        throw Exception('Error fetching pokemon detail: ${result.exception}');
      }

      final pokemons = result.data?['pokemon_v2_pokemon'] as List<dynamic>?;
      if (pokemons == null || pokemons.isEmpty) {
        throw Exception('Pokemon not found');
      }

      final pokemon = pokemons[0] as Map<String, dynamic>;
      return PokemonDetail.fromGraphQL(pokemon);
    } catch (e) {
      throw Exception('Error fetching pokemon detail: $e');
    }
  }

  /// Fetch the evolution chain using GraphQL
  static Future<List<PokemonListItem>> fetchEvolutionChain(int pokemonId) async {
    const query = '''
      query GetEvolutionChain(\$pokemonId: Int!) {
        pokemon_v2_pokemonspecies(where: {id: {_eq: \$pokemonId}}) {
          pokemon_v2_evolutionchain {
            pokemon_v2_pokemonspecies(order_by: {id: asc}) {
              id
              name
            }
          }
        }
      }
    ''';

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {'pokemonId': pokemonId},
        ),
      );

      if (result.hasException) {
        throw Exception('Error fetching evolution chain: ${result.exception}');
      }

      final species = result.data?['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [];
      if (species.isEmpty) return [];

      final evolutionChain = (species[0] as Map<String, dynamic>)['pokemon_v2_evolutionchain'] 
          as Map<String, dynamic>?;
      
      if (evolutionChain == null) return [];

      final allSpecies = evolutionChain['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [];
      
      return allSpecies.map((s) {
        final speciesData = s as Map<String, dynamic>;
        return PokemonListItem.fromGraphQL(speciesData);
      }).toList();
    } catch (e) {
      // Error fetching evolution chain - returning empty list
      return [];
    }
  }

  /// Fetch pokemon names by type using GraphQL
  static Future<Set<String>> fetchPokemonNamesByType(String type) async {
    const query = '''
      query GetPokemonByType(\$typeName: String!) {
        pokemon_v2_type(where: {name: {_eq: \$typeName}}) {
          pokemon_v2_pokemontypes {
            pokemon_v2_pokemon {
              name
            }
          }
        }
      }
    ''';

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {'typeName': type},
        ),
      );

      if (result.hasException) {
        throw Exception('Error fetching type $type: ${result.exception}');
      }

      final types = result.data?['pokemon_v2_type'] as List<dynamic>? ?? [];
      final names = <String>{};

      for (final typeData in types) {
        final pokemonTypes =
            typeData['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [];
        for (final pt in pokemonTypes) {
          final pokemon = pt['pokemon_v2_pokemon'] as Map<String, dynamic>?;
          if (pokemon != null) {
            final name = pokemon['name'] as String?;
            if (name != null) names.add(name);
          }
        }
      }

      return names;
    } catch (e) {
      throw Exception('Error fetching type $type: $e');
    }
  }

  /// Fetch pokemon names by generation using GraphQL
  static Future<Set<String>> fetchPokemonNamesByGeneration(int generationId) async {
    const query = '''
      query GetPokemonByGeneration(\$genId: Int!) {
        pokemon_v2_generation(where: {id: {_eq: \$genId}}) {
          pokemon_v2_pokemonspecies {
            name
          }
        }
      }
    ''';

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {'genId': generationId},
        ),
      );

      if (result.hasException) {
        throw Exception('Error fetching generation $generationId: ${result.exception}');
      }

      final generations = result.data?['pokemon_v2_generation'] as List<dynamic>? ?? [];
      final names = <String>{};

      for (final gen in generations) {
        final species = gen['pokemon_v2_pokemonspecies'] as List<dynamic>? ?? [];
        for (final s in species) {
          final name = s['name'] as String?;
          if (name != null) names.add(name);
        }
      }

      return names;
    } catch (e) {
      throw Exception('Error fetching generation $generationId: $e');
    }
  }

  /// Fetch pokemon types by id using GraphQL
  static Future<List<String>> fetchPokemonTypes(int id) async {
    const query = '''
      query GetPokemonTypes(\$id: Int!) {
        pokemon_v2_pokemon(where: {id: {_eq: \$id}}) {
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
    ''';

    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        throw Exception('Error fetching pokemon types: ${result.exception}');
      }

      final pokemons = result.data?['pokemon_v2_pokemon'] as List<dynamic>? ?? [];
      if (pokemons.isEmpty) return [];

      final pokemon = pokemons[0] as Map<String, dynamic>;
      final types = pokemon['pokemon_v2_pokemontypes'] as List<dynamic>? ?? [];

      return types
          .map((t) =>
              (t as Map<String, dynamic>)['pokemon_v2_type']['name'] as String)
          .toList();
    } catch (e) {
      throw Exception('Error fetching pokemon types: $e');
    }
  }
}
