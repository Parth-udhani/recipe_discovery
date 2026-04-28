import 'package:hive/hive.dart';
import '../../../core/utils/app_logger.dart';
import '../../recipes/data/models/recipe_model.dart';

class FavoriteRecipeHive {

  final Box<RecipeModel> favoritesBox;
  FavoriteRecipeHive(this.favoritesBox);

  Future<void> addFavorite(RecipeModel recipe) async {
    AppLogger.info( 'Adding to favorites → "${recipe.name}" (id: ${recipe.id})');
    await favoritesBox.put(recipe.id, recipe);
    AppLogger.debug( '"${recipe.name}" added to favorites ✓ — total favorites: ${favoritesBox.length}');
  }

  Future<void> removeFavorite(String id) async {
    final existing = favoritesBox.get(id);
    AppLogger.info( 'Removing from favorites → "${existing?.name ?? id}" (id: $id)');
    await favoritesBox.delete(id);
    AppLogger.debug( 'Removed from favorites ✓ — total favorites: ${favoritesBox.length}');
  }

  List<RecipeModel> getAllFavorites() {
    final favorites = favoritesBox.values.toList();
    AppLogger.info( 'Loading all favorites → found ${favorites.length} saved recipes');
    if (favorites.isEmpty) {
      AppLogger.info( 'Favorites box is empty — user has no saved recipes yet');
    } else {
      final names = favorites.map((r) => '"${r.name}"').join(', ');
      AppLogger.info( 'Favorites: [$names]');
    }
    return favorites;
  }

  bool isFavorite(String id) {
    final result = favoritesBox.containsKey(id);
    AppLogger.info( 'isFavorite check → id: $id → ${result ? "YES ❤️" : "NO 🤍"}');
    return result;
  }
}