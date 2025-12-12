import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/movie.dart';
import '../viewmodels/favourite_view_model.dart';
import '../viewmodels/movie_detail_view_model.dart';
import 'widget/movie_card_widget.dart';

class MovieDetailScreen extends StatefulWidget {
  static const routeName = '/movie-detail';
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieId = ModalRoute.of(context)?.settings.arguments as String?;
      if (movieId != null) {
        Provider.of<MovieDetailViewModel>(
          context,
          listen: false,
        ).fetchMovieDetail(movieId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double collapsedToolbarHeight = kToolbarHeight + statusBarHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<MovieDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }
          if (viewModel.movie == null) {
            return const Center(
              child: Text(
                'Movie not found or failed to load data.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = viewModel.movie!;
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 350.0,
                backgroundColor: Colors.black,
                pinned: true,
                floating: false,
                snap: false,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          var settings = context
                              .dependOnInheritedWidgetOfExactType<
                                FlexibleSpaceBarSettings
                              >();
                          if (settings == null) return const SizedBox.shrink();
                          double deltaExtent =
                              settings.maxExtent - settings.minExtent;
                          double t = (deltaExtent == 0)
                              ? 0
                              : (1.0 -
                                        (settings.currentExtent -
                                                settings.minExtent) /
                                            deltaExtent)
                                    .clamp(0.0, 1.0);
                          bool isCollapsed = t > 0.8;

                          return CircleAvatar(
                            backgroundColor: isCollapsed
                                ? Colors.transparent
                                : Colors.black.withOpacity(0.5),
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                  ),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeaderImageWithGradient(context, movie),
                  title: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          var top = constraints.biggest.height;
                          bool isCollapsed = top <= collapsedToolbarHeight + 1;

                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 100),
                            opacity: isCollapsed ? 1.0 : 0.0,
                            child: Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                  ),
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 56.0,
                    bottom: 16.0,
                    end: 16.0,
                  ),
                  collapseMode: CollapseMode.parallax,
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(context, movie),
                      _buildSynopsis(context, movie),
                      _buildSimilarMovies(context, viewModel),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderImageWithGradient(BuildContext context, Movie movie) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          movie.posterUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            );
          },
          errorBuilder: (ctx, err, stack) => Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.movie, color: Colors.white54, size: 50),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87, Colors.black],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Movie movie) {
    void launchTrailer() async {
      final movie = Provider.of<MovieDetailViewModel>(
        context,
        listen: false,
      ).movie;
      if (movie == null || movie.trailerKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trailer not found for this movie.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final url = Uri.parse(
        'https://www.youtube.com/watch?v=${movie.trailerKey}',
      );

      try {
        bool launched = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          launched = await launchUrl(url, mode: LaunchMode.platformDefault);
        }

        if (!launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open trailer URL.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    final bool isTrailerAvailable = movie.trailerKey != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
              const SizedBox(width: 5),
              Text(
                movie.releaseDate.length >= 4
                    ? movie.releaseDate.substring(0, 4)
                    : 'N/A',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, color: Colors.white70, size: 14),
              const SizedBox(width: 5),
              Text(
                movie.duration ?? 'N/A',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isTrailerAvailable
                      ? launchTrailer
                      : null,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: Text(
                    isTrailerAvailable ? 'Play Trailer' : 'Trailer Not Found',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(color: Colors.red),
                    ),
                    disabledBackgroundColor: Colors.grey.shade700,
                    disabledForegroundColor: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Consumer<FavouriteViewModel>(
                builder: (context, favViewModel, child) {
                  bool isFav = favViewModel.isFavourite(movie.id);

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isFav ? Colors.red : Colors.white54,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        favViewModel.toggleFavourite(movie);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSynopsis(BuildContext context, Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Synopsis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            movie.summary ?? 'Synopsis not available.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Genre',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            movie.genre.join(', '),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Text(
            'Director',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            movie.director ?? 'N/A',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            movie.cast?.join(', ') ?? 'N/A',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSimilarMovies(
    BuildContext context,
    MovieDetailViewModel viewModel,
  ) {
    if (viewModel.similarMovies.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            'Similar Movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: viewModel.similarMovies.length,
            itemBuilder: (context, index) {
              final movie = viewModel.similarMovies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      MovieDetailScreen.routeName,
                      arguments: movie.id,
                    );
                  },
                  child: MovieCardWidget(movie: movie, isLargeCard: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
