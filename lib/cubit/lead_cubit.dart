import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/lead_model.dart';
import '../services/lead_storage.dart';

part 'lead_state.dart';

class LeadCubit extends Cubit<LeadState> {
  final LeadStorage storage;

  LeadCubit({required this.storage}) : super(LeadState.initial()) {
    loadLeads();
  }

  //load leads function
  Future<void> loadLeads() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final leads = storage.getAllLeads();
      emit(state.copyWith(leads: leads, isLoading: false, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  //add lead function
  Future<void> addLead(LeadModel lead) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await storage.addLead(lead);
      await loadLeads();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

   //update lead function
  Future<void> updateLead(LeadModel lead) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await storage.updateLead(lead);
      await loadLeads();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

   //delete lead function
  Future<void> deleteLead(int id) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await storage.deleteLead(id);
      await loadLeads();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  //clear error function
  void clearError() {
    if (state.errorMessage != null) emit(state.copyWith(errorMessage: null));
  }

  //set filter function
  void setFilter(LeadStatus? status) {
    if (status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(filter: status));
    }
  }

  //set search query function
  void setSearchQuery(String q) {
    emit(state.copyWith(searchQuery: q));
  }
}
