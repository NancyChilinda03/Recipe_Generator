import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/search_service.dart';
import 'recipe_details.dart';
import 'favorite.dart';
import 'search.dart';
import 'profile.dart';

class RecipeHomePage extends StatefulWidget {
  const RecipeHomePage({super.key});

  @override
  _RecipeHomePageState createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  List<Recipe> recipes = [];
  bool isLoading = false;
  String? _errorMessage;
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController(); // Added controller
  late final RecipeSearchService _recipeSearchService;

  @override
  void initState() {
    super.initState();
    _recipeSearchService = RecipeSearchService(RecipeService());
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.spoonacular.com/recipes/random?apiKey=9ac2fe88293041e69bb4536b1dc70bc1&number=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['recipes'];
        if (data != null) {
          setState(() {
            recipes = data
                .map<Recipe>((recipeData) => Recipe.fromJson(recipeData))
                .toList();
          });
        } else {
          throw Exception('No recipes found.');
        }
      } else {
        throw Exception(
            'Failed to load recipes. Error code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching recipes: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // New method for fetching recipes by name
  Future<void> fetchRecipesByName(String name) async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final searchedRecipes = await _recipeSearchService.searchRecipesByName(name);
      setState(() {
        recipes = searchedRecipes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching recipes: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        fetchRecipes(); // Call fetchRecipes when "Recipes" tab is tapped
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(right: 50.0), // Adjust padding as needed
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'FlavorFinds',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),

      ),
      body: _selectedIndex == 0
          ? _buildRecipesPage()
          : _selectedIndex == 1
          ? SearchPage(recipeSearchService: _recipeSearchService)
          : _selectedIndex == 2
          ? const FavoritePage()
          : _selectedIndex == 3
          ? const ProfilePage()
          : const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_sharp),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildRecipesPage() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController, // Attached controller
                  decoration: InputDecoration(
                    hintText: 'Search by recipe name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      fetchRecipesByName(query); // Trigger search on submission
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: fetchRecipes,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : recipes.isEmpty
                ? const Center(
              child: Text(
                'No recipes found. Please reload.',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3 / 4,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                  child: RecipeCard(recipe: recipe),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          children: [
            Expanded(
              child: recipe.imageUrl?.isNotEmpty ?? false
                  ? Image.network(
                recipe.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
              )
                  : const Icon(Icons.image_not_supported),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                recipe.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
