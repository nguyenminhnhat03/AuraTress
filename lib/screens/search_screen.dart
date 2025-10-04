import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/salon_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/top_navbar.dart';
import '../theme.dart';
import 'book_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final String _location = 'hochiminh';
  String _categoryValue = 'all';
  String _categoryLabelKey = 'filter.all_salons';
  String _distanceValue = 'all';
  String _distanceLabelKey = 'filter.all';

  @override
  void initState() {
    super.initState();
    ref.read(salonProvider.notifier).search(_location);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salonsAsync = ref.watch(salonProvider);

    return Scaffold(
      appBar: const TopNavbar(activeIndex: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search.placeholder'.tr(),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
              onSubmitted: (value) => ref.read(salonProvider.notifier).search(
                _location,
                category: _categoryValue == 'all' ? null : _categoryValue,
                service: value.isEmpty ? null : value,
                maxDistanceKm: _distanceValue == 'all' ? null : double.tryParse(_distanceValue),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                _FilterChipPopup(
                  label: _categoryLabelKey.tr(),
                  icon: Icons.filter_alt,
                  items: const [
                    {'labelKey': 'filter.all_salons', 'value': 'all'},
                    {'labelKey': 'service.premium_cut', 'value': 'Premium Cut & Style'},
                    {'labelKey': 'service.ai_color', 'value': 'AI Color Consultation'},
                    {'labelKey': 'service.spa_treatment', 'value': 'Spa Treatment'},
                  ],
                  onSelected: (map) {
                    setState(() {
                      _categoryValue = map['value'] as String;
                      _categoryLabelKey = map['labelKey'] as String;
                    });
                    ref.read(salonProvider.notifier).search(
                      _location,
                      category: _categoryValue == 'all' ? null : _categoryValue,
                      service: _searchController.text.isEmpty ? null : _searchController.text,
                      maxDistanceKm: _distanceValue == 'all' ? null : double.tryParse(_distanceValue),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _FilterChipPopup(
                  label: _distanceLabelKey.tr(),
                  icon: Icons.place_outlined,
                  items: const [
                    {'labelKey': 'filter.all', 'value': 'all'},
                    {'labelKey': 'filter.km_0_5', 'value': '0.5'},
                    {'labelKey': 'filter.km_1', 'value': '1'},
                    {'labelKey': 'filter.km_3', 'value': '3'},
                  ],
                  onSelected: (map) {
                    setState(() {
                      _distanceValue = map['value'] as String;
                      _distanceLabelKey = map['labelKey'] as String;
                    });
                    ref.read(salonProvider.notifier).search(
                      _location,
                      category: _categoryValue == 'all' ? null : _categoryValue,
                      service: _searchController.text.isEmpty ? null : _searchController.text,
                      maxDistanceKm: _distanceValue == 'all' ? null : double.tryParse(_distanceValue),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: salonsAsync.when(
              data: (salons) {
                // List already filtered by API; just render
                final filtered = salons;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final salon = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final userId = ref.read(authProvider).value?.id ?? '';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookScreen(userId: userId, salon: salon),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with salon name and rating
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.content_cut,
                                        color: AppTheme.accent,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            salon.name,
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                size: 16,
                                                color: Colors.amber.shade400,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${salon.rating} ${'salon.rating'.tr()}',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '(${salon.reviews} ${'salon.reviews'.tr()})',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.buttonGradient,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        salon.priceRange,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Location
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        salon.location,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Services
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: salon.services.take(3).map((service) => 
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        service,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ).toList(),
                                ),
                                if (salon.services.length > 3) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '+${salon.services.length - 3} more',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${'common.error'.tr()}: $e', style: const TextStyle(color: Colors.white)),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(salonProvider),
                      child: Text('common.retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F0A1F),
    );
  }
}

class _FilterChipPopup extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Map<String, String>> items; // [{labelKey,value}]
  final ValueChanged<Map<String, String>> onSelected;
  const _FilterChipPopup({required this.label, required this.icon, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Map<String, String>>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final item in items) PopupMenuItem(value: item, child: Text(item['labelKey']!.tr())),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}
