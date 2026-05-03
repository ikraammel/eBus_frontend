import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';

class OccupancyLineChart extends StatelessWidget {
  final RealtimeOccupancyDTO data;

  const OccupancyLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blueGrey[700]),
                const SizedBox(width: 8),
                Text(
                  "Taux d'occupation des bus",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildLegend(),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}%'),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(data.labels[index], style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                  minX: 0,
                  maxX: data.labels.length > 0 ? (data.labels.length - 1).toDouble() : 0,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: data.datasets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dataset = entry.value;
                    return LineChartBarData(
                      spots: List.generate(dataset.data.length, (i) => FlSpot(i.toDouble(), dataset.data[i])),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: dataset.color.startsWith('#') 
                          ? Color(int.parse(dataset.color.substring(1), radix: 16) + 0xFF000000)
                          : Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: index == data.datasets.length - 1),
                      belowBarData: BarAreaData(
                        show: index == data.datasets.length - 1,
                        color: dataset.color.startsWith('#')
                            ? Color(int.parse(dataset.color.substring(1), radix: 16) + 0x20000000)
                            : Colors.blue.withValues(alpha: 0.2),
                      ),
                    );
                  }).toList(),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.x.toInt()}h\n${spot.y.toInt()}%',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Heures de pointe: 08:00 - 09:00 et 17:00 - 18:00',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Exporter'),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: data.datasets.map((dataset) {
        return Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                color: dataset.color.startsWith('#')
                    ? Color(int.parse(dataset.color.substring(1), radix: 16) + 0xFF000000)
                    : Colors.blue,
              ),
              const SizedBox(width: 4),
              Text(dataset.label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
