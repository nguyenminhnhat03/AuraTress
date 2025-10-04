import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/salon.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final salonProvider = AsyncNotifierProvider<SalonNotifier, List<Salon>>(
  () => SalonNotifier(),
);

class SalonNotifier extends AsyncNotifier<List<Salon>> {
  late final ApiService apiService;

  @override
  Future<List<Salon>> build() async {
    apiService = ref.watch(apiServiceProvider);
    return [];
  }

  Future<void> search(
    String location, {
    String? category,
    String? service, 
    double? maxDistanceKm,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await apiService.searchSalons(
      location, 
      category: category,
      service: service, 
      maxDistanceKm: maxDistanceKm,
    ));
  }
}
