import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorite_services.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoriteService.isFavorite(widget.recipe);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(widget.recipe);
    } else {
      await _favoriteService.addFavorite(widget.recipe);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.recipe.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.green,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe image
              if (widget.recipe.imageUrl?.isNotEmpty ?? false)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.recipe.imageUrl!,
                    width: double.infinity,
                    height: 200, // Limit the height
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 200, color: Colors.grey),
                  ),
                )
              else
                const Icon(Icons.broken_image, size: 200, color: Colors.grey),
              const SizedBox(height: 16.0),

              // Ingredients section
              _buildSection(
                context,
                title: 'Ingredients',
                content: widget.recipe.ingredients.map((ingredient) {
                  return _buildBulletPoint(ingredient);
                }).toList() ??
                    [const Text('No ingredients available.')],
              ),
              const SizedBox(height: 16.0),

              // Instructions section
              _buildSection(
                context,
                title: 'Instructions',
                content: widget.recipe.instructions.split('\n').map((step) {
                  return _buildBulletPoint(step);
                }).toList() ??
                    [const Text('No instructions available.')],
              ),
              const SizedBox(height: 16.0),

              // Share button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Add share functionality here
                  },
                  icon: const Icon(Icons.share, color: Colors.black),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16.0, color: Colors.black),
              softWrap: true, // Allow text wrapping
              overflow: TextOverflow.clip, // Avoid ellipsis for content
            ),
          ),
        ],
      ),
    );
  }
}
