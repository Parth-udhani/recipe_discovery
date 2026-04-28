import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
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
    AppLogger.info( 'searchRecipes called → query: "$query"');

    if (await connectivity.isConnected) {
      AppLogger.info( 'Online — fetching search results from API...');
      try {
        final models = await remote.searchRecipes(query);
        AppLogger.info( 'Caching ${models.length} search results locally...');
        await local.cacheRecipes(models);
        AppLogger.debug( 'searchRecipes complete → ${models.length} results returned');
        return models.map((m) => m.toEntity()).toList();
      } catch (e) {
        AppLogger.error( 'API search failed — falling back to cache');
        return _filteredCache(query);
      }
    }

    AppLogger.warning( 'Offline — searching in local cache for "$query"');
    return _filteredCache(query);
  }

  List<Recipe> _filteredCache(String query) {
    final q = query.toLowerCase();
    final results = local
        .getCachedRecipes()
        .where((r) => r.name.toLowerCase().contains(q))
        .map((r) => r.toEntity())
        .toList();
    AppLogger.warning( 'Cache search for "$query" → found ${results.length} matching recipes');
    return results;
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    AppLogger.info( 'getRecipesByCategory called → "$category"');

    if (await connectivity.isConnected) {
      AppLogger.info( 'Online — fetching category "$category" from API...');
      try {
        final models = await remote.getRecipesByCategory(category);
        AppLogger.info( 'Caching ${models.length} recipes for category "$category"...');
        await local.cacheRecipes(models);
        AppLogger.debug( 'getRecipesByCategory complete → ${models.length} recipes');
        return models.map((m) => m.toEntity()).toList();
      } catch (e) {
        AppLogger.error( 'Category API failed — falling back to cache for "$category"');
        return _cachedByCategory(category);
      }
    }

    AppLogger.warning( 'Offline — loading category "$category" from cache');
    return _cachedByCategory(category);
  }

  List<Recipe> _cachedByCategory(String category) {
    final results = local
        .getCachedRecipes()
        .where((r) => r.category == category)
        .map((r) => r.toEntity())
        .toList();
    AppLogger.warning( 'Cache fallback for category "$category" → ${results.length} recipes found');
    return results;
  }

  @override
  Future<List<Recipe>> getRecipesByArea(String area) async {
    AppLogger.info( 'getRecipesByArea called → "$area"');

    if (await connectivity.isConnected) {
      AppLogger.info( 'Online — fetching area "$area" from API...');
      try {
        final models = await remote.getRecipesByArea(area);
        AppLogger.info( 'Caching ${models.length} recipes for area "$area"...');
        await local.cacheRecipes(models);
        AppLogger.debug( 'getRecipesByArea complete → ${models.length} recipes');
        return models.map((m) => m.toEntity()).toList();
      } catch (e) {
        AppLogger.error( 'Area API failed — falling back to cache for "$area"');
        return _cachedByArea(area);
      }
    }

    AppLogger.warning( 'Offline — loading area "$area" from cache');
    return _cachedByArea(area);
  }

  List<Recipe> _cachedByArea(String area) {
    final results = local
        .getCachedRecipes()
        .where((r) => r.area == area)
        .map((r) => r.toEntity())
        .toList();
    AppLogger.warning( 'Cache fallback for area "$area" → ${results.length} recipes found');
    return results;
  }

  @override
  Future<Recipe?> getRecipeDetail(String id) async {
    AppLogger.info( 'getRecipeDetail called → id: $id');

    if (await connectivity.isConnected) {
      AppLogger.info( 'Online — fetching full detail for id: $id');
      try {
        final model = await remote.getRecipeDetail(id);
        if (model != null) {
          AppLogger.info( 'Caching detail for "${model.name}"...');
          await local.cacheRecipe(model);
          AppLogger.debug( 'getRecipeDetail complete → "${model.name}"');
          return model.toEntity();
        }
        AppLogger.warning( 'Remote returned null for id: $id');
      } catch (e) {
        AppLogger.error( 'Detail API failed for id: $id — checking cache');
      }
    } else {
      AppLogger.warning( 'Offline — looking up detail for id: $id in cache');
    }

    final cached = local.getCachedRecipe(id);
    if (cached != null) {
      AppLogger.debug( 'Returning cached detail for "${cached.name}"');
    } else {
      AppLogger.error( 'No cached detail found for id: $id');
    }
    return cached?.toEntity();
  }

  @override
  Future<List<Recipe>> getCachedRecipes() async {
    AppLogger.info( 'getCachedRecipes called — reading all from local storage');
    final recipes = local.getCachedRecipes().map((m) => m.toEntity()).toList();
    AppLogger.debug( 'getCachedRecipes → returned ${recipes.length} cached recipes');
    return recipes;
  }
}