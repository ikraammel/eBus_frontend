import '../../models/system_status.dart';
import '../../models/dashboard.dart';

abstract class DashboardState {}
class DashboardInitial extends DashboardState {}
class DashboardLoading extends DashboardState {}
class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final SystemStatus? systemStatus;

  DashboardLoaded(this.data,{this.systemStatus});
}
class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
