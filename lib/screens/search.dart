import 'package:flutter/material.dart';
import 'package:recipe_generator/screens/home.dart';
import '../../models/recipe.dart';
import '../services/search_service.dart';
import 'recipe_details.dart';

class SearchPage extends StatefulWidget {
  final RecipeSearchService recipeSearchService;

  const SearchPage({super.key, required this.recipeSearchService});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchRecipes() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter at least one ingredient.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await widget.recipeSearchService.searchRecipes(query);
      setState(() {
        _searchResults = recipes;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Recipes',
            style: TextStyle(color: Colors.white),
      ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.push(context,
              MaterialPageRoute(
                builder: (context) => RecipeHomePage(),
              ),);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchRecipes,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_searchResults.isEmpty)
                const Center(child: Text('No recipes found.')),
            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final recipe = _searchResults[index];
                    return Card(
                      child: ListTile(
                        leading: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                            ? Image.network(
                          recipe.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : const Icon(Icons.image_not_supported),
                        title: Text(recipe.title),
                        subtitle: Text(
                          recipe.ingredients.isNotEmpty
                              ? recipe.ingredients.join(', ')
                              : 'No ingredients available',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: ()  {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(recipe: recipe),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
