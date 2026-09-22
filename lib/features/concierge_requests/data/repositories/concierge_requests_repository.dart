import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/concierge_request_model.dart';

final conciergeRequestsRepositoryProvider = Provider<ConciergeRequestsRepository>((ref) {
  return ConciergeRequestsRepository();
});

final conciergeRequestsListStreamProvider = StreamProvider<List<ConciergeRequestModel>>((ref) {
  return ref.watch(conciergeRequestsRepositoryProvider).watchConciergeRequests();
});

class ConciergeRequestsRepository {
  final List<ConciergeRequestModel> _requests = [
    ConciergeRequestModel(
      id: 'concierge_001',
      name: 'Baroness Elena Rossi',
      email: 'elena.rossi@milanolux.it',
      phone: '+39 02 1234 567',
      requestDetails: 'VIP Mercedes Maybach transfer from Samedan St. Moritz airport directly to Badrutt’s Palace with luggage van.',
      status: ConciergeRequestStatus.isNew,
      adminNotes: 'Assigned to alpine ground logistics team.',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    ConciergeRequestModel(
      id: 'concierge_002',
      name: 'Sheikh Hamdan Al-Maktoum',
      email: 'h.maktoum@dubaiholding.ae',
      phone: '+971 50 123 4567',
      requestDetails: 'Private helicopter connection from Geneva airport to Courchevel 1850 alpine chalet.',
      status: ConciergeRequestStatus.inProgress,
      adminNotes: 'Helicopter pre-positioned in Geneva. Customs clearance in progress.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final _streamController = StreamController<List<ConciergeRequestModel>>.broadcast();

  ConciergeRequestsRepository() {
    _notify();
  }

  void _notify() {
    _requests.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    _streamController.add(List.unmodifiable(_requests));
  }

  Stream<List<ConciergeRequestModel>> watchConciergeRequests() {
    return Stream<List<ConciergeRequestModel>>.multi((controller) {
      _requests.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
      controller.add(List.unmodifiable(_requests));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<ConciergeRequestModel> get currentRequests => List.unmodifiable(_requests);

  Future<ConciergeRequestModel?> getConciergeRequestById(String id) async {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, ConciergeRequestStatus status) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(status: status);
      _notify();
    }
  }

  Future<void> updateAdminNotes(String id, String notes) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(adminNotes: notes);
      _notify();
    }
  }

  Future<void> deleteConciergeRequest(String id) async {
    _requests.removeWhere((r) => r.id == id);
    _notify();
  }
}
