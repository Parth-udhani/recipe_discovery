import 'package:hive/hive.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/recipe_model.dart';

class RecipeLocalDataSource {

  final Box<RecipeModel> cachedBox;
  RecipeLocalDataSource(this.cachedBox);

  Future<void> cacheRecipes(List<RecipeModel> recipes) async {
    AppLogger.info( 'Caching ${recipes.length} recipes to box "${cachedBox.name}"...');

    final map = {for (var r in recipes) r.id: r};
    await cachedBox.putAll(map);

    AppLogger.debug( 'Cached ${recipes.length} recipes — box now has ${cachedBox.length} total entries');
  }

  Future<void> cacheRecipe(RecipeModel recipe) async {
    AppLogger.info( 'Caching single recipe → "${recipe.name}" (id: ${recipe.id})');
    await cachedBox.put(recipe.id, recipe);
    AppLogger.debug( 'Single recipe cached ✓ — box total: ${cachedBox.length}');
  }

  List<RecipeModel> getCachedRecipes() {
    final recipes = cachedBox.values.toList();
    AppLogger.info( 'Reading all cached recipes → found ${recipes.length} entries');
    if (recipes.isEmpty) {
      AppLogger.warning( 'Cache is EMPTY — no local recipes available');
    }
    return recipes;
  }

  RecipeModel? getCachedRecipe(String id) {
    AppLogger.info( 'Looking up cached recipe by id: $id');
    final recipe = cachedBox.get(id);
    if (recipe != null) {
      AppLogger.debug( 'Cache HIT → "${recipe.name}" (id: $id)');
    } else {
      AppLogger.warning( 'Cache MISS → no recipe found for id: $id');
    }
    return recipe;
  }

  Future<void> clearCache() async {
    final count = cachedBox.length;
    AppLogger.info( 'Clearing cache — removing $count entries...');
    await cachedBox.clear();
    AppLogger.debug( 'Cache cleared ✓ — box is now empty');
  }
}