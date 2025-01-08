import '../models/recipe.dart';
import 'recipe_service.dart';

class RecipeSearchService {
  final RecipeService _recipeService;

  RecipeSearchService(this._recipeService);

  // Search recipes by ingredients
  Future<List<Recipe>> searchRecipes(String ingredients) async {
    if (ingredients.isEmpty) {
      throw Exception('Please enter at least one ingredient');
    }

    try {
      final recipes = await _recipeService.getRecipes(ingredients);
      return recipes;
    } catch (error) {
      throw Exception('Error fetching recipes: $error');
    }
  }

  // New: Search recipes by recipe name
  Future<List<Recipe>> searchRecipesByName(String recipeName) async {
    if (recipeName.isEmpty) {
      throw Exception('Please enter a recipe name');
    }

    try {
      final recipes = await _recipeService.searchRecipesByName(recipeName);
      return recipes;
    } catch (error) {
      throw Exception('Error fetching recipes by name: $error');
    }
  }
}
