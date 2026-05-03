import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_bus/constants/constants.dart';
import '../models/dashboard_model.dart';

// Events
abstract class DashboardEvent {}
class LoadDashboard extends DashboardEvent {}
class RefreshDashboard extends DashboardEvent {}

// States
abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final DashboardData data;
  DashboardLoaded(this.data);
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // On s'assure que Dio utilise la baseUrl des constantes
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<RefreshDashboard>(_onRefresh);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      debugPrint("Tentative de connexion au Dashboard: ${AppConstants.baseUrl}/admin/dashboard");
      final response = await _dio.get('/admin/dashboard');
      
      if (response.statusCode == 200) {
        final dashboardData = DashboardData.fromJson(response.data);
        emit(DashboardLoaded(dashboardData));
      } else {
        emit(DashboardError('Erreur serveur: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      debugPrint("Erreur Dio Dashboard: ${e.message}");
      String errorMsg = 'Impossible de contacter le serveur';
      if (e.type == DioExceptionType.connectionTimeout) errorMsg = 'Délai de connexion dépassé';
      if (e.response?.statusCode == 404) errorMsg = 'Service statistiques introuvable (404)';
      
      emit(DashboardError(errorMsg));
    } catch (e) {
      debugPrint("Erreur Parsing Dashboard: $e");
      emit(DashboardError('Erreur de traitement des données statistiques'));
    }
  }

  Future<void> _onRefresh(RefreshDashboard event, Emitter<DashboardState> emit) async {
    try {
      final response = await _dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        final dashboardData = DashboardData.fromJson(response.data);
        emit(DashboardLoaded(dashboardData));
      }
    } catch (e) {
      // On garde l'ancien état en cas d'erreur de rafraîchissement
      debugPrint("Erreur Refresh Dashboard: $e");
    }
  }
}
