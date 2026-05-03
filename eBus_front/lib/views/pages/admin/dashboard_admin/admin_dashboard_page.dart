import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bus/bloc/dashboard_bloc.dart';
import 'package:smart_bus/models/dashboard_model.dart';
import 'package:smart_bus/utils/app_snack_bar.dart';
import 'package:smart_bus/widgets/occupancy_line_chart.dart';
import 'package:smart_bus/views/UI/splash_screen.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: BlocProvider(
        create: (context) => DashboardBloc()..add(LoadDashboard()),
        child: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError) {
              AppSnackBar.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const SplashScreen();
            }
            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboard());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKPISection(state.data.kpis),
                      const SizedBox(height: 24),
                      _buildResponsiveSection(
                        context,
                        child1: OccupancyLineChart(data: state.data.realtimeOccupancy),
                        child2: _buildAlertsCard(context, state.data.alerts),
                        flex1: 2,
                        flex2: 1,
                      ),
                      const SizedBox(height: 24),
                      _buildResponsiveSection(
                        context,
                        child1: _buildTopLinesCard(context, state.data.topLines),
                        child2: _buildEnergyCard(context, state.data.energyConsumption),
                        flex1: 1,
                        flex2: 1,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text("Une erreur est survenue lors de l'affichage du dashboard"));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF1A1F26),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        _buildDateTimeWidget(),
        const SizedBox(width: 16),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildDateTimeWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 14),
          const SizedBox(width: 8),
          Text(
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildKPISection(KPIsDTO kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _KPIWidget(title: 'Occupation', item: kpis.occupationRate, unit: '%', icon: Icons.people),
            _KPIWidget(title: 'Ponctualité', item: kpis.punctualityRate, unit: '%', icon: Icons.timer),
            _KPIWidget(title: 'Distance', item: kpis.dailyKilometers, unit: 'km', icon: Icons.route),
            _KPIWidget(title: 'Disponibilité', item: kpis.availabilityRate, unit: '%', icon: Icons.bus_alert),
            _KPIWidget(title: 'Satisfaction', item: kpis.satisfactionScore, unit: '/5', icon: Icons.star_border),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveSection(BuildContext context, {required Widget child1, required Widget child2, int flex1 = 1, int flex2 = 1}) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    if (isMobile) {
      return Column(
        children: [
          child1,
          const SizedBox(height: 24),
          child2,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: flex1, child: child1),
        const SizedBox(width: 24),
        Expanded(flex: flex2, child: child2),
      ],
    );
  }

  Widget _buildAlertsCard(BuildContext context, List<AlertDTO> alerts) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Alertes Actives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (alerts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                    child: Text('${alerts.length}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('Aucune alerte à signaler', style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length > 5 ? 5 : alerts.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Row(
                    children: [
                      Icon(
                        alert.severity == 'high' ? Icons.error : Icons.warning_amber,
                        color: alert.severity == 'high' ? Colors.red : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alert.message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Bus ${alert.busId} • ${_formatTimeAgo(alert.timestamp)}', 
                                style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLinesCard(BuildContext context, List<TopLineDTO> lines) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lignes Fréquentées', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...lines.take(4).map((line) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text(line.line, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${line.riders} passagers', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Text('${line.occupancy.toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: line.occupancy / 100,
                              backgroundColor: Colors.grey[200],
                              color: line.occupancy > 80 ? Colors.red : Colors.blue,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyCard(BuildContext context, List<EnergyConsumptionDTO> energy) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Énergie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...energy.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _hexToColor(e.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(e.type, style: const TextStyle(fontSize: 14))),
                  Text('${e.percentage.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blueGrey;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'le ${timestamp.day}/${timestamp.month}';
  }
}

class _KPIWidget extends StatelessWidget {
  final String title;
  final KPIItemDTO item;
  final String unit;
  final IconData icon;

  const _KPIWidget({required this.title, required this.item, required this.unit, required this.icon});

  @override
  Widget build(BuildContext context) {
    final bool isPositive = !item.trend.contains('-');
    final Color trendColor = isPositive ? Colors.green : Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: Colors.blueGrey[400]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: trendColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(item.trend, style: TextStyle(fontSize: 10, color: trendColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.value.toStringAsFixed(item.value % 1 == 0 ? 0 : 1)}$unit',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
