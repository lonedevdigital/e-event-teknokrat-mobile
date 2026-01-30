// lib/core/widgets/footer.dart
import 'dart:ui';
import 'package:flutter/material.dart';

// Warna Maron Solid sesuai identitas aplikasi Anda
const Color kPrimaryColor = Color(0xFF641515);

class MainFooterNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const MainFooterNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Jarak sisi agar footer terlihat melayang (Floating)
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          // Menggunakan warna solid maron pekat sesuai permintaan
          color: kPrimaryColor.withOpacity(0.98),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur halus
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.explore_rounded, 'Events'),
                // UPDATE: Label diganti ke My Events & Ikon diganti ke kalender centang
                _buildNavItem(2, Icons.event_available_rounded, 'My Events'),
                _buildNavItem(3, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.decelerate,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // Pill/Kapsul latar belakang untuk item aktif
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 24,
            ),
            // Teks muncul hanya saat item aktif sesuai desain referensi
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}