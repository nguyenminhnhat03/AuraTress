import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../config.dart';
import '../models/salon.dart';
import '../models/appointment.dart';
import 'mock_data_service.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        // Simple auto-retry x3 for transient errors
        final current = (error.requestOptions.extra['retry'] ?? 0) as int;
        if (current >= 3) return handler.next(error);
        error.requestOptions.extra['retry'] = current + 1;
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          final response = await _dio.fetch(error.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(error);
        }
      },
    ));
  }

  // Salons search with server-side filtering
  Future<List<Salon>> searchSalons(
    String location, {
    String? category,
    String? service, 
    double? maxDistanceKm,
  }) async {
    try {
      // For development, use mock data
      // In production, uncomment the API call below
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return MockDataService.searchSalons(
        location: location,
        category: category,
        service: service,
        maxDistanceKm: maxDistanceKm,
      );
      
      /*
      // Uncomment for real API calls:
      final queryParams = <String, dynamic>{
        'location': location,
      };
      
      // Add category filter (server-side filtering)
      if (category != null && category != 'all' && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      
      // Add service filter
      if (service != null && service != 'all' && service.isNotEmpty) {
        queryParams['service'] = service;
      }
      
      // Add distance filter (server-side filtering)
      if (maxDistanceKm != null && maxDistanceKm > 0) {
        queryParams['maxDistanceKm'] = maxDistanceKm;
      }
      
      final resp = await _dio.get('/salons', queryParameters: queryParams);
      final data = resp.data;
      if (data is List) {
        return data.map((e) => Salon.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('error.server'.tr());
      */
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('${'search.search_failed'.tr()}: $e');
    }
  }

  // User appointments
  Future<List<Appointment>> getAppointments(String userId) async {
    try {
      final resp = await _dio.get('/users/$userId/appointments');
      final data = resp.data;
      if (data is List) {
        return data.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
      }
      return const [];
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message']
          : e.message;
      throw Exception('${'appointment.booking_failed'.tr()}: $msg');
    }
  }

  // Create appointment
  Future<String> bookAppointment(String userId, String salonId, String service, DateTime date) async {
    try {
      final resp = await _dio.post(
        '/appointments',
        data: {
          'userId': userId,
          'salonId': salonId,
          'service': service,
          'date': date.toIso8601String(),
        },
      );
      final data = resp.data;
      if (data is Map && data['id'] != null) {
        return data['id'].toString();
      }
      // Fallback: try Location header or generate local fallback
      return data?.toString() ?? 'new_appointment_id_${DateTime.now().millisecondsSinceEpoch}';
    } on DioException catch (e) {
      final msg = e.response?.data is Map && (e.response?.data['message'] != null)
          ? e.response?.data['message']
          : e.message;
      throw Exception('${'appointment.booking_failed'.tr()}: $msg');
    }
  }
}
