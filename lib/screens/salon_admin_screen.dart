// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/appointment.dart';
import '../widgets/top_navbar.dart';
import '../theme.dart';

class SalonAdminScreen extends ConsumerStatefulWidget {
  final String salonId;
  const SalonAdminScreen({super.key, required this.salonId});

  @override
  ConsumerState<SalonAdminScreen> createState() => _SalonAdminScreenState();
}

class _SalonAdminScreenState extends ConsumerState<SalonAdminScreen> {
  final DatabaseService _db = DatabaseService();
  late Future<List<Appointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = _db.getSalonAppointments(widget.salonId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _db.getSalonAppointments(widget.salonId);
    });
  }

  Future<void> _updateStatus(Appointment appt, String status) async {
    await _db.updateAppointmentStatus(appt.id, status);
    await _refresh();
  }

  Future<void> _reschedule(Appointment appt) async {
    final newDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: appt.date,
    );
    if (newDate != null) {
      await _db.updateAppointmentSchedule(appt.id, newDate, appt.timeSlot);
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavbar(activeIndex: 0),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Appointment>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final appt = data[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${appt.salonName} - ${appt.service}', style: Theme.of(context).textTheme.bodyLarge),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(appt.status, style: Theme.of(context).textTheme.labelSmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('User: ${appt.userId}', style: Theme.of(context).textTheme.bodySmall),
                      Text('Date: ${appt.date.toLocal().toString().substring(0, 16)} (${appt.timeSlot})', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _updateStatus(appt, 'completed'),
                            icon: const Icon(Icons.check),
                            label: Text('Mark completed'.tr()),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _updateStatus(appt, 'no_show'),
                            icon: const Icon(Icons.person_off),
                            label: Text('No-show'.tr()),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _reschedule(appt),
                            icon: const Icon(Icons.schedule),
                            label: Text('Reschedule'.tr()),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final ctx = context;
          _db.getSalonTransactions(widget.salonId).then((txns) {
            if (!mounted) return;
            showDialog(
              context: ctx,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF1B1033),
                title: Text('Transactions'.tr(), style: const TextStyle(color: Colors.white)),
                content: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: txns.map((t) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '${t['created_at']} - ${t['type']}: ${t['details']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),
            );
          });
        },
        child: const Icon(Icons.receipt_long),
      ),
    );
  }
}
