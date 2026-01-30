// lib/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/nav_provider.dart';
import 'core/widgets/footer.dart';

// Import halaman konten Anda
import 'features/home/home_page.dart';
import 'features/home/event/event_list.dart';
import 'features/home/event/my_events_page.dart';
import 'features/profile/profile_page.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      // extendBody tetap true agar konten merayap di bawah footer blur
      extendBody: true,

      // Header null agar tab selain Home tidak punya AppBar global
      appBar: null,

      // SafeArea memastikan konten tidak menabrak status bar/notch
      body: SafeArea(
        // Kita hanya butuh SafeArea di bagian atas (top)
        // karena bagian bawah sudah di-handle oleh extendBody & padding footer
        top: true,
        bottom: false,
        child: IndexedStack(
          index: currentIndex,
          children: const [
            HomePage(),      // HomePage punya Scaffold & AppBar sendiri di dalamnya
            EventListPage(),
            MyEventsPage(),
            ProfilePage(),
          ],
        ),
      ),

      bottomNavigationBar: MainFooterNav(
        currentIndex: currentIndex,
        onItemSelected: (index) {
          ref.read(navIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}