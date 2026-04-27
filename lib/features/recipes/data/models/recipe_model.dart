import 'package:hive/hive.dart';
import '../../domain/entities/recipe.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class RecipeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String area;

  @HiveField(4)
  final String instructions;

  @HiveField(5)
  final String thumbnail;

  @HiveField(6)
  final String? youtubeUrl;

  @HiveField(7)
  final List<String> ingredients;

  @HiveField(8)
  final List<String> measures;

  @HiveField(9)
  final bool isFavorite;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    this.youtubeUrl,
    required this.ingredients,
    required this.measures,
    this.isFavorite = false,
  });

  // From JSON (API response)
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    final ingredients = <String>[];
    final measures = <String>[];

    // TheMealDB has ingredient1..ingredient20 and measure1..measure20
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measures.add(measure?.toString().trim() ?? '');
      }
    }

    return RecipeModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  // To JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnail,
      'strYoutube': youtubeUrl,
      'ingredients': ingredients,
      'measures': measures,
      'isFavorite': isFavorite,
    };
  }

  // Convert to domain entity
  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      category: category,
      area: area,
      instructions: instructions,
      thumbnail: thumbnail,
      youtubeUrl: youtubeUrl,
      ingredients: ingredients,
      measures: measures,
      isFavorite: isFavorite,
    );
  }

  // Convert from domain entity
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      category: recipe.category,
      area: recipe.area,
      instructions: recipe.instructions,
      thumbnail: recipe.thumbnail,
      youtubeUrl: recipe.youtubeUrl,
      ingredients: recipe.ingredients,
      measures: recipe.measures,
      isFavorite: recipe.isFavorite,
    );
  }
}