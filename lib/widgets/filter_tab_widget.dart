import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamleadapp/cubit/lead_cubit.dart';
import 'package:teamleadapp/models/lead_model.dart';

class FilterTabWidget extends StatelessWidget {
  FilterTabWidget({super.key});

  //filter types
  final List<Map<String, dynamic>> filterType = [
    {'label': 'All', 'status': null, 'icon': Icons.grid_view},
    {
      'label': 'New',
      'status': LeadStatus.newLead,
      'icon': Icons.new_releases_outlined,
    },
    {
      'label': 'Contacted',
      'status': LeadStatus.contacted,
      'icon': Icons.phone_outlined,
    },
    {
      'label': 'Converted',
      'status': LeadStatus.converted,
      'icon': Icons.check_circle_outline,
    },
    {'label': 'Lost', 'status': LeadStatus.lost, 'icon': Icons.cancel_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => _buildFilterChip(
          context,
          filterType[index]['status'],
          filterType[index]['label'],
          filterType[index]['icon'],
        ),
      ),
    );
  }

  //build filter chip
  Widget _buildFilterChip(
    BuildContext context,
    LeadStatus? status,
    String label,
    IconData icon,
  ) {
    final current = context.select((LeadCubit c) => c.state.filter);
    final isSelected = current == status;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withAlpha(153),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) {
          context.read<LeadCubit>().setFilter(isSelected ? null : status);
        },
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
        elevation: isSelected ? 3 : 0,
        shadowColor: Theme.of(context).colorScheme.primary.withAlpha(76),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
