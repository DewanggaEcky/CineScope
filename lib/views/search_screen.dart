import 'package:flutter/material.dart';
import 'package:project_movie/views/movie_detail_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/search_view_model.dart';
import '../viewmodels/home_view_model.dart';
import 'widget/movie_card_widget.dart';
import 'favourite_screen.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<SearchViewModel>(context, listen: false);
      _searchController.text = viewModel.searchQuery;
      viewModel.fetchMasterList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search movies...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                viewModel.updateSearchQuery(query);
              },
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildGenreFilters(context, viewModel),
              const SizedBox(height: 20),
              Expanded(
                child: _buildBodyContent(context, viewModel),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        );
      },
    );
  }

  Widget _buildBodyContent(BuildContext context, SearchViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.isInitialLoadDone) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    if (viewModel.isInitialLoadDone && viewModel.filteredMovies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Text(
            viewModel.searchQuery.isEmpty
                ? 'No movies found for the selected filter.'
                : 'No results found for "${viewModel.searchQuery}".',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: viewModel.filteredMovies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final movie = viewModel.filteredMovies[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              MovieDetailScreen.routeName,
              arguments: movie.id,
            );
          },
          child: MovieCardWidget(movie: movie, isLargeCard: false),
        );
      },
    );
  }

  Widget _buildGenreFilters(BuildContext context, SearchViewModel viewModel) {
    final List<String> genres = viewModel.availableGenres;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == viewModel.selectedGenre;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ActionChip(
              label: Text(
                genre,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected ? Colors.red : Colors.grey.shade900,
              onPressed: () {
                viewModel.updateSelectedGenre(genre);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: isSelected
                  ? const BorderSide(color: Colors.red, width: 1)
                  : const BorderSide(color: Colors.grey, width: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white54,
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favourite',
        ),
      ],
      onTap: (index) {
        final homeViewModel = Provider.of<HomeViewModel>(
          context,
          listen: false,
        );
        final viewModel = Provider.of<SearchViewModel>(context, listen: false);
        if (index == 0) {
          viewModel.resetSearch();
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          // SEARCH
        } else if (index == 2) {
          viewModel.resetSearch();
          homeViewModel.resetHomeFilter();
          Navigator.pushReplacementNamed(context, FavouriteScreen.routeName);
        }
      },
    );
  }
}
