import 'package:dio/dio.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';
import '../models/type_abonnement.dart';

class TypeAbonnementService {
  final Dio _dio = DioClient.dio;

  // 📥 GET ALL
  Future<List<TypeAbonnement>> getAll() async {
    final res = await _dio.get('/types-abonnement');
    return (res.data as List)
        .map((e) => TypeAbonnement.fromJson(e))
        .toList();
  }

  // ➕ CREATE (ADMIN)
  Future<void> create(TypeAbonnement t) async {
    final data = t.toJson();
    data.remove('id');
    await _dio.post('/types-abonnement', data: data);
  }

  // ✏️ UPDATE (ADMIN)
  Future<void> update(TypeAbonnement t) async {
    await _dio.put('/types-abonnement/${t.id}', data: t.toJson());
  }

  // ❌ DELETE (ADMIN)
  Future<void> delete(int id) async {
    await _dio.delete('/types-abonnement/$id');
  }
}
