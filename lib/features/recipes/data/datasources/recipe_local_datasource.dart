import 'package:hive/hive.dart';
import '../models/recipe_model.dart';

class RecipeLocalDataSource {
  final Box<RecipeModel> cachedBox;

  RecipeLocalDataSource(this.cachedBox);

  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    final map = {for (var r in recipes) r.id: r};
    await cachedBox.putAll(map);
  }

  Future<void> cacheRecipe(RecipeModel recipe) async {
    await cachedBox.put(recipe.id, recipe);
  }

  List<RecipeModel> getCachedRecipes() {
    return cachedBox.values.toList();
  }

  RecipeModel? getCachedRecipe(String id) {
    return cachedBox.get(id);
  }

  Future<void> clearCache() async {
    await cachedBox.clear();
  }
}