import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../notifications/notification_service.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/usecases/recipe_usecases.dart';
import '../bloc/recipe_cubit.dart';
import '../bloc/recipe_state.dart';
import '../widgets/recipe_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shimmer_card.dart';
import 'favorites_page.dart';
import '../../data/datasources/location_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final RecipeCubit _cubit;
  String? _detectedArea;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<RecipeCubit>();
    _init();

    // Listen to connectivity
    sl<ConnectivityService>().onConnectivityChanged.listen((connected) {
      if (mounted) setState(() => _isOffline = !connected);
    });
  }

  Future<void> _init() async {
    final area = await sl<LocationService>().getAreaCuisine();
    setState(() => _detectedArea = area);
    await _cubit.loadContextualRecipes(detectedArea: area);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Offline Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isOffline ? 40 : 0,
                color: AppTheme.error,
                child: _isOffline
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'No internet — showing cached recipes',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      )
                    : null,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      _cubit.loadContextualRecipes(detectedArea: _detectedArea),
                  color: AppTheme.primary,
                  child: CustomScrollView(
                    slivers: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildCategoryChips(),
                      _buildBody(),

                    ],
                  ),
                ),
              ),
              // In any page (wrap in kDebugMode)

                ElevatedButton(
                    // onPressed: () async {
                    //   final plugin = FlutterLocalNotificationsPlugin();
                    //
                    //   await plugin.show(
                    //     999,
                    //     "Instant Test",
                    //     "If you see this, notifications work",
                    //     const NotificationDetails(
                    //       android: AndroidNotificationDetails(
                    //         'test_channel',
                    //         'Test',
                    //         importance: Importance.high,
                    //         priority: Priority.high,
                    //       ),
                    //     ),
                    //   );
                    // },
                  onPressed: () async {
                    print("Button clicked");
                    final svc = sl<NotificationService>();
                    final recipes = await sl<GetRecipesByCategory>().call('Chicken');
                    await svc.scheduleTestNotifications(
                      breakfast: recipes.first,
                      lunch: recipes.first,
                      dinner: recipes.first,
                    );
                  },
                  child: const Text('[DEV] Test Notifications'),
                )
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppConstants.getMealEmoji()} ${AppConstants.getGreeting()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _detectedArea != null
                      ? 'Showing $_detectedArea cuisine for you'
                      : 'What are you cooking today?',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: SearchBarWidget(
          onChanged: _cubit.onSearchChanged,
          onClear: () =>
              _cubit.loadContextualRecipes(detectedArea: _detectedArea),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      ('All', null),
      ('🌅 Breakfast', AppConstants.breakfast),
      ('☀️ Lunch', AppConstants.lunch),
      ('🌙 Dinner', AppConstants.dinner),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final (label, category) = categories[index];
            return GestureDetector(
              onTap: () {
                if (category == null) {
                  _cubit.loadContextualRecipes(detectedArea: _detectedArea);
                } else {
                  _cubit.filterByCategory(category);
                }
              },
              child: Chip(
                label: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
                backgroundColor: AppTheme.primary,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<RecipeCubit, RecipeState>(
      listener: (context, state) {
        if (state is RecipeLoaded && state.isOffline) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Showing cached recipes'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.textSecondary,
            ),
          );
        }
        if (state is RecipeError && state.cachedRecipes.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is RecipeLoading) {
          return const SliverToBoxAdapter(child: ShimmerGrid());
        }

        if (state is RecipeLoaded) {
          return _buildGrid(state.recipes);
        }

        if (state is RecipeError) {
          if (state.cachedRecipes.isNotEmpty) {
            return _buildGrid(state.cachedRecipes);
          }
          return SliverFillRemaining(
            child: _ErrorView(
              message: state.message,
              onRetry: () =>
                  _cubit.loadContextualRecipes(detectedArea: _detectedArea),
            ),
          );
        }

        return const SliverToBoxAdapter(child: ShimmerGrid());
      },
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No recipes found',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => RecipeCard(recipe: recipes[index]),
          childCount: recipes.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: true,
              onTap: () {},
            ),
            _NavItem(
              icon: Icons.favorite_rounded,
              label: 'Favorites',
              selected: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 72,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
