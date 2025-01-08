import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/recipe.dart';

class FavoriteService {
  static const _favoritesBox = 'favorite_recipes';

  // Initialize Hive and open the box
  Future<Box> _getFavoritesBox() async {
    if (!Hive.isBoxOpen(_favoritesBox)) {
      return await Hive.openBox(_favoritesBox);
    }
    return Hive.box(_favoritesBox);
  }

  // Save a recipe to favorites
  Future<void> addFavorite(Recipe recipe) async {
    final box = await _getFavoritesBox();
    // Convert the recipe to JSON and save it, using the title as the key
    if (!box.containsKey(recipe.title)) {
      await box.put(recipe.title, jsonEncode(recipe.toJson()));
    }
  }

  // Remove a recipe from favorites
  Future<void> removeFavorite(Recipe recipe) async {
    final box = await _getFavoritesBox();
    // Remove the recipe by its title key
    await box.delete(recipe.title);
  }

  // Get all favorite recipes
  Future<List<Recipe>> getFavorites() async {
    final box = await _getFavoritesBox();
    // Get all values from the box and convert them back to `Recipe` objects
    return box.values
        .map((recipeJson) => Recipe.fromJson(jsonDecode(recipeJson)))
        .toList();
  }

  // Check if a recipe is in favorites
  Future<bool> isFavorite(Recipe recipe) async {
    final box = await _getFavoritesBox();
    // Check if the recipe title exists in the box
    return box.containsKey(recipe.title);
  }
}
