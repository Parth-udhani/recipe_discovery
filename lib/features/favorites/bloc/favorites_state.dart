import '../../recipes/domain/entities/recipe.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Recipe> favorites;

  FavoritesLoaded(this.favorites);
}