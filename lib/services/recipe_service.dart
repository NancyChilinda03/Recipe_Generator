import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeService {
  final String _apiKey = '9ac2fe88293041e69bb4536b1dc70bc1';

  // Fetching recipes based on ingredients
  Future<List<Recipe>> getRecipes(String ingredients) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredients&number=10&apiKey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Recipe> recipes = [];

      // Fetching each recipe's details
      for (var item in data) {
        final recipeId = item['id'];
        final recipeDetails = await getRecipeDetails(recipeId);
        recipes.add(recipeDetails);
      }
      return recipes;
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Method to fetch recipe details based on recipe ID
  Future<Recipe> getRecipeDetails(int id) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/$id/information?apiKey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Recipe(
        title: data['title'] ?? 'No Title',
        imageUrl: data['image'] ?? '',
        ingredients: data['extendedIngredients'] != null
            ? List<String>.from(data['extendedIngredients']
            .map((ingredient) => ingredient['original'] ?? 'Unknown'))
            : [],
        instructions: data['instructions'] ?? 'No instructions available.',
      );
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  // Method to fetch random recipes
  Future<List<Recipe>> getRecipesFromAPI() async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/random?number=10&apiKey=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> recipeList = data['recipes'];

      return recipeList.map<Recipe>((json) {
        return Recipe(
          title: json['title'] ?? 'No Title',
          imageUrl: json['image'] ?? '',
          ingredients: json['extendedIngredients'] != null
              ? List<String>.from(json['extendedIngredients']
              .map((ingredient) => ingredient['original'] ?? 'Unknown'))
              : [],
          instructions: json['instructions'] ?? 'No instructions available.',
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch recipes');
    }
  }

  // Method to fetch recipes by name
  Future<List<Recipe>> searchRecipesByName(String recipeName) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?query=$recipeName&number=10&apiKey=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'] ?? [];

      // Optionally fetch detailed info for each recipe using `getRecipeDetails`
      return results.map<Recipe>((json) {
        return Recipe(
          title: json['title'] ?? 'No Title',
          imageUrl: json['image'] ?? '',
          ingredients: [], // Fetch details if needed
          instructions: '', // Fetch instructions if needed
        );
      }).toList();
    } else {
      throw Exception('Failed to load recipes by name');
    }
  }
}
