// lib/features/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/session_manager.dart';

const Color kPrimaryColor = Color(0xFF641515);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  String _buildInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    }
    return (parts[0].isNotEmpty ? parts[0][0] : '') +
        (parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(currentSessionProvider);

    // MENGGUNAKAN MATERIAL SEBAGAI ROOT (BUKAN SCAFFOLD)
    // Scaffold sudah dihandle secara global oleh PageWrapper agar navigasi halus
    return Material(
      color: Colors.transparent,
      child: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Gagal memuat profil:\n$err'),
        ),
        data: (session) {
          if (session == null) {
            return const Center(
              child: Text('Belum ada data sesi. Silakan login terlebih dahulu.'),
            );
          }

          final mhs = session.mahasiswa;
          final user = session.user;

          final nama = mhs.nama.isNotEmpty ? mhs.nama : user.name;
          final npm = mhs.npm;
          final fakultas = mhs.namaFakultas;
          final prodi = mhs.namaProdi;
          final angkatan = mhs.angkatan;
          final email = user.email;

          final initials = _buildInitials(nama);

          return SingleChildScrollView(
            // PADDING BAWAH EXTRA AGAR KONTEN TIDAK TERTUTUP FOOTER MELAYANG
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
            child: Column(
              children: [
                // =====================================================
                // KARTU PROFILE (MODERN FLAT)
                // =====================================================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // BAGIAN ATAS (GRADIENT HEADER)
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kPrimaryColor, Color(0xFF8A1F1F)],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                nama,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prodi.isNotEmpty ? prodi : 'Mahasiswa',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              // MINI INFO BAR
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _MiniInfo(label: 'NPM', value: npm),
                                  Container(
                                    width: 1, height: 20,
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    color: Colors.white24,
                                  ),
                                  _MiniInfo(
                                    label: 'Angkatan',
                                    value: angkatan.isEmpty ? '-' : angkatan,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // BAGIAN BAWAH (DETAIL LIST)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _ProfileItem(
                                icon: Icons.person_outline_rounded,
                                label: 'Nama Lengkap',
                                value: nama,
                              ),
                              _ProfileItem(
                                icon: Icons.badge_outlined,
                                label: 'NPM',
                                value: npm,
                              ),
                              _ProfileItem(
                                icon: Icons.school_outlined,
                                label: 'Fakultas',
                                value: fakultas.isEmpty ? '-' : fakultas,
                              ),
                              _ProfileItem(
                                icon: Icons.apartment_rounded,
                                label: 'Program Studi',
                                value: prodi.isEmpty ? '-' : prodi,
                              ),
                              _ProfileItem(
                                icon: Icons.event_available_outlined,
                                label: 'Tahun Angkatan',
                                value: angkatan.isEmpty ? '-' : angkatan,
                              ),
                              _ProfileItem(
                                icon: Icons.email_outlined,
                                label: 'Alamat Email',
                                value: email,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;
  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 22),
          ),
          title: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
          ),
        ),
        Divider(color: Colors.grey.shade100, height: 1),
      ],
    );
  }
}