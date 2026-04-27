import '../../domain/entities/recipe.dart';

abstract class RecipeState {}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;
  final String? area;
  final bool isOffline;

  RecipeLoaded(this.recipes, {this.area, this.isOffline = false});
}

class RecipeError extends RecipeState {
  final String message;
  final List<Recipe> cachedRecipes;

  RecipeError(this.message, {this.cachedRecipes = const []});
}