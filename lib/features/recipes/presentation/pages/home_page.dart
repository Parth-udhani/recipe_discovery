import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../domain/entities/recipe.dart';
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
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _cubit = sl<RecipeCubit>();
    _init();

    sl<ConnectivityService>().onConnectivityChanged.listen((connected) {
      if (mounted) setState(() => _isOffline = !connected);
    });
  }

  Future<void> _init() async {
    setState(() => _isLocating = true);
    final area = await sl<LocationService>().getAreaCuisine();
    if (mounted) setState(() {
      _detectedArea = area;
      _isLocating = false;
    });
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
                    Icon(Icons.wifi_off_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'No internet — showing cached recipes',
                      style:
                      TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                )
                    : null,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _init,
                  color: AppTheme.primary,
                  child: CustomScrollView(
                    slivers: [
                      _buildHeader(),
                      _buildContextBadge(),
                      _buildSearchBar(),
                      _buildBody(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

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
                const SizedBox(height: 2),
                Text(
                  'What are you cooking today?',
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
              child: const Icon(Icons.restaurant_menu_rounded,
                  color: AppTheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Context Badge (replaces chips) ────────────────────────────────────────
  //
  // Shows a single pill that communicates what context is active
  // (time-of-day + location when available). Tapping it refreshes.

  Widget _buildContextBadge() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: GestureDetector(
          onTap: _init,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isLocating
                ? _ContextPill(
              key: const ValueKey('locating'),
              icon: Icons.location_searching_rounded,
              label: 'Detecting your location…',
              color: AppTheme.textSecondary,
            )
                : _ContextPill(
              key: ValueKey(_detectedArea ?? 'time'),
              icon: _detectedArea != null
                  ? Icons.location_on_rounded
                  : Icons.access_time_rounded,
              label: _buildContextLabel(),
              color: AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  String _buildContextLabel() {
    final meal = AppConstants.getMealCategory();
    if (_detectedArea != null) {
      return '$_detectedArea • $meal';
    }
    return '$meal suggestions';
  }

  // ── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: SearchBarWidget(
          onChanged: _cubit.onSearchChanged,
          onClear: () =>
              _cubit.loadContextualRecipes(detectedArea: _detectedArea),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

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
              Icon(Icons.search_off_rounded,
                  size: 64, color: AppTheme.textSecondary),
              SizedBox(height: 16),
              Text('No recipes found',
                  style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
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

  // ── Bottom Nav ────────────────────────────────────────────────────────────

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

// ── Context Pill Widget ───────────────────────────────────────────────────────

class _ContextPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ContextPill({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.refresh_rounded, size: 12, color: color.withOpacity(0.6)),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

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
            Icon(icon,
                color: selected ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color:
                selected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

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
            const Icon(Icons.wifi_off_rounded,
                size: 72, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
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