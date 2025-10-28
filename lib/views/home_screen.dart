import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_view_model.dart';
import '../viewmodels/search_view_model.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';
import 'widget/movie_card_widget.dart';

import 'login_screen.dart';
import 'search_screen.dart';
import 'favourite_screen.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).loadHomePageData();
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'CineScope',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          FutureBuilder<Map<String, String>>(
            future: AuthService().getUserData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.person, color: Colors.white),
                );
              }

              final userData = snapshot.data!;
              final userName = userData['name'];
              final userEmail = userData['email'];
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  final navigator = Navigator.of(context);
                  if (value == 'logout') {
                    await AuthService().clearUserData();
                    navigator.pushNamedAndRemoveUntil(
                      LoginScreen.routeName,
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                color: Colors.grey.shade900,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      userName ?? "CineScope User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      userEmail ?? "user@example.com",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const PopupMenuDivider(height: 10),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 10),
                        Text('Logout', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
          if (viewModel.nowShowing.isEmpty &&
              viewModel.trending.isEmpty &&
              viewModel.topRated.isEmpty) {
            return const Center(
              child: Text(
                'No movies found for the selected filter.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildSearchBar(context),
                const SizedBox(height: 20),
                _buildGenreFilters(context, viewModel),
                const SizedBox(height: 20),
                _buildMovieSection(
                  title: 'Now Showing',
                  movies: viewModel.nowShowing,
                  isLargeCard: true,
                ),
                _buildMovieSection(
                  title: 'Trending',
                  movies: viewModel.trending,
                  isLargeCard: false,
                ),
                _buildMovieSection(
                  title: 'Top Rated',
                  movies: viewModel.topRated,
                  isLargeCard: false,
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, SearchScreen.routeName);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70),
              const SizedBox(width: 10),
              Text(
                'Search movies...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreFilters(BuildContext context, HomeViewModel viewModel) {
    final List<String> genres = [
      'All',
      'Action',
      'Drama',
      'Comedy',
      'Sci-Fi',
      'Animation',
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected =
              genre ==
              viewModel.selectedGenre;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ActionChip(
              label: Text(
                genre,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white70,
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
              side: BorderSide(
                color: isSelected
                    ? Colors.red
                    : Colors.grey.shade700,
                width: 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieSection({
    required String title,
    required List<Movie> movies,
    required bool isLargeCard,
  }) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: isLargeCard
              ? 300
              : 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      MovieDetailScreen.routeName,
                      arguments: movie.id,
                    );
                  },
                  child: MovieCardWidget(
                    movie: movie,
                    isLargeCard: isLargeCard,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );
    final homeViewModel = Provider.of<HomeViewModel>(
      context,
      listen: false,
    );

    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white54,
      currentIndex: 0,
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
        if (index == 0) {
        } else if (index == 1) {
          homeViewModel.resetHomeFilter();
          Navigator.pushReplacementNamed(context, SearchScreen.routeName);
        } else if (index == 2) {
          searchViewModel.resetSearch();
          homeViewModel.resetHomeFilter();
          Navigator.pushReplacementNamed(context, FavouriteScreen.routeName);
        }
      },
    );
  }
}
