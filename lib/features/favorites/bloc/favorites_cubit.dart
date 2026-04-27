import 'package:flutter_bloc/flutter_bloc.dart';
import '../hive/favorite_recipe_hive.dart';
import '../../recipes/data/models/recipe_model.dart';
import '../../recipes/domain/entities/recipe.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoriteRecipeHive _hive;

  FavoritesCubit(this._hive) : super(FavoritesInitial());

  void loadFavorites() {
    final favorites = _hive.getAllFavorites().map((m) => m.toEntity()).toList();
    emit(FavoritesLoaded(favorites));
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    if (_hive.isFavorite(recipe.id)) {
      await _hive.removeFavorite(recipe.id);
    } else {
      final model = RecipeModel.fromEntity(recipe.copyWith(isFavorite: true));
      await _hive.addFavorite(model);
    }
    loadFavorites();
  }

  bool isFavorite(String id) => _hive.isFavorite(id);
}