import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesByCategory {
  final RecipeRepository repository;
  GetRecipesByCategory(this.repository);

  Future<List<Recipe>> call(String category) {
    return repository.getRecipesByCategory(category);
  }
}