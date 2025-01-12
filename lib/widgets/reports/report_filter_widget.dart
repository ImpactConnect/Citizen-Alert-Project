import 'package:flutter/material.dart';
import '../../models/report_model.dart';

class ReportFilterWidget extends StatelessWidget {
  final ReportCategory? selectedCategory;
  final ReportStatus? selectedStatus;
  final Function(ReportCategory?) onCategoryChanged;
  final Function(ReportStatus?) onStatusChanged;

  const ReportFilterWidget({
    super.key,
    this.selectedCategory,
    this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ReportCategory?>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...ReportCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }),
                    ],
                    onChanged: onCategoryChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<ReportStatus?>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...ReportStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.toString().split('.').last),
                        );
                      }),
                    ],
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
