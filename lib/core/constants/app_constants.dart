class AppConstants {
  // API
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String searchUrl = '$baseUrl/search.php';
  static const String filterUrl = '$baseUrl/filter.php';
  static const String categoryUrl = '$baseUrl/categories.php';
  static const String lookupUrl = '$baseUrl/lookup.php';

  // Hive Box Names
  static const String favoritesBox = 'favorites_box';
  static const String cachedRecipesBox = 'cached_recipes_box';

  // Time-based meal categories
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';

  // Location fallback
  static const String defaultCuisine = 'Indian';
  static const String defaultArea = 'India';

  // Debounce duration
  static const int debounceMilliseconds = 500;

  // Map country to TheMealDB area
  static const Map<String, String> countryToCuisine = {
    'India': 'Indian',
    'United States': 'American',
    'Italy': 'Italian',
    'China': 'Chinese',
    'Japan': 'Japanese',
    'Mexico': 'Mexican',
    'France': 'French',
    'Thailand': 'Thai',
    'United Kingdom': 'British',
    'Turkey': 'Turkish',
    'Canada': 'Canadian',
    'Morocco': 'Moroccan',
    'Greece': 'Greek',
    'Spain': 'Spanish',
    'Egypt': 'Egyptian',
    'Philippines': 'Filipino',
    'Jamaica': 'Jamaican',
    'Poland': 'Polish',
    'Russia': 'Russian',
    'Tunisia': 'Tunisian',
    'Vietnam': 'Vietnamese',
    'Netherlands': 'Dutch',
    'Croatia': 'Croatian',
    'Ukraine': 'Ukrainian',
  };

  // Get meal category based on time
  static String getMealCategory() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return breakfast;
    } else if (hour >= 11 && hour < 16) {
      return lunch;
    } else {
      return dinner;
    }
  }

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Get emoji based on time
  static String getMealEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return '🌅';
    } else if (hour >= 11 && hour < 16) {
      return '☀️';
    } else {
      return '🌙';
    }
  }
}