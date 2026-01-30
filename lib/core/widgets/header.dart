// lib/core/widgets/header.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/session_manager.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/login_page.dart';

const Color kPrimaryColor = Color(0xFF641515);

/// Header utama aplikasi yang didesain untuk dipasang pada properti appBar di Scaffold
class MainHeader extends ConsumerWidget implements PreferredSizeWidget {
  final double height;
  final VoidCallback? onProfileTap;

  const MainHeader({
    super.key,
    this.height = 80, // Ukuran tinggi yang lebih proporsional untuk desain modern
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentSessionProvider);
    final session = sessionAsync.asData?.value;

    final namaMhs = session != null
        ? (session.mahasiswa.nama.isNotEmpty ? session.mahasiswa.nama : session.user.name)
        : 'Mahasiswa';

    String initials = '';
    final parts = namaMhs.trim().split(' ');
    if (parts.isNotEmpty) {
      initials = parts.take(2).map((e) => e.isNotEmpty ? e[0] : '').join();
    }

    // Mengembalikan PreferredSizeWidget (AppBar) secara langsung agar tidak bentrok dengan Scaffold luar
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20), // Sudut tumpul untuk kesan modern
          ),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Selamat Datang,',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        namaMhs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (onProfileTap != null) onProfileTap!();
                    _showProfileMenu(context, ref, namaMhs);
                  },
                  child: Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                        border: Border.all(color: Colors.white30, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          initials.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

void _showProfileMenu(BuildContext context, WidgetRef ref, String namaMhs) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person_outline_rounded, color: kPrimaryColor),
            title: Text(namaMhs, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Mahasiswa Teknokrat'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}