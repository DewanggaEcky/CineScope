import 'package:flutter/material.dart';
import 'package:project_movie/main.dart';
import 'package:provider/provider.dart';
import '../viewmodels/favourite_view_model.dart';
import 'widget/movie_card_widget.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';
import '../viewmodels/search_view_model.dart';
import '../viewmodels/home_view_model.dart';

class FavouriteScreen extends StatefulWidget {
  static const routeName = '/favourite';
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavouriteViewModel>(context, listen: false).loadFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Favourites', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading:
            false,
      ),
      body: Consumer<FavouriteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (viewModel.favouriteMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade900,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Favourite Movies Yet',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  )
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: viewModel.favouriteMovies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemBuilder: (context, index) {
              final movie = viewModel.favouriteMovies[index];
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
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final searchViewModel = Provider.of<SearchViewModel>(
      context,
      listen: false,
    );
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);

    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white54,
      currentIndex: 2,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favourite',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          searchViewModel.resetSearch();
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          homeViewModel.resetHomeFilter();
          Navigator.pushReplacementNamed(context, SearchScreen.routeName);
        } else if (index == 2) {
          //Favourite
        }
      },
    );
  }
}
