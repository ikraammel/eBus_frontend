import 'package:dio/dio.dart';

import '../constants/constants.dart';
import '../models/Bus.dart';

class BusService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<Bus> createBus(Bus bus) async {
    final response = await _dio.post('/bus/new', data: bus.toJson());
    if (response.statusCode == 200) {
      return Bus.fromJson(response.data);
    } else {
      throw Exception("Erreur création bus: ${response.data}");
    }
  }

  Future<Bus> updateBus(int id,Bus bus) async {
    final response = await _dio.patch('/bus/$id', data: bus.toJson());
    if (response.statusCode == 200) {
      return Bus.fromJson(response.data);
    } else {
      throw Exception("Erreur modification bus: ${response.data}");
    }
  }

  Future<void> deleteBus(int id) async {
    final response = await _dio.delete('/bus/$id');
    if (response.statusCode == 200 || response.statusCode == 204) {
      print("Bus supprimé avec succès");
    }else{
      throw Exception("Erreur suppression bus");
    }
  }

  Future<List<Bus>> getAllBus() async {
    final response = await _dio.get('/bus');

    if (response.statusCode == 200) {
      List data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data['bus'] != null) {
        data = response.data['bus'];
      } else {
        data = [];
      }
      return data.map((e) => Bus.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement bus");
    }
  }

}