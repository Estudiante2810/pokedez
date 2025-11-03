import 'package:flutter/material.dart';

import '../models/pokemon_detail.dart';
import '../models/pokemon_list_item.dart';
import '../services/poke_api.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int id;
  final String name;

  const PokemonDetailScreen({super.key, required this.id, required this.name});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  PokemonDetail? _detail;
  List<PokemonListItem> _evolutions = [];
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
      appBar: AppBar(
        title: Text(_capitalize(widget.name)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_detail!.spriteUrl.isNotEmpty)
                            Center(child: Image.network(_detail!.spriteUrl, height: 220, fit: BoxFit.contain)),
                          const SizedBox(height: 12),
                          Center(child: Text('#${_detail!.id}  ${_capitalize(_detail!.name)}', style: Theme.of(context).textTheme.headlineSmall)),
                          const SizedBox(height: 8),

                          // types
                          Center(child: Wrap(spacing: 8, children: _detail!.types.map((t) => Chip(label: Text(_capitalize(t)))).toList())),
                          const SizedBox(height: 16),

                          // basic info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(children: [Text('Height'), const SizedBox(height: 4), Text('${_detail!.height / 10} m')]),
                              Column(children: [Text('Weight'), const SizedBox(height: 4), Text('${_detail!.weight / 10} kg')]),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // stats
                          Text('Stats', style: Theme.of(context).textTheme.titleMedium),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [Text(_capitalize(e.key)), Text(value.toString())],
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(value: pct, minHeight: 8),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),

                          // abilities
                          Text('Abilities', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, children: _detail!.abilities.map((a) => Chip(label: Text(_capitalize(a)))).toList()),
                          const SizedBox(height: 12),

                          // evolutions
                          Text('Evolutions', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (_evolutions.isEmpty)
                            const Text('No evolutions found')
                          else
                            SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _evolutions.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final ev = _evolutions[i];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (_) => PokemonDetailScreen(id: ev.id, name: ev.name),
                                      ));
                                    },
                                    child: Column(
                                      children: [
                                        Image.network(ev.imageUrl, width: 80, height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                                        const SizedBox(height: 6),
                                        Text(_capitalize(ev.name)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 12),

                          // moves (first 10)
                          Text('Moves', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          if (_detail!.moves.isEmpty)
                            const Text('No moves available')
                          else
                            Wrap(spacing: 6, runSpacing: 6, children: _detail!.moves.take(10).map((m) => InputChip(label: Text(m))).toList()),
                        ],
                      ),
                    ),
    );
  }
}
