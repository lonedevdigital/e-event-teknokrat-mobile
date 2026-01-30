// lib/features/home/widgets/home_dok_list.dart
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF641515);

/// Data satu item dokumentasi di home.
class HomeDokItemData {
  final String id;
  final String title;
  final String? dateText;
  final String? imageUrl;
  final VoidCallback? onTap;

  const HomeDokItemData({
    required this.id,
    required this.title,
    this.dateText,
    this.imageUrl,
    this.onTap,
  });
}

class HomeDokList extends StatelessWidget {
  final List<HomeDokItemData> items;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  const HomeDokList({
    super.key,
    required this.items,
    this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH BAR MODERN FLAT
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Pencarian Dokumentasi...',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: kPrimaryColor, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none, // Flat design tanpa border garis
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (items.isEmpty)
            _buildEmptyState(theme)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85, // Rasio sedikit lebih tinggi agar teks tidak terpotong
              ),
              itemBuilder: (context, index) {
                return _DokCard(item: items[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Belum ada dokumentasi tersedia.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}

class _DokCard extends StatelessWidget {
  final HomeDokItemData item;

  const _DokCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material( // Material diperlukan agar InkWell berfungsi
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AREA GAMBAR DENGAN ASPECT RATIO TETAP
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                        : _buildPlaceholder(),
                  ),
                ),
              ),

              // AREA TEKS
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (item.dateText != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 10, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            item.dateText!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.image_not_supported_outlined,
          color: Colors.black12, size: 30),
    );
  }
}