import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesByArea {
  final RecipeRepository repository;
  GetRecipesByArea(this.repository);

  Future<List<Recipe>> call(String area) {
    return repository.getRecipesByArea(area);
  }
}