import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../screens/search_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/book_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/salon_admin_screen.dart';
import '../services/database_service.dart';
import '../screens/login_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'language_switcher.dart';

class TopNavbar extends ConsumerWidget implements PreferredSizeWidget {
  final int activeIndex; // 0: explore, 1: book, 2: ai, 3: profile
  const TopNavbar({super.key, required this.activeIndex});

  @override
  Size get preferredSize => const Size.fromHeight(140);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: logo, lang, auth button/profile
              Row(
                children: [
                  // Enhanced logo with glow effect
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.content_cut,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'app.name'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  const LanguageSwitcher(),
                  const SizedBox(width: 12),
if (user == null)
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFF8FAFC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => showLoginModal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'auth.login'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.accent.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () => ref.read(authProvider.notifier).logout(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            foregroundColor: AppTheme.textSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.logout, size: 16),
                          label: Text(
                            'auth.logout'.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Secondary nav row with enhanced design
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                  _NavChip(
                    label: 'navigation.search'.tr(),
                    icon: Icons.explore,
                    isActive: activeIndex == 0,
                    onTap: () => _navTo(context, const SearchScreen()),
                  ),
                  _NavChip(
                    label: 'navigation.appointments'.tr(),
                    icon: Icons.calendar_today,
                    isActive: activeIndex == 1,
                    onTap: () {
                      final uid = ref.read(authProvider).value?.id ?? '';
                      Navigator.push(context, MaterialPageRoute(builder: (_) => BookScreen(userId: uid)));
                    },
                  ),
                  _NavChip(
                    label: 'navigation.chat'.tr(),
                    icon: Icons.psychology_alt,
                    isActive: activeIndex == 2,
                    onTap: () => _navTo(context, const ChatScreen()),
                  ),
                  _NavChip(
                    label: 'navigation.profile'.tr(),
                    icon: Icons.person_outline,
                    isActive: activeIndex == 3,
                    onTap: () {
                      final uid = ref.read(authProvider).value?.id ?? '';
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: uid)));
                    },
                  ),
                  if ((ref.read(authProvider).value?.isAdmin ?? false))
                    _NavChip(
                      label: 'Admin',
                      icon: Icons.store_mall_directory,
                      isActive: false,
                      onTap: () {
                        final user = ref.read(authProvider).value;
                        if (user != null) {
                          final salonId = DatabaseService().getSalonIdForAdmin(user.id) ?? 'salon_lehieu_006';
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SalonAdminScreen(salonId: salonId)));
                        }
                      },
                    ),
                ].expand((w) sync* { yield w; yield const SizedBox(width: 4); }).toList()..removeLast(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _NavChip({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.buttonGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive 
                  ? AppTheme.accent.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.2),
              width: isActive ? 1.5 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

