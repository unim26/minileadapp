part of 'lead_cubit.dart';

class LeadState extends Equatable {
  final List<LeadModel> leads;
  final LeadStatus? filter; // null = all
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const LeadState({
    required this.leads,
    this.filter,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  factory LeadState.initial() => const LeadState(leads: []);

  //copywith method
  LeadState copyWith({
    List<LeadModel>? leads,
    LeadStatus? filter,
    bool clearFilter = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LeadState(
      leads: leads ?? this.leads,
      filter: clearFilter ? null : (filter ?? this.filter),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  //get visible leads
  List<LeadModel> get visibleLeads {
    var filtered = leads;
    if (filter != null) {
      filtered = filtered.where((l) => l.status == filter).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (l) => l.name.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  @override
  List<Object?> get props => [
    leads,
    filter,
    searchQuery,
    isLoading,
    errorMessage,
  ];
}
