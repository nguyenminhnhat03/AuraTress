import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../models/appointment.dart';
import 'auth_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final appointmentProvider = AsyncNotifierProvider<AppointmentNotifier, List<Appointment>>(
  AppointmentNotifier.new,
);

class AppointmentNotifier extends AsyncNotifier<List<Appointment>> {
  late final ApiService apiService;
  late final DatabaseService databaseService;
  late final String userId;

  @override
  Future<List<Appointment>> build() async {
    // Get the userId from the provider parameter - this might need adjustment
    // For now, return empty list as placeholder
    apiService = ref.watch(apiServiceProvider);
    databaseService = ref.watch(databaseServiceProvider);
    return [];
  }

  Future<void> loadAppointments(String userId) async {
    this.userId = userId;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await databaseService.getUserAppointments(userId));
  }

  Future<String?> book(String userId, String salonId, String salonName, String service, DateTime date, {String? timeSlot}) async {
    try {
      final newId = await databaseService.createAppointment(
        userId: userId,
        salonId: salonId,
        salonName: salonName,
        service: service,
        appointmentDate: date,
        timeSlot: timeSlot,
      );
      await loadAppointments(userId);
      return newId;
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
      return null;
    }
  }
}
