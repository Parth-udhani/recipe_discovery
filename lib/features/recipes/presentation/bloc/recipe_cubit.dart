import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/recipe_usecases.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../../../core/constants/app_constants.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final GetRecipesByCategory getRecipesByCategory;
  final GetRecipesByArea getRecipesByArea;
  final SearchRecipes searchRecipes;
  final RecipeRepository repository;

  Timer? _debounce;

  RecipeCubit({
    required this.getRecipesByCategory,
    required this.getRecipesByArea,
    required this.searchRecipes,
    required this.repository,
  }) : super(RecipeInitial());

  Future<void> loadContextualRecipes({String? detectedArea}) async {
    emit(RecipeLoading());
    try {
      final category = AppConstants.getMealCategory();

      // Load by area (location-based) if available, else by category
      if (detectedArea != null && detectedArea.isNotEmpty) {
        final recipes = await getRecipesByArea.call(detectedArea);
        if (recipes.isNotEmpty) {
          emit(RecipeLoaded(recipes, area: detectedArea));
          return;
        }
      }

      final recipes = await getRecipesByCategory.call(category);
      emit(RecipeLoaded(recipes));
    } catch (e) {
      final cached = await repository.getCachedRecipes();
      if (cached.isNotEmpty) {
        emit(RecipeLoaded(cached, isOffline: true));
      } else {
        emit(RecipeError(e.toString()));
      }
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      loadContextualRecipes();
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.debounceMilliseconds),
          () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    emit(RecipeLoading());
    try {
      final recipes = await searchRecipes.call(query);
      emit(RecipeLoaded(recipes));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> filterByArea(String area) async {
    emit(RecipeLoading());
    try {
      final recipes = await getRecipesByArea.call(area);
      emit(RecipeLoaded(recipes, area: area));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> filterByCategory(String category) async {
    emit(RecipeLoading());
    try {
      final recipes = await getRecipesByCategory.call(category);
      emit(RecipeLoaded(recipes));
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}