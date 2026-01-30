// lib/features/home/widgets/home_event_list.dart
import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF641515);

/// Data satu item event di home.
class HomeEventItemData {
  final String id;
  final String title;
  final String? dateText; // contoh: "03 Agu 2025"
  final String? location; // contoh: "AULA - A"
  final String? description; // teks pendek (sekarang tidak dipakai di UI)
  final bool isJoined;
  final String? imageUrl; // poster event
  final VoidCallback? onTap;

  const HomeEventItemData({
    required this.id,
    required this.title,
    this.dateText,
    this.location,
    this.description,
    this.isJoined = false,
    this.imageUrl,
    this.onTap,
  });
}

/// Section "Event di Home":
/// - Search bar
/// - Grid 2 kolom berisi kartu event
class HomeEventList extends StatelessWidget {
  final List<HomeEventItemData> events;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  const HomeEventList({
    super.key,
    required this.events,
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
          // SEARCH BAR "Pencarian Event"
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Pencarian Event',
              prefixIcon: const Icon(Icons.search),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (events.isEmpty)
            Text(
              'Belum ada event yang tersedia.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.disabledColor),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 4 / 3,
              ),
              itemBuilder: (context, index) {
                final data = events[index];
                return _EventCard(data: data);
              },
            ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final HomeEventItemData data;

  const _EventCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = data.location != null && data.location!.isNotEmpty;

    return InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // BACKGROUND IMAGE
              if (data.imageUrl != null && data.imageUrl!.isNotEmpty)
                Image.network(
                  data.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),

              // BADGE LOKASI DI POJOK KANAN ATAS
              if (hasLocation)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data.location!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // bottom overlay: HANYA JUDUL
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                  child: Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
