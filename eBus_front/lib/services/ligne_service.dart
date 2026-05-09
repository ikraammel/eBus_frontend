import 'package:dio/dio.dart';
import 'package:smart_bus/models/station.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

import '../models/ligne.dart';

class LigneService {
  final Dio _dio = DioClient.dio;

  Future<List<Ligne>> getLignes() async {
    final response = await _dio.get('/lignes');
    print("Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      List data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data['lignes'] != null) {
        data = response.data['lignes'];
      } else {
        data = [];
      }
      return data.map((e) => Ligne.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement lignes");
    }
  }

  Future<Ligne> createLine(Ligne ligne) async {
    final response = await _dio.post('/lignes/new', data: ligne.toJson());
    if(response.statusCode == 200){
      return Ligne.fromJson(response.data);
    }else{
      throw Exception("Erreur création ligne: ${response.data}");
    }
  }

  Future<Ligne> updateLine(int id,Map<String, dynamic> patch) async {
    final response = await _dio.patch('/lignes/$id', data: patch);
    if(response.statusCode == 200){
      return Ligne.fromJson(response.data);
    }else{
      throw Exception("Erreur modification ligne: ${response.data}");
    }
  }

  Future<void> deleteLine(int id) async{
    final response = await _dio.delete('/lignes/$id');
    if(response.statusCode == 200 || response.statusCode == 204){
      print("Ligne supprimée avec succès");
    }else{
      throw Exception("Erreur suppression ligne");
    }
  }

  Future<Station> addStation(Station station,int ligneId) async {
    final response = await _dio.post(
        '/lignes/station/new/${ligneId}',
        data: station.toJson()
    );
    if(response.statusCode == 200){
      return Station.fromJson(response.data);
    }else{
      throw Exception("Erreur création station: ${response.data}");
    }
  }

  Future<Station> updateStation(Station station,int ligneId,int stationId) async {
    final response = await _dio.patch(
        '/lignes/ligne/${ligneId}/station/${stationId}',
        data: station.toJson()
    );
    if(response.statusCode == 200){
      return Station.fromJson(response.data);
    }else{
      throw Exception("Erreur lors de la mise à jour de la station: ${response.data}");
    }
  }

  Future<void> deleteStation(int ligneId,int stationId) async{
    final response = await _dio.delete('/lignes/ligne/${ligneId}/station/${stationId}');
    if(response.statusCode == 200 || response.statusCode == 204){
      print("Station supprimée avec succès");
    }else{
      throw Exception("Erreur suppression station");
    }
  }
  }