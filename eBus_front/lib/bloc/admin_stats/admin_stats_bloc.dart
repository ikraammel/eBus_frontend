import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

import '../../models/admin_stats.dart';
import 'admin_stats_event.dart';
import 'admin_stats_state.dart';

class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  final Dio _dio = DioClient.dio;

  AdminStatsBloc() : super(AdminStatsInitial()) {
    on<LoadAdminStats>(_onLoad);
  }

  Future<void> _onLoad(LoadAdminStats event, Emitter<AdminStatsState> emit) async {
    emit(AdminStatsLoading());
    try {
      final response = await _dio.get('/admin/stats');
      if (response.statusCode == 200) {
        final stats = AdminStatsModel.fromJson(response.data as Map<String, dynamic>);
        emit(AdminStatsLoaded(stats));
      } else {
        emit(AdminStatsError('Erreur serveur: ${response.statusCode}'));
      }
    } catch (e) {
      debugPrint('AdminStatsBloc error: $e');
      emit(AdminStatsError('Impossible de charger les statistiques'));
    }
  }
}