import 'package:flutter/material.dart';
import '../services/favorite_services.dart';
import '../models/recipe.dart';
import 'home.dart';
import 'recipe_details.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}
class _FavoritePageState extends State<FavoritePage> {
  final FavoriteService _favoriteService = FavoriteService();
  List<Recipe> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoriteService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Favorites', style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => RecipeHomePage(),
              ),); // Navigates back to the previous screen
          },
        ),
      ),
      body: _favorites.isEmpty
          ? const Center(child: Text('No favorite recipes yet!'))
          : ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final recipe = _favorites[index];
          return ListTile(
            title: Text(recipe.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailPage(recipe: recipe),
                ),
              ).then((_) => _loadFavorites()); // Reload favorites on return
            },
          );
        },
      ),
    );
  }
}
