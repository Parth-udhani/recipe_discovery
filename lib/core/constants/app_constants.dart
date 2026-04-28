// lib/core/constants/app_constants.dart
class AppConstants {
  // ── API ───────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String searchUrl  = '$baseUrl/search.php';
  static const String filterUrl  = '$baseUrl/filter.php';
  static const String categoryUrl = '$baseUrl/categories.php';
  static const String lookupUrl  = '$baseUrl/lookup.php';

  // ── Hive ──────────────────────────────────────────────────────────────────
  static const String favoritesBox    = 'favorites_box';
  static const String cachedRecipesBox = 'cached_recipes_box';

  // ── Meal categories ───────────────────────────────────────────────────────
  static const String breakfast = 'Breakfast';
  static const String lunch     = 'Lunch';
  static const String dinner    = 'Dinner';

  // ── Location fallback ─────────────────────────────────────────────────────
  static const String defaultCuisine = 'Indian';
  static const String defaultArea    = 'India';

  // ── Search debounce ───────────────────────────────────────────────────────
  static const int debounceMilliseconds = 500;

  // ── Country → TheMealDB area mapping ─────────────────────────────────────
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

  // ── Time-based helpers ────────────────────────────────────────────────────
  // Single read so all three helpers are consistent within the same call.
  static int get _hour => DateTime.now().hour;

  static String getMealCategory() {
    if (_hour >= 5 && _hour < 11) return breakfast;
    if (_hour >= 11 && _hour < 16) return lunch;
    return dinner;
  }

  static String getGreeting() {
    if (_hour >= 5  && _hour < 12) return 'Good Morning';
    if (_hour >= 12 && _hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String getMealEmoji() {
    if (_hour >= 5  && _hour < 11) return '🌅';
    if (_hour >= 11 && _hour < 16) return '☀️';
    return '🌙';
  }
}