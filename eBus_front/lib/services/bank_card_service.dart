import 'package:dio/dio.dart';
import 'package:smart_bus/models/bank_card.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

class BankCardService {
  final Dio _dio = DioClient.dio;


  Future<List<BankCard>> getCards(int userId) async {
    try {
      final res = await _dio.get('/cards/user/$userId');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).map((e) => BankCard.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Erreur réseau');
    }
  }


  Future<BankCard> addCard(BankCard card) async {
    try {
      final res = await _dio.post('/cards', data: card.toJson());
      return BankCard.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Erreur lors de l\'ajout');
    }
  }


  Future<BankCard> updateCard(int id, BankCard card) async {
    try {
      final res = await _dio.put('/cards/$id', data: card.toJson());
      return BankCard.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Erreur lors de la mise à jour');
    }
  }


  Future<void> setMain(int id) async {
    try {
      await _dio.patch('/cards/$id/set-main');
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Erreur');
    }
  }


  Future<void> deleteCard(int id) async {
    try {
      await _dio.delete('/cards/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? 'Erreur lors de la suppression');
    }
  }
}
