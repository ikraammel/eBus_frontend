import 'package:dio/dio.dart';

import '../constants/constants.dart';
import '../models/Ligne.dart';

class LigneService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<List<Ligne>> getLignes() async {
      final response = await _dio.get('/lignes');
      if(response.statusCode == 200){
        List data = response.data;
        return data.map((e) => Ligne.fromJson(e)).toList();
      }else{
        throw Exception("Erreur chargement lignes");
      }
  }
}