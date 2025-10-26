import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/audiobook/audiobook_bloc.dart';
import '../blocs/audio_player/audio_player_bloc.dart';
import '../blocs/audio_player/audio_player_event.dart';
import '../widgets/loading/simple_loading_widget.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/audio_player/audio_player_mini.dart';

/// Home page displaying the audiobook library
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = '';
  String _selectedAuthor = '';
  String _selectedNarrator = '';
  bool _showCompleted = false;
  bool _showFavorites = false;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget is fully built before loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAudiobooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAudiobooks() {
    context.read<AudiobookBloc>().add(
      LoadAudiobooksEvent(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        genre: _selectedGenre.isEmpty ? null : _selectedGenre,
        author: _selectedAuthor.isEmpty ? null : _selectedAuthor,
        narrator: _selectedNarrator.isEmpty ? null : _selectedNarrator,
        isCompleted: _showCompleted,
        isFavorite: _showFavorites,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      ),
    );
  }

  void _onSearchChanged(String query) {
    _loadAudiobooks();
  }

  void _onGenreChanged(String genre) {
    setState(() {
      _selectedGenre = genre;
    });
    _loadAudiobooks();
  }

  void _onAuthorChanged(String author) {
    setState(() {
      _selectedAuthor = author;
    });
    _loadAudiobooks();
  }

  void _onNarratorChanged(String narrator) {
    setState(() {
      _selectedNarrator = narrator;
    });
    _loadAudiobooks();
  }

  void _onCompletedChanged(bool value) {
    setState(() {
      _showCompleted = value;
    });
    _loadAudiobooks();
  }

  void _onFavoritesChanged(bool value) {
    setState(() {
      _showFavorites = value;
    });
    _loadAudiobooks();
  }

  void _onSortChanged(String sortBy, String sortOrder) {
    setState(() {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
    });
    _loadAudiobooks();
  }

  void _onRefresh() {
    _loadAudiobooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: AppBarIcon(),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Audio Bookshelf',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AudiobookSearchDelegate(
                  onSearch: _onSearchChanged,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search audiobooks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                if (_selectedGenre.isNotEmpty)
                  Chip(
                    label: Text(_selectedGenre),
                    onDeleted: () => _onGenreChanged(''),
                  ),
                if (_selectedAuthor.isNotEmpty)
                  Chip(
                    label: Text(_selectedAuthor),
                    onDeleted: () => _onAuthorChanged(''),
                  ),
                if (_selectedNarrator.isNotEmpty)
                  Chip(
                    label: Text(_selectedNarrator),
                    onDeleted: () => _onNarratorChanged(''),
                  ),
                if (_showCompleted)
                  Chip(
                    label: const Text('Completed'),
                    onDeleted: () => _onCompletedChanged(false),
                  ),
                if (_showFavorites)
                  Chip(
                    label: const Text('Favorites'),
                    onDeleted: () => _onFavoritesChanged(false),
                  ),
              ],
            ),
          ),
          
          // Audiobook list
          Expanded(
            child: BlocBuilder<AudiobookBloc, AudiobookState>(
              builder: (context, state) {
                if (state is AudiobookLoadingState) {
                  return const SimpleLoadingWidget(
                    message: 'Loading your audiobook library...',
                    showLogo: true,
                  );
                } else if (state is AudiobookErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is AudiobookLoadedState) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      _onRefresh();
                    },
                    child: ListView.builder(
                      itemCount: state.audiobooks.length,
                      itemBuilder: (context, index) {
                        final audiobook = state.audiobooks[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(audiobook.title[0].toUpperCase()),
                          ),
                          title: Text(audiobook.title),
                          subtitle: Text(audiobook.author),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Play button
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  context.read<AudioPlayerBloc>().add(
                                    PlayAudiobookEvent(audiobook),
                                  );
                                },
                                tooltip: 'Play',
                              ),
                              IconButton(
                                icon: Icon(
                                  audiobook.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: audiobook.isFavorite ? Colors.red : null,
                                ),
                                onPressed: () {
                                  context.read<AudiobookBloc>().add(
                                    ToggleFavoriteEvent(audiobook.id),
                                  );
                                },
                                tooltip: 'Toggle Favorite',
                              ),
                              IconButton(
                                icon: const Icon(Icons.star_border),
                                onPressed: () {
                                  // TODO: Implement rating dialog
                                },
                                tooltip: 'Rate',
                              ),
                            ],
                          ),
                          onTap: () {
                            _navigateToAudiobookDetail(audiobook.id);
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddAudiobook();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AudioPlayerMini(),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Audiobooks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Completed'),
              value: _showCompleted,
              onChanged: (value) {
                setState(() {
                  _showCompleted = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Show Favorites Only'),
              value: _showFavorites,
              onChanged: (value) {
                setState(() {
                  _showFavorites = value ?? false;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showCompleted = false;
                _showFavorites = false;
                _selectedGenre = '';
                _selectedAuthor = '';
                _selectedNarrator = '';
              });
              _loadAudiobooks();
              Navigator.of(context).pop();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () {
              _loadAudiobooks();
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Audiobooks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Title'),
              value: 'title',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Author'),
              value: 'author',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Rating'),
              value: 'rating',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Duration'),
              value: 'duration',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Date Added'),
              value: 'created_at',
              groupValue: _sortBy,
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
              },
            ),
            const Divider(),
            RadioListTile<String>(
              title: const Text('Ascending'),
              value: 'asc',
              groupValue: _sortOrder,
              onChanged: (value) {
                setState(() {
                  _sortOrder = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Descending'),
              value: 'desc',
              groupValue: _sortOrder,
              onChanged: (value) {
                setState(() {
                  _sortOrder = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _onSortChanged(_sortBy, _sortOrder);
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _navigateToAudiobookDetail(String audiobookId) {
    context.go('/audiobook-detail', extra: audiobookId);
  }

  void _navigateToAddAudiobook() {
    context.go('/add-audiobook');
  }
}

/// Search delegate for audiobook search
class AudiobookSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  AudiobookSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}
