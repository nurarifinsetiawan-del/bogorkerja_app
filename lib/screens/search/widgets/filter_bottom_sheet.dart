import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/taxonomy_provider.dart';
import '../../../repository/job_repository.dart';
import '../../../theme/app_colors.dart';

const _employmentTypes = [
  ('FULL_TIME', 'Penuh Waktu'),
  ('PART_TIME', 'Paruh Waktu'),
  ('CONTRACT', 'Kontrak'),
  ('INTERNSHIP', 'Magang'),
  ('FREELANCE', 'Freelance'),
];

const _educationLevels = [
  'SD', 'SMP', 'SMA/SMK', 'D3', 'S1', 'S2',
];

/// Bottom sheet filter lengkap — dipanggil dari tombol filter di
/// SearchScreen. Mengembalikan [JobFilter] baru lewat Navigator.pop.
class FilterBottomSheet extends ConsumerStatefulWidget {
  final JobFilter initialFilter;

  const FilterBottomSheet({super.key, required this.initialFilter});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late JobFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    final professionsAsync = ref.watch(professionsProvider);
    final citiesAsync = ref.watch(citiesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Filter Pencarian', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _draft = const JobFilter()),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _FilterSectionTitle('Urutkan'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _choiceChip('Terbaru', _draft.sort == 'latest',
                          () => setState(() => _draft = _draft.copyWith(sort: 'latest'))),
                      _choiceChip('Terpopuler', _draft.sort == 'popular',
                          () => setState(() => _draft = _draft.copyWith(sort: 'popular'))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FilterSectionTitle('Kota'),
                  citiesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Gagal memuat data kota'),
                    data: (cities) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cities.map((c) {
                        return _choiceChip(
                          c.label,
                          _draft.city == c.label,
                          () => setState(() => _draft = _draft.copyWith(
                                city: _draft.city == c.label ? null : c.label,
                              )),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FilterSectionTitle('Profesi'),
                  professionsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Gagal memuat data profesi'),
                    data: (professions) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: professions.map((p) {
                        return _choiceChip(
                          p.label,
                          _draft.profession == p.slug,
                          () => setState(() => _draft = _draft.copyWith(
                                profession: _draft.profession == p.slug ? null : p.slug,
                              )),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _FilterSectionTitle('Tipe Pekerjaan'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _employmentTypes.map((e) {
                      return _choiceChip(
                        e.$2,
                        _draft.employmentType == e.$1,
                        () => setState(() => _draft = _draft.copyWith(
                              employmentType: _draft.employmentType == e.$1 ? null : e.$1,
                            )),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  _FilterSectionTitle('Pendidikan Minimal'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _educationLevels.map((e) {
                      return _choiceChip(
                        e,
                        _draft.education == e,
                        () => setState(() => _draft = _draft.copyWith(
                              education: _draft.education == e ? null : e,
                            )),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_draft),
                    child: const Text('Terapkan Filter'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  final String text;
  const _FilterSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
