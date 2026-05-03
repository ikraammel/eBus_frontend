import 'package:flutter/material.dart';

// Modèle principal du dashboard
class DashboardData {
  final DateTime timestamp;
  final int refreshInterval;
  final KPIsDTO kpis;
  final RealtimeOccupancyDTO realtimeOccupancy;
  final List<AlertDTO> alerts;
  final List<TopLineDTO> topLines;
  final List<EnergyConsumptionDTO> energyConsumption;

  DashboardData({
    required this.timestamp,
    required this.refreshInterval,
    required this.kpis,
    required this.realtimeOccupancy,
    required this.alerts,
    required this.topLines,
    required this.energyConsumption,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      refreshInterval: json['refreshInterval'] ?? 30,
      kpis: KPIsDTO.fromJson(json['kpis'] ?? {}),
      realtimeOccupancy: RealtimeOccupancyDTO.fromJson(json['realtimeOccupancy'] ?? {'labels': [], 'datasets': []}),
      alerts: json['alerts'] != null 
          ? (json['alerts'] as List).map((e) => AlertDTO.fromJson(e)).toList() 
          : [],
      topLines: json['topLines'] != null 
          ? (json['topLines'] as List).map((e) => TopLineDTO.fromJson(e)).toList() 
          : [],
      energyConsumption: json['energyConsumption'] != null 
          ? (json['energyConsumption'] as List).map((e) => EnergyConsumptionDTO.fromJson(e)).toList() 
          : [],
    );
  }
}

// KPIs Container
class KPIsDTO {
  final KPIItemDTO occupationRate;
  final KPIItemDTO punctualityRate;
  final KPIItemDTO dailyKilometers;
  final KPIItemDTO availabilityRate;
  final KPIItemDTO satisfactionScore;

  KPIsDTO({
    required this.occupationRate,
    required this.punctualityRate,
    required this.dailyKilometers,
    required this.availabilityRate,
    required this.satisfactionScore,
  });

  factory KPIsDTO.fromJson(Map<String, dynamic> json) {
    return KPIsDTO(
      occupationRate: KPIItemDTO.fromJson(json['occupationRate'] ?? {}),
      punctualityRate: KPIItemDTO.fromJson(json['punctualityRate'] ?? {}),
      dailyKilometers: KPIItemDTO.fromJson(json['dailyKilometers'] ?? {}),
      availabilityRate: KPIItemDTO.fromJson(json['availabilityRate'] ?? {}),
      satisfactionScore: KPIItemDTO.fromJson(json['satisfactionScore'] ?? {}),
    );
  }
}

// Item KPI individuel
class KPIItemDTO {
  final double value;
  final String trend;
  final String status;
  final double? threshold;
  final double? thresholdMin;
  final double? thresholdMax;
  final String? unit;

  KPIItemDTO({
    required this.value,
    required this.trend,
    required this.status,
    this.threshold,
    this.thresholdMin,
    this.thresholdMax,
    this.unit,
  });

  factory KPIItemDTO.fromJson(Map<String, dynamic> json) {
    return KPIItemDTO(
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend']?.toString() ?? '0',
      status: json['status'] ?? 'normal',
      threshold: json['threshold'] != null ? (json['threshold'] as num).toDouble() : null,
      thresholdMin: json['thresholdMin'] != null ? (json['thresholdMin'] as num).toDouble() : null,
      thresholdMax: json['thresholdMax'] != null ? (json['thresholdMax'] as num).toDouble() : null,
      unit: json['unit'],
    );
  }
}

// Données d'occupation en temps réel
class RealtimeOccupancyDTO {
  final List<String> labels;
  final List<OccupancyDatasetDTO> datasets;

  RealtimeOccupancyDTO({
    required this.labels,
    required this.datasets,
  });

  factory RealtimeOccupancyDTO.fromJson(Map<String, dynamic> json) {
    return RealtimeOccupancyDTO(
      labels: json['labels'] != null ? List<String>.from(json['labels']) : [],
      datasets: json['datasets'] != null 
          ? (json['datasets'] as List).map((e) => OccupancyDatasetDTO.fromJson(e)).toList() 
          : [],
    );
  }
}

// Dataset pour le graphique
class OccupancyDatasetDTO {
  final String label;
  final List<double> data;
  final String color;
  final int busCount;

  OccupancyDatasetDTO({
    required this.label,
    required this.data,
    required this.color,
    required this.busCount,
  });

  factory OccupancyDatasetDTO.fromJson(Map<String, dynamic> json) {
    return OccupancyDatasetDTO(
      label: json['label'] ?? '',
      data: json['data'] != null ? (json['data'] as List).map((e) => (e as num).toDouble()).toList() : [],
      color: json['color'] ?? '#000000',
      busCount: json['busCount'] ?? 0,
    );
  }
}

// Alerte
class AlertDTO {
  final String id;
  final String severity;
  final String busId;
  final String message;
  final DateTime timestamp;
  final String status;

  AlertDTO({
    required this.id,
    required this.severity,
    required this.busId,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  factory AlertDTO.fromJson(Map<String, dynamic> json) {
    return AlertDTO(
      id: json['id']?.toString() ?? '',
      severity: json['severity'] ?? 'low',
      busId: json['busId']?.toString() ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}

// Top Ligne
class TopLineDTO {
  final String line;
  final int riders;
  final double occupancy;

  TopLineDTO({
    required this.line,
    required this.riders,
    required this.occupancy,
  });

  factory TopLineDTO.fromJson(Map<String, dynamic> json) {
    return TopLineDTO(
      line: json['line'] ?? '',
      riders: json['riders'] ?? 0,
      occupancy: (json['occupancy'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// Consommation énergétique
class EnergyConsumptionDTO {
  final String type;
  final double percentage;
  final String color;

  EnergyConsumptionDTO({
    required this.type,
    required this.percentage,
    required this.color,
  });

  factory EnergyConsumptionDTO.fromJson(Map<String, dynamic> json) {
    return EnergyConsumptionDTO(
      type: json['type'] ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] ?? '#000000',
    );
  }
}
