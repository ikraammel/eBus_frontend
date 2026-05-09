import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

import '../../models/system_status.dart';
import '../../models/dashboard.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  SystemStatus? systemStatus;

  final Dio _dio = DioClient.dio;

  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<RefreshDashboard>(_onRefresh);
  }

  Future<void> _onLoad(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());

    try {
      final dashboardResponse = await _dio.get('/admin/dashboard');
      final systemResponse = await _dio.get('/admin/system-status');

      final dashboardData = DashboardData.fromJson(dashboardResponse.data);
      final systemStatus = SystemStatus.fromJson(systemResponse.data);

      emit(DashboardLoaded(
        dashboardData,
        systemStatus: systemStatus,
      ));
    } catch (e) {
      emit(DashboardError("Erreur chargement dashboard"));
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

  Future<void> _loadSystemStatus() async {
    try {
      final response = await _dio.get('/admin/system-status');
      systemStatus = SystemStatus.fromJson(response.data);
    } catch (e) {
      systemStatus = null;
      debugPrint("System status error: $e");
    }
  }
}
