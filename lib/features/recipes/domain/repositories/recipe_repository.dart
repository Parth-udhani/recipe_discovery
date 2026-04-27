import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> searchRecipes(String query);
  Future<List<Recipe>> getRecipesByCategory(String category);
  Future<List<Recipe>> getRecipesByArea(String area);
  Future<Recipe?> getRecipeDetail(String id);
  Future<List<Recipe>> getCachedRecipes();
}