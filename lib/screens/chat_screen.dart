import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../widgets/top_navbar.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../services/database_service.dart';
import '../theme.dart';
import '../services/mock_data_service.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final AiService _aiService = AiService();
  final List<Map<String, dynamic>> _messages = [];
  final _controller = TextEditingController();

  Future<void> _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;
    setState(() => _messages.add({'text': query, 'isUser': true}));
    _controller.clear();
    try {
      final user = ref.read(authProvider).value;

      // Natural-language intent parsing (VN + EN)
      final parsed = _parseIntentFlexible(query);

      if (user != null && parsed['intent'] == 'book') {
        final userId = user.id;
        final salon = parsed['salon'] as Map<String, String?>?;
        final salonId = salon?['id'] ?? 'salon_lehieu_006';
        final salonName = salon?['name'] ?? 'Le Hieu Salon';
        final service = parsed['service'] as String? ?? 'Premium Cut & Style';
        final dt = parsed['datetime'] as DateTime?;
        final timeSlot = parsed['timeSlot'] as String?;

        if (dt == null || timeSlot == null) {
          setState(() => _messages.add({'text': 'Thiếu ngày/giờ. Ví dụ: "Đặt lịch cắt tóc ngày 20/10/2025 lúc 14:30"', 'isUser': false}));
        } else {
          final id = await ref.read(appointmentProvider.notifier)
              .book(userId, salonId, salonName, service, dt, timeSlot: timeSlot);
          if (mounted) {
            final dateLabel = DateFormat('HH:mm dd/MM/yyyy').format(dt);
            final ok = id != null;
            setState(() => _messages.add({'text': ok ? 'Đã đặt lịch: $salonName, dịch vụ $service, vào $dateLabel (Mã: $id)' : 'Đặt lịch thất bại', 'isUser': false}));
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã đặt $service tại $salonName vào $dateLabel')),
              );
            }
          }
        }
      } else if (parsed['intent'] == 'cancel') {
        final apptId = parsed['appointmentId'] as String?;
        if (apptId == null) {
          setState(() => _messages.add({'text': 'Thiếu mã lịch để hủy. Ví dụ: "Hủy lịch appointment_001"', 'isUser': false}));
        } else {
          await DatabaseService().cancelAppointment(apptId);
          if (mounted) {
            setState(() => _messages.add({'text': 'Đã hủy lịch: $apptId', 'isUser': false}));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã hủy lịch $apptId')),
            );
          }
        }
      } else if (parsed['intent'] == 'list_appointments') {
        if (user == null) {
          setState(() => _messages.add({'text': 'Bạn cần đăng nhập để xem lịch hẹn.', 'isUser': false}));
        } else {
          final appts = await DatabaseService().getUserAppointments(user.id);
          if (mounted) {
            if (appts.isEmpty) {
              setState(() => _messages.add({'text': 'Bạn chưa có lịch hẹn nào.', 'isUser': false}));
            } else {
              final lines = appts.take(5).map((a) => '- ${a.salonName}, ${a.service}, ${DateFormat('HH:mm dd/MM/yyyy').format(a.date)} (Mã: ${a.id})').join('\n');
              setState(() => _messages.add({'text': 'Lịch hẹn của bạn:\n$lines', 'isUser': false}));
            }
          }
        }
      } else if (parsed['intent'] == 'reschedule') {
        final apptId = parsed['appointmentId'] as String?;
        final dt = parsed['datetime'] as DateTime?;
        final timeSlot = parsed['timeSlot'] as String?;
        if (apptId == null || dt == null) {
          setState(() => _messages.add({'text': 'Thiếu mã lịch hoặc thời gian mới. Ví dụ: "Đổi lịch appointment_001 sang 05/10/2025 lúc 14:00"', 'isUser': false}));
        } else {
          await DatabaseService().updateAppointmentSchedule(apptId, dt, timeSlot);
          if (mounted) {
            final dateLabel = DateFormat('HH:mm dd/MM/yyyy').format(dt);
            setState(() => _messages.add({'text': 'Đã dời lịch $apptId sang $dateLabel', 'isUser': false}));
          }
        }
      } else if (parsed['intent'] == 'list_services') {
        final salon = parsed['salon'] as Map<String, String?>?;
        if (salon == null) {
          setState(() => _messages.add({'text': 'Bạn muốn xem dịch vụ của salon nào?', 'isUser': false}));
        } else {
          final list = _findServicesForSalon(salon['id']);
          setState(() => _messages.add({'text': list.isEmpty ? 'Salon chưa có dịch vụ.' : 'Dịch vụ tại ${salon['name']}:\n- ${list.join('\n- ')}', 'isUser': false}));
        }
      } else {
        final response = await _aiService.consultAI(query);
        setState(() => _messages.add({'text': response, 'isUser': false}));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _messages.add({'text': 'Lỗi: $e', 'isUser': false}));
      }
    }
  }

  // Flexible intent parser supporting Vietnamese with accents and English.
  Map<String, dynamic> _parseIntentFlexible(String text) {
    final raw = text.trim();
    final lower = raw.toLowerCase();
    final noDia = _stripDiacritics(lower);

    // Detect cancel intent in VN/EN
    if (noDia.contains(RegExp(r'\b(huy|huy\s+lich|cancel)\b'))) {
      final m = RegExp(r'(appointment_\d+)').firstMatch(noDia);
      return {'intent': 'cancel', 'appointmentId': m?.group(1)};
    }

    // Detect reschedule intents
    final reschedule = noDia.contains('doi lich') || noDia.contains('di lich') || noDia.contains('doi hen') || lower.contains('reschedule');
    if (reschedule) {
      final idMatch = RegExp(r'(appointment_\d+)').firstMatch(noDia);
      final dtParse = _parseDateTimeFlexible(text);
      return {
        'intent': 'reschedule',
        'appointmentId': idMatch?.group(1),
        'datetime': dtParse?['dt'],
        'timeSlot': dtParse?['timeSlot'],
      };
    }

    // Detect list appointments
    if (noDia.contains('lich hen cua toi') || noDia.contains('xem lich') || noDia.contains('danh sach lich hen') || lower.contains('my appointments')) {
      return {'intent': 'list_appointments'};
    }

    // Try booking detection if phrase contains words like 'dat', 'dat lich', 'book', 'toi muon', 'giup toi' etc.
    final maybeBook = noDia.contains('dat') || noDia.contains('dat lich') || noDia.contains('book') ||
        noDia.contains('toi muon') || noDia.contains('giup toi') || noDia.contains('hen');

    // Extract salon and service regardless, to allow natural phrasing
    final salon = _resolveSalon(lower);
    final service = _resolveService(lower, noDia);

    // Detect list services intent
    if ((noDia.contains('dich vu') || lower.contains('services')) && salon != null) {
      return {'intent': 'list_services', 'salon': salon};
    }

    final dtParse = _parseDateTimeFlexible(raw);

    if (salon != null && dtParse != null) {
      return {
        'intent': 'book',
        'salon': salon,
        'service': service,
        'datetime': dtParse['dt'] as DateTime,
        'timeSlot': dtParse['timeSlot'] as String,
      };
    }

    // If user asked to book but missing parts, mark as book intent to ask follow-up
    if (maybeBook) {
      return {
        'intent': 'book',
        'salon': salon,
        'service': service,
        'datetime': dtParse?['dt'],
        'timeSlot': dtParse?['timeSlot'],
      };
    }

    return {'intent': 'chat'};
  }

  Map<String, String>? _resolveSalon(String lower) {
    // Known salons mapping (extend as needed)
    final candidates = <RegExp, Map<String, String>>{
      RegExp(r'\b(le\s*hieu|lê\s*hiếu)\b', caseSensitive: false):
        {'id': 'salon_lehieu_006', 'name': 'Le Hieu Salon'},
      RegExp(r'\b(traky|tra\s*ky)\b', caseSensitive: false):
        {'id': 'salon_traky_004', 'name': 'Traky Hair Salon'},
    };
    for (final entry in candidates.entries) {
      if (entry.key.hasMatch(lower)) return entry.value;
    }
    return null;
  }

  String? _resolveService(String lower, String noDia) {
    if (noDia.contains('cat toc') || lower.contains('haircut')) return 'Haircut';
    if (noDia.contains('nhuom') || lower.contains('color')) return 'Hair Color';
    if (noDia.contains('uon') || lower.contains('perm')) return 'Perm';
    if (noDia.contains('goi dau') || lower.contains('wash')) return 'Shampoo';
    return null;
  }

  Map<String, dynamic>? _parseDateTimeFlexible(String raw) {
    // Try multiple patterns for date and time (EN + VN)
    // 1) English: October 3, 2025 at 9:00 PM
    final en = RegExp(r'(january|february|march|april|may|june|july|august|september|october|november|december)\s+([0-9]{1,2}),\s*([0-9]{4})(?:\s*(?:at)?\s*([0-9]{1,2}:[0-9]{2})\s*(am|pm)?)?', caseSensitive: false);
    final mEn = en.firstMatch(raw);
    if (mEn != null) {
      final monthName = mEn.group(1)!;
      final day = int.parse(mEn.group(2)!);
      final year = int.parse(mEn.group(3)!);
      String? timeStr = mEn.group(4);
      final ampm = mEn.group(5);
      int month = DateFormat('MMMM').parse(monthName).month;
      DateTime date = DateTime(year, month, day);
      int hour = 9, minute = 0;
      if (timeStr != null) {
        final t = DateFormat('H:mm').tryParse(timeStr) ?? DateFormat('h:mm').tryParse(timeStr);
        if (t != null) {
          hour = t.hour; minute = t.minute;
        }
        if (ampm != null) {
          final isPM = ampm.toLowerCase() == 'pm';
          if (isPM && hour < 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
        }
      }
      final dt = DateTime(date.year, date.month, date.day, hour, minute);
      final timeSlot = DateFormat('h:mm a').format(dt);
      return {'dt': dt, 'timeSlot': timeSlot};
    }

    // 2) Vietnamese: ngày 3 tháng 10, 2025 lúc 21:00
    final vn = RegExp(r'ngày\s*([0-9]{1,2})\s*tháng\s*([0-9]{1,2})\s*,?\s*([0-9]{4})(?:\s*(?:lúc|vao|vào)?\s*([0-9]{1,2}:[0-9]{2})(?:\s*(am|pm))?)?', caseSensitive: false);
    final mVn = vn.firstMatch(raw.toLowerCase());
    if (mVn != null) {
      final day = int.parse(mVn.group(1)!);
      final month = int.parse(mVn.group(2)!);
      final year = int.parse(mVn.group(3)!);
      String? timeStr = mVn.group(4);
      final ampm = mVn.group(5);
      int hour = 9, minute = 0;
      if (timeStr != null) {
        final t = DateFormat('H:mm').tryParse(timeStr) ?? DateFormat('h:mm').tryParse(timeStr);
        if (t != null) { hour = t.hour; minute = t.minute; }
        if (ampm != null) {
          final isPM = ampm.toLowerCase() == 'pm';
          if (isPM && hour < 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
        }
      }
      final dt = DateTime(year, month, day, hour, minute);
      final timeSlot = DateFormat('h:mm a').format(dt);
      return {'dt': dt, 'timeSlot': timeSlot};
    }

    // 3) Numeric formats: dd/MM/yyyy or yyyy-MM-dd plus time HH:mm optionally
    final dateNum = RegExp(r'(\d{4}-\d{2}-\d{2}|\d{1,2}/\d{1,2}/\d{4})');
    final mDateNum = dateNum.firstMatch(raw);
    if (mDateNum != null) {
      final ds = mDateNum.group(1)!;
      DateTime? d;
      if (ds.contains('-')) {
        d = DateFormat('yyyy-MM-dd').tryParse(ds);
      } else {
        d = DateFormat('d/M/yyyy').tryParse(ds) ?? DateFormat('dd/MM/yyyy').tryParse(ds);
      }
      if (d != null) {
        final tMatch = RegExp(r'(?:at|lúc|luc|vao|vào)?\s*([0-9]{1,2}:[0-9]{2})\s*(am|pm)?', caseSensitive: false).firstMatch(raw);
        int hour = 9, minute = 0;
        if (tMatch != null) {
          final tStr = tMatch.group(1)!;
          final t = DateFormat('H:mm').tryParse(tStr) ?? DateFormat('h:mm').tryParse(tStr);
          if (t != null) { hour = t.hour; minute = t.minute; }
          final ampm = tMatch.group(2);
          if (ampm != null) {
            final isPM = ampm.toLowerCase() == 'pm';
            if (isPM && hour < 12) hour += 12;
            if (!isPM && hour == 12) hour = 0;
          }
        }
        final dt = DateTime(d.year, d.month, d.day, hour, minute);
        final timeSlot = DateFormat('h:mm a').format(dt);
        return {'dt': dt, 'timeSlot': timeSlot};
      }
    }

    return null;
  }

  String _stripDiacritics(String input) {
    const mapping = {
      'à':'a','á':'a','ả':'a','ã':'a','ạ':'a','ă':'a','ằ':'a','ắ':'a','ẳ':'a','ẵ':'a','ặ':'a','â':'a','ầ':'a','ấ':'a','ẩ':'a','ẫ':'a','ậ':'a',
      'è':'e','é':'e','ẻ':'e','ẽ':'e','ẹ':'e','ê':'e','ề':'e','ế':'e','ể':'e','ễ':'e','ệ':'e',
      'ì':'i','í':'i','ỉ':'i','ĩ':'i','ị':'i',
      'ò':'o','ó':'o','ỏ':'o','õ':'o','ọ':'o','ô':'o','ồ':'o','ố':'o','ổ':'o','ỗ':'o','ộ':'o','ơ':'o','ờ':'o','ớ':'o','ở':'o','ỡ':'o','ợ':'o',
      'ù':'u','ú':'u','ủ':'u','ũ':'u','ụ':'u','ư':'u','ừ':'u','ứ':'u','ử':'u','ữ':'u','ự':'u',
      'ỳ':'y','ý':'y','ỷ':'y','ỹ':'y','ỵ':'y',
      'đ':'d',
    };
    final sb = StringBuffer();
    for (final cp in input.runes) {
      final ch = String.fromCharCode(cp);
      sb.write(mapping[ch] ?? ch);
    }
    return sb.toString();
  }

  List<String> _findServicesForSalon(String? salonId) {
    if (salonId == null) return [];
    final salons = MockDataService.getHoChiMinhSalons();
    final s = salons.where((e) => e.id == salonId).toList();
    if (s.isEmpty) return [];
    return s.first.services;
  }

  Future<void> _pickAndSendImage() async {
    final image = await _aiService.pickImage();
    if (image != null && mounted) {
      setState(() => _messages.add({'text': 'Ảnh tóc', 'isUser': true, 'imagePath': image.path}));
      try {
        final response = await _aiService.consultAI('Phân tích ảnh', image: image);
        setState(() => _messages.add({'text': response, 'isUser': false}));
      } catch (e) {
        setState(() => _messages.add({'text': 'Lỗi phân tích: $e', 'isUser': false}));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavbar(activeIndex: 2),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple : const Color(0xFF1B1033),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg['imagePath'] != null)
                          Image.file(File(msg['imagePath'] as String), height: 200, fit: BoxFit.cover),
                        Text(
                          msg['text'] as String,
                          style: TextStyle(color: isUser ? Colors.white : AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Hỏi về tóc...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.image), onPressed: _pickAndSendImage),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0F0A1F),
    );
  }
}
