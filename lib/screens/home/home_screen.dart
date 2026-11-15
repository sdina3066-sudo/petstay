import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routes/app_routes.dart';
import '../../data/models/pet.dart';
import '../../providers/sitter_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/sitter_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<SitterProvider>().query,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilters(SitterProvider provider) async {
    double maximumPrice = (provider.maximumPrice ?? 75000).toDouble();
    double minimumRating = provider.minimumRating;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter penitip',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    Text('Harga maksimum: Rp ${maximumPrice.round()} / hari'),
                    Slider(
                      value: maximumPrice,
                      min: 25000,
                      max: 75000,
                      divisions: 10,
                      label: 'Rp ${maximumPrice.round()}',
                      onChanged: (double value) =>
                          setSheetState(() => maximumPrice = value),
                    ),
                    const SizedBox(height: 8),
                    Text('Rating minimum: ${minimumRating.toStringAsFixed(1)}'),
                    Slider(
                      value: minimumRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: minimumRating.toStringAsFixed(1),
                      onChanged: (double value) =>
                          setSheetState(() => minimumRating = value),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            provider.resetFilter();
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Atur ulang'),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            provider.setMaximumPrice(
                              maximumPrice >= 75000
                                  ? null
                                  : maximumPrice.round(),
                            );
                            provider.setMinimumRating(minimumRating);
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Terapkan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SitterProvider>(
      builder: (BuildContext context, SitterProvider provider, Widget? child) {
        return RefreshIndicator(
          onRefresh: provider.retry,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              Text(
                'Titipkan dengan tenang',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Temukan penitip hewan terpercaya di Batam.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                onChanged: provider.setQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari nama, lokasi, atau jenis hewan',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: () {
                            _searchController.clear();
                            provider.setQuery('');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _typeChip(provider, null, 'Semua'),
                    ...PetType.values.map(
                      (PetType type) => _typeChip(provider, type, type.label),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _showFilters(provider),
                  icon: const Icon(Icons.tune),
                  label: const Text('Harga & rating'),
                ),
              ),
              const SizedBox(height: 14),
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null)
                ErrorState(
                  message: provider.errorMessage!,
                  onRetry: provider.retry,
                )
              else if (provider.filteredSitters.isEmpty)
                const EmptyState(
                  title: 'Penitip tidak ditemukan',
                  message: 'Coba ubah kata pencarian atau sesuaikan filter yang dipilih.',
                  icon: Icons.search_off,
                )
              else ...[
                Text(
                  '${provider.filteredSitters.length} penitip tersedia',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                ...provider.filteredSitters.map(
                  (sitter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SitterCard(
                      sitter: sitter,
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.sitterDetail, arguments: sitter.id),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _typeChip(SitterProvider provider, PetType? type, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: provider.petTypeFilter == type,
        onSelected: (_) => provider.setPetTypeFilter(type),
      ),
    );
  }
}
