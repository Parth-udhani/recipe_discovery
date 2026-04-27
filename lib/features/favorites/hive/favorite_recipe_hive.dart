import 'package:hive/hive.dart';
import '../../recipes/data/models/recipe_model.dart';

class FavoriteRecipeHive {
  final Box<RecipeModel> favoritesBox;

  FavoriteRecipeHive(this.favoritesBox);

  Future<void> addFavorite(RecipeModel recipe) async {
    await favoritesBox.put(recipe.id, recipe);
  }

  Future<void> removeFavorite(String id) async {
    await favoritesBox.delete(id);
  }

  List<RecipeModel> getAllFavorites() {
    return favoritesBox.values.toList();
  }

  bool isFavorite(String id) {
    return favoritesBox.containsKey(id);
  }
}