import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:teamleadapp/widgets/app_text_field_widget.dart';
import 'package:teamleadapp/widgets/filter_tab_widget.dart';
import '../cubit/lead_cubit.dart';
import '../cubit/theme_cubit.dart';
import '../models/lead_model.dart';
import '../theme/app_theme.dart';
import 'add_edit_lead_screen.dart';
import 'lead_detail_screen.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Mini Lead Manager',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => context.read<ThemeCubit>().toggle(),
            tooltip: 'Toggle theme',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      //body
      body: BlocListener<LeadCubit, LeadState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<LeadCubit>().clearError();
          }
        },

        //child
        child: Column(
          children: [
            //search field
            AppTextFieldWidget(
              searchCtrl: _searchCtrl,
              hintText: 'search lead ny name....',
              prefixIcon: Icons.search,
              onChanged: (v) => context.read<LeadCubit>().setSearchQuery(v),
            ),

            //filter tab
            FilterTabWidget(),


            const SizedBox(height: 6),

            Expanded(
              child: BlocBuilder<LeadCubit, LeadState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final leads = state.visibleLeads;
                  if (leads.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📋', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            'No leads yet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first lead',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withAlpha(153),
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeOutCubic,
                    child: ListView.separated(
                      key: ValueKey<int>(
                        leads.length +
                            state.filter.hashCode +
                            state.searchQuery.hashCode,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final cubit = context.read<LeadCubit>();
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LeadDetailScreen(leadId: lead.id),
                                  ),
                                );
                                if (!mounted) return;
                                cubit.loadLeads();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withAlpha(128)
                                          : AppTheme.avatarBg,
                                      child: Text(
                                        lead.name.isNotEmpty
                                            ? lead.name[0].toUpperCase()
                                            : '?',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lead.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            lead.phone,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withAlpha(179),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _statusBadge(context, lead.status),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: leads.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cubit = context.read<LeadCubit>();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditLeadScreen()),
          );
          if (!mounted) return;
          cubit.loadLeads();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Lead'),
        elevation: 4,
      ),
    );
  }


  Widget _statusBadge(BuildContext context, LeadStatus status) {
    Color color;
    String label;
    switch (status) {
      case LeadStatus.newLead:
        color = AppStatusColors.newLead;
        label = 'New';
        break;
      case LeadStatus.contacted:
        color = AppStatusColors.contacted;
        label = 'Contacted';
        break;
      case LeadStatus.converted:
        color = AppStatusColors.converted;
        label = 'Converted';
        break;
      case LeadStatus.lost:
        color = AppStatusColors.lost;
        label = 'Lost';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
