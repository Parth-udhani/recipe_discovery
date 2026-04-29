import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_discovery/features/recipes/domain/entities/recipe.dart';

void main() {
  group('Recipe entity', () {
    const recipe = Recipe(
      id: '1',
      name: 'Butter Chicken',
      category: 'Chicken',
      area: 'Indian',
      instructions: 'Cook it well.',
      thumbnail: 'https://example.com/img.jpg',
      ingredients: ['Chicken', 'Butter', 'Cream'],
      measures: ['500g', '2 tbsp', '100ml'],
    );

    test('default isFavorite is false', () {
      expect(recipe.isFavorite, false);
    });

    test('copyWith updates isFavorite correctly', () {
      final updated = recipe.copyWith(isFavorite: true);
      expect(updated.isFavorite, true);
      expect(updated.name, 'Butter Chicken');
    });

    test('copyWith preserves original when no args passed', () {
      final copy = recipe.copyWith();
      expect(copy.id, recipe.id);
      expect(copy.name, recipe.name);
      expect(copy.ingredients.length, recipe.ingredients.length);
    });

    test('ingredients and measures have same length', () {
      expect(recipe.ingredients.length, recipe.measures.length);
    });
  });
}