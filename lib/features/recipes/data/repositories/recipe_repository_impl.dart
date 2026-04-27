import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../models/recipe_model.dart';
import '../../../../core/network/connectivity_service.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remote;
  final RecipeLocalDataSource local;
  final ConnectivityService connectivity;

  RecipeRepositoryImpl({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  @override
  Future<List<Recipe>> searchRecipes(String query) async {
    if (await connectivity.isConnected) {
      try {
        final models = await remote.searchRecipes(query);
        await local.cacheRecipes(models);
        return models.map((m) => m.toEntity()).toList();
      } catch (_) {
        return _filteredCache(query);
      }
    }
    return _filteredCache(query);
  }

  List<Recipe> _filteredCache(String query) {
    final q = query.toLowerCase();
    return local
        .getCachedRecipes()
        .where((r) => r.name.toLowerCase().contains(q))
        .map((r) => r.toEntity())
        .toList();
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    if (await connectivity.isConnected) {
      try {
        final models = await remote.getRecipesByCategory(category);
        await local.cacheRecipes(models);
        return models.map((m) => m.toEntity()).toList();
      } catch (_) {
        return _cachedByCategory(category);
      }
    }
    return _cachedByCategory(category);
  }

  List<Recipe> _cachedByCategory(String category) {
    return local
        .getCachedRecipes()
        .where((r) => r.category == category)
        .map((r) => r.toEntity())
        .toList();
  }

  @override
  Future<List<Recipe>> getRecipesByArea(String area) async {
    if (await connectivity.isConnected) {
      try {
        final models = await remote.getRecipesByArea(area);
        await local.cacheRecipes(models);
        return models.map((m) => m.toEntity()).toList();
      } catch (_) {
        return _cachedByArea(area);
      }
    }
    return _cachedByArea(area);
  }

  List<Recipe> _cachedByArea(String area) {
    return local
        .getCachedRecipes()
        .where((r) => r.area == area)
        .map((r) => r.toEntity())
        .toList();
  }

  @override
  Future<Recipe?> getRecipeDetail(String id) async {
    if (await connectivity.isConnected) {
      try {
        final model = await remote.getRecipeDetail(id);
        if (model != null) {
          await local.cacheRecipe(model);
          return model.toEntity();
        }
      } catch (_) {}
    }
    return local.getCachedRecipe(id)?.toEntity();
  }

  @override
  Future<List<Recipe>> getCachedRecipes() async {
    return local.getCachedRecipes().map((m) => m.toEntity()).toList();
  }
}