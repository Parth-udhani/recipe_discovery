import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_logger.dart';
import '../hive/favorite_recipe_hive.dart';
import '../../recipes/data/models/recipe_model.dart';
import '../../recipes/domain/entities/recipe.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {

  final FavoriteRecipeHive _hive;

  FavoritesCubit(this._hive) : super(FavoritesInitial()) {
    AppLogger.debug( 'FavoritesCubit created → initial state: FavoritesInitial');
  }

  void loadFavorites() {
    AppLogger.info( 'loadFavorites called — reading from Hive...');
    final favorites = _hive.getAllFavorites().map((m) => m.toEntity()).toList();
    AppLogger.info( 'Emitting FavoritesLoaded → ${favorites.length} favorites');
    emit(FavoritesLoaded(favorites));
    AppLogger.debug( 'FavoritesLoaded emitted ✓');
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final wasFavorite = _hive.isFavorite(recipe.id);
    AppLogger.info( 'toggleFavorite called → "${recipe.name}" | currently: ${wasFavorite ? "FAVORITED" : "NOT favorited"}');

    if (wasFavorite) {
      AppLogger.info( 'Removing "${recipe.name}" from favorites...');
      await _hive.removeFavorite(recipe.id);
      AppLogger.debug( '"${recipe.name}" removed from favorites ✓');
    } else {
      AppLogger.info( 'Adding "${recipe.name}" to favorites...');
      final model = RecipeModel.fromEntity(recipe.copyWith(isFavorite: true));
      await _hive.addFavorite(model);
      AppLogger.debug( '"${recipe.name}" added to favorites ✓');
    }

    AppLogger.info( 'Refreshing favorites list after toggle...');
    loadFavorites();
  }

  bool isFavorite(String id) {
    final result = _hive.isFavorite(id);
    AppLogger.info( 'isFavorite("$id") → $result');
    return result;
  }
}