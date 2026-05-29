import 'package:dio/dio.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

import '../models/bus.dart';

class BusService {
  final Dio _dio = DioClient.dio;

  Future<Bus> createBus(Bus bus) async {
    final response = await _dio.post('/bus/new', data: bus.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Bus.fromJson(Map<String, dynamic>.from(response.data));
    }
    throw Exception("Erreur creation bus: ${response.data}");
  }

  Future<Bus> updateBus(int id, Bus bus) async {
    final response = await _dio.patch('/bus/$id', data: bus.toJson());
    if (response.statusCode == 200) {
      return Bus.fromJson(Map<String, dynamic>.from(response.data));
    }
    throw Exception("Erreur modification bus: ${response.data}");
  }

  Future<void> deleteBus(int id) async {
    final response = await _dio.delete('/bus/$id');
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception("Erreur suppression bus");
  }

  Future<List<Bus>> getAllBus() async {
    final response = await _dio.get('/bus');
    if (response.statusCode == 200) {
      return _parseBusList(response.data);
    }
    throw Exception("Erreur chargement bus");
  }

  Future<Bus> getBusById(int id) async {
    final response = await _dio.get('/bus/$id');
    if (response.statusCode == 200 && response.data is Map) {
      return Bus.fromJson(Map<String, dynamic>.from(response.data));
    }
    throw Exception("Bus introuvable");
  }

  Future<Bus> getBusByImmatriculation(String immatriculation) async {
    final encoded = Uri.encodeComponent(immatriculation);
    final response = await _dio.get('/bus/immatriculation/$encoded');
    if (response.statusCode == 200 && response.data is Map) {
      return Bus.fromJson(Map<String, dynamic>.from(response.data));
    }
    throw Exception("Bus introuvable");
  }

  Future<List<Bus>> getBusesByLigne(int ligneId) async {
    final response = await _dio.get('/bus/ligne/$ligneId');
    if (response.statusCode == 200) {
      return _parseBusList(response.data);
    }
    throw Exception("Erreur chargement bus par ligne");
  }

  List<Bus> _parseBusList(dynamic payload) {
    final data = _extractList(payload);
    return data
        .whereType<Map>()
        .map((e) => Bus.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map) {
      for (final key in ['bus', 'buses', 'data', 'content', 'items', 'results']) {
        final value = payload[key];
        if (value is List) return value;
      }
    }
    return [];
  }
}
