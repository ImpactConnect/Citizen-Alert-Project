import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/report_model.dart';
import '../../../providers/report_provider.dart';

class FilterSection extends StatefulWidget {
  const FilterSection({super.key});

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search reports...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    reportProvider.setSearchQuery(_searchController.text);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Filter Toggle
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
              label: const Text('Filters'),
            ),

            // Expandable Filter Section
            if (_showFilters) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ReportCategory?>(
                      value: reportProvider.selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...ReportCategory.values.map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.toString().split('.').last),
                          ),
                        ),
                      ],
                      onChanged: (value) => reportProvider.setCategory(value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<ReportStatus?>(
                      value: reportProvider.selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Status'),
                        ),
                        ...ReportStatus.values.map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toString().split('.').last),
                          ),
                        ),
                      ],
                      onChanged: (value) => reportProvider.setStatus(value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (reportProvider.selectedCategory != null ||
                  reportProvider.selectedStatus != null ||
                  reportProvider.searchQuery.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      reportProvider.clearFilters();
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
