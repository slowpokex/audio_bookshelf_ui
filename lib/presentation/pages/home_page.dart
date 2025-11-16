import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/audiobook.dart';
import '../blocs/audiobook/audiobook_bloc.dart';
import '../widgets/loading/simple_loading_widget.dart';
import '../widgets/common/app_icon.dart';
import '../widgets/audio_player/audio_player_mini.dart';
import '../widgets/audiobook/audiobook_card.dart';
import '../widgets/audiobook/audiobook_empty_state.dart';

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
  
  // View mode: 'grid' or 'list'
  bool _isGridView = false;
  
  // Filter mode: 'all', 'continue', 'recent', 'favorites', 'completed'
  String _filterMode = 'all';
  
  // Debounce timer for search
  Timer? _searchDebounceTimer;
  
  // Scroll controller for sections
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure the widget is fully built before loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAudiobooks();
    });
    
    // Listen to search input changes with debouncing
    _searchController.addListener(() {
      _debounceSearch();
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadAudiobooks() {
    if (!mounted) return;
    
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
  
  void _debounceSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadAudiobooks();
      }
    });
  }

  void _onSearchChanged(String query) {
    // Search is now debounced via the listener
    // This method is kept for compatibility with search delegate
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
          // View mode toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.view_module),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick filter buttons
          _buildQuickFilters(context),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: StatefulBuilder(
              builder: (context, setState) {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide clear button
                    _onSearchChanged(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search audiobooks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {}); // Rebuild to hide clear button
                              _loadAudiobooks();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                );
              },
            ),
          ),
          
          // Filter chips
          if (_hasActiveFilters())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
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
          
          // Content
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
                  return _buildContent(context, state.audiobooks);
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


  void _navigateToAddAudiobook() {
    context.go('/add-audiobook');
  }

  /// Check if there are active filters
  bool _hasActiveFilters() {
    return _selectedGenre.isNotEmpty ||
        _selectedAuthor.isNotEmpty ||
        _selectedNarrator.isNotEmpty ||
        _showCompleted ||
        _showFavorites;
  }

  /// Build quick filter buttons
  Widget _buildQuickFilters(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _buildFilterChip(
            context,
            label: 'All',
            icon: Icons.library_books,
            isSelected: _filterMode == 'all',
            onTap: () => _setFilterMode('all'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Continue',
            icon: Icons.play_circle_outline,
            isSelected: _filterMode == 'continue',
            onTap: () => _setFilterMode('continue'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Recent',
            icon: Icons.history,
            isSelected: _filterMode == 'recent',
            onTap: () => _setFilterMode('recent'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Favorites',
            icon: Icons.favorite,
            isSelected: _filterMode == 'favorites',
            onTap: () => _setFilterMode('favorites'),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Completed',
            icon: Icons.check_circle,
            isSelected: _filterMode == 'completed',
            onTap: () => _setFilterMode('completed'),
          ),
        ],
      ),
    );
  }

  /// Build filter chip button
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
      ),
    );
  }

  /// Set filter mode
  void _setFilterMode(String mode) {
    setState(() {
      _filterMode = mode;
      switch (mode) {
        case 'continue':
          _showCompleted = false;
          _showFavorites = false;
          break;
        case 'favorites':
          _showFavorites = true;
          _showCompleted = false;
          break;
        case 'completed':
          _showCompleted = true;
          _showFavorites = false;
          break;
        case 'recent':
          _sortBy = 'last_played_at';
          _sortOrder = 'desc';
          _showCompleted = false;
          _showFavorites = false;
          break;
        case 'all':
        default:
          _showCompleted = false;
          _showFavorites = false;
          break;
      }
    });
    _loadAudiobooks();
  }

  /// Build content based on filter mode
  Widget _buildContent(BuildContext context, List<Audiobook> audiobooks) {
    // Filter and sort audiobooks based on mode
    List<Audiobook> filteredBooks = _filterAudiobooks(audiobooks);

    if (filteredBooks.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AudiobookEmptyState(
            message: _getEmptyMessage(),
            actionLabel: 'Add Audiobook',
            onAction: _navigateToAddAudiobook,
          ),
        ),
      );
    }

    // Group books for sections
    if (_filterMode == 'all' && !_hasActiveFilters()) {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: _buildSectionsView(context, audiobooks),
      );
    } else {
      return RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        child: _buildBooksList(context, filteredBooks),
      );
    }
  }

  /// Build sections view (Continue Reading, Recently Played, etc.)
  Widget _buildSectionsView(BuildContext context, List<Audiobook> audiobooks) {
    final continueReading = audiobooks
        .where((book) => book.isStarted && !book.isCompleted)
        .toList()
      ..sort((a, b) {
        final aTime = a.lastPlayedAt ?? DateTime(2000);
        final bTime = b.lastPlayedAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

    final recentlyPlayed = audiobooks
        .where((book) => book.lastPlayedAt != null)
        .toList()
      ..sort((a, b) {
        final aTime = a.lastPlayedAt ?? DateTime(2000);
        final bTime = b.lastPlayedAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

    final favorites = audiobooks.where((book) => book.isFavorite).toList();

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: [
        if (continueReading.isNotEmpty)
          _buildSection(
            context,
            title: 'Continue Reading',
            subtitle: 'Pick up where you left off',
            icon: Icons.play_circle_outline,
            audiobooks: continueReading.take(10).toList(),
          ),
        if (recentlyPlayed.isNotEmpty && continueReading.length < 10)
          _buildSection(
            context,
            title: 'Recently Played',
            subtitle: 'Your listening history',
            icon: Icons.history,
            audiobooks: recentlyPlayed.take(10).toList(),
          ),
        if (favorites.isNotEmpty)
          _buildSection(
            context,
            title: 'Favorites',
            subtitle: 'Your favorite audiobooks',
            icon: Icons.favorite,
            audiobooks: favorites,
          ),
        _buildSection(
          context,
          title: 'All Audiobooks',
          subtitle: 'Your complete library',
          icon: Icons.library_books,
          audiobooks: audiobooks,
        ),
      ],
    );
  }

  /// Build section widget
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Audiobook> audiobooks,
  }) {
    if (audiobooks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: _isGridView ? null : 200,
          child: _isGridView
              ? _buildGridView(context, audiobooks)
              : _buildHorizontalList(context, audiobooks),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build horizontal list for sections
  Widget _buildHorizontalList(BuildContext context, List<Audiobook> audiobooks) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        return SizedBox(
          width: 160,
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: AudiobookCard(
              audiobook: audiobooks[index],
              isGridView: true,
            ),
          ),
        );
      },
    );
  }

  /// Build books list
  Widget _buildBooksList(BuildContext context, List<Audiobook> audiobooks) {
    if (_isGridView) {
      return _buildGridView(context, audiobooks);
    } else {
      return _buildListView(context, audiobooks);
    }
  }

  /// Build grid view
  Widget _buildGridView(BuildContext context, List<Audiobook> audiobooks) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        return AudiobookCard(
          audiobook: audiobooks[index],
          isGridView: true,
        );
      },
    );
  }

  /// Build list view
  Widget _buildListView(BuildContext context, List<Audiobook> audiobooks) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: audiobooks.length,
      itemBuilder: (context, index) {
        return AudiobookCard(
          audiobook: audiobooks[index],
          isGridView: false,
        );
      },
    );
  }

  /// Filter audiobooks based on current filters
  List<Audiobook> _filterAudiobooks(List<Audiobook> audiobooks) {
    List<Audiobook> filtered = List.from(audiobooks);

    // Apply filter mode
    switch (_filterMode) {
      case 'continue':
        filtered = filtered.where((book) => book.isStarted && !book.isCompleted).toList();
        filtered.sort((a, b) {
          final aTime = a.lastPlayedAt ?? DateTime(2000);
          final bTime = b.lastPlayedAt ?? DateTime(2000);
          return bTime.compareTo(aTime);
        });
        break;
      case 'favorites':
        filtered = filtered.where((book) => book.isFavorite).toList();
        break;
      case 'completed':
        filtered = filtered.where((book) => book.isCompleted).toList();
        break;
      case 'recent':
        filtered = filtered.where((book) => book.lastPlayedAt != null).toList();
        filtered.sort((a, b) {
          final aTime = a.lastPlayedAt ?? DateTime(2000);
          final bTime = b.lastPlayedAt ?? DateTime(2000);
          return bTime.compareTo(aTime);
        });
        break;
    }

    // Apply additional filters
    if (_selectedGenre.isNotEmpty) {
      filtered = filtered.where((book) => book.genre == _selectedGenre).toList();
    }
    if (_selectedAuthor.isNotEmpty) {
      filtered = filtered.where((book) => book.author == _selectedAuthor).toList();
    }
    if (_selectedNarrator.isNotEmpty) {
      filtered = filtered.where((book) => book.narrator == _selectedNarrator).toList();
    }
    if (_showCompleted && _filterMode != 'completed') {
      filtered = filtered.where((book) => book.isCompleted).toList();
    }
    if (_showFavorites && _filterMode != 'favorites') {
      filtered = filtered.where((book) => book.isFavorite).toList();
    }

    return filtered;
  }

  /// Get empty message based on filter
  String _getEmptyMessage() {
    switch (_filterMode) {
      case 'continue':
        return 'No books in progress';
      case 'favorites':
        return 'No favorite audiobooks';
      case 'completed':
        return 'No completed audiobooks';
      case 'recent':
        return 'No recently played audiobooks';
      default:
        return 'No audiobooks found';
    }
  }
}
