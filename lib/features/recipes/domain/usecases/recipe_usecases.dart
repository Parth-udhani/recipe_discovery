import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipesByArea {
  final RecipeRepository repository;
  GetRecipesByArea(this.repository);

  Future<List<Recipe>> call(String area) {
    return repository.getRecipesByArea(area);
  }
}

class GetRecipesByCategory {
  final RecipeRepository repository;
  GetRecipesByCategory(this.repository);

  Future<List<Recipe>> call(String category) {
    return repository.getRecipesByCategory(category);
  }
}

class SearchRecipes {
  final RecipeRepository repository;
  SearchRecipes(this.repository);

  Future<List<Recipe>> call(String query) {
    return repository.searchRecipes(query);
  }
}