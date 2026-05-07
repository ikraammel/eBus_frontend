import 'package:dio/dio.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/models/activity.dart';

class ActivityService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<List<Activity>> getRecentActivities(int userId) async{
    try{
      final response = await _dio.get('/activities/$userId');
      if(response.statusCode == 200){
        List data;
        if(response.data is List){
          data = response.data;
        }else if(response.data is Map && response.data['data'] != null){
          data = response.data['data'];
        }else{
          data = [];
        }
        return data.map((e) => Activity.fromJson(e)).toList();
      }return [];
    } catch (e) {
      print("ACTIVITY ERROR FULL: $e");
      return [];
    }
  }

  Future<List<Activity>> getRecentActivitiesAdmin() async{
    try{
      print("BASE URL: ${AppConstants.baseUrl}");
      final response = await _dio.get('/activities/admin/recent');
      if(response.statusCode == 200){
        List data;
        if(response.data is List){
          data = response.data;
        }else if(response.data is Map && response.data['data'] != null){
          data = response.data['data'];
        }else{
          data = [];
        }
        return data.map((e) => Activity.fromJson(e)).toList();
      }return [];
    } catch (e) {
      print("ACTIVITY ERROR FULL: $e");
      return [];
    }
  }
}