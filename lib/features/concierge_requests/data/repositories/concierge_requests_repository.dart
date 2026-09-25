import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/concierge_request_model.dart';

final conciergeRequestsRepositoryProvider = Provider<ConciergeRequestsRepository>((ref) {
  return ConciergeRequestsRepository();
});

final conciergeRequestsListStreamProvider = StreamProvider<List<ConciergeRequestModel>>((ref) {
  return ref.watch(conciergeRequestsRepositoryProvider).watchConciergeRequests();
});

class ConciergeRequestsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<ConciergeRequestModel> defaultRequests = [
    ConciergeRequestModel(
      id: 'concierge_001',
      name: 'Baroness Elena Rossi',
      email: 'elena.rossi@milanolux.it',
      phone: '+39 02 1234 567',
      serviceCategory: 'Chauffeur & Ground Handling',
      preferredDate: '2026-02-05',
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
      serviceCategory: 'VIP Travel Solutions',
      preferredDate: '2026-03-12',
      requestDetails: 'Private helicopter connection from Geneva airport to Courchevel 1850 alpine chalet.',
      status: ConciergeRequestStatus.inProgress,
      adminNotes: 'Helicopter pre-positioned in Geneva. Customs clearance in progress.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<ConciergeRequestModel> _requests = [];
  final _streamController = StreamController<List<ConciergeRequestModel>>.broadcast();
  bool _isSeeded = false;

  ConciergeRequestsRepository() {
    _requests.addAll(defaultRequests);
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('concierge_requests').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _requests.clear();
            for (final doc in snapshot.docs) {
              _requests.add(ConciergeRequestModel.fromMap(doc.data(), doc.id));
            }
            _notify();
          } else if (!_isSeeded) {
            _isSeeded = true;
            seedInitialConciergeRequests();
          }
        },
        onError: (e) {
          dev.log('Firestore concierge_requests listener error: $e', name: 'ConciergeRequestsRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore concierge_requests: $e', name: 'ConciergeRequestsRepository');
      _notify();
    }
  }

  Future<void> seedInitialConciergeRequests({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('concierge_requests').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final req in defaultRequests) {
        final docRef = _firestore.collection('concierge_requests').doc(req.id);
        batch.set(docRef, req.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      dev.log('Initial concierge requests seeded to Firestore', name: 'ConciergeRequestsRepository');
    } catch (e) {
      dev.log('Error seeding concierge requests to Firestore: $e', name: 'ConciergeRequestsRepository');
      if (_requests.isEmpty) {
        _requests.addAll(defaultRequests);
        _notify();
      }
    }
  }

  void _notify() {
    _requests.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    _streamController.add(List.unmodifiable(_requests));
  }

  Stream<List<ConciergeRequestModel>> watchConciergeRequests() {
    return Stream<List<ConciergeRequestModel>>.multi((controller) {
      _notify();
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
      final doc = await _firestore.collection('concierge_requests').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final req = ConciergeRequestModel.fromMap(doc.data()!, doc.id);
        final idx = _requests.indexWhere((r) => r.id == id);
        if (idx >= 0) {
          _requests[idx] = req;
        } else {
          _requests.add(req);
        }
        _notify();
        return req;
      }
    } catch (e) {
      dev.log('Error fetching concierge request $id from Firestore: $e', name: 'ConciergeRequestsRepository');
    }

    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, ConciergeRequestStatus status) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(status: status, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('concierge_requests').doc(id).set({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating status for concierge request $id in Firestore: $e', name: 'ConciergeRequestsRepository');
    }
  }

  Future<void> updateAdminNotes(String id, String notes) async {
    final index = _requests.indexWhere((r) => r.id == id);
    if (index >= 0) {
      _requests[index] = _requests[index].copyWith(adminNotes: notes, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('concierge_requests').doc(id).set({
        'adminNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating admin notes for concierge request $id in Firestore: $e', name: 'ConciergeRequestsRepository');
    }
  }

  Future<void> deleteConciergeRequest(String id) async {
    _requests.removeWhere((r) => r.id == id);
    _notify();

    try {
      await _firestore.collection('concierge_requests').doc(id).delete();
    } catch (e) {
      dev.log('Error deleting concierge request $id from Firestore: $e', name: 'ConciergeRequestsRepository');
    }
  }

  Future<void> saveConciergeRequest(ConciergeRequestModel request) async {
    final newId = request.id.isNotEmpty
        ? request.id
        : 'concierge_${DateTime.now().millisecondsSinceEpoch}';
    final index = _requests.indexWhere((r) => r.id == newId || (request.id.isNotEmpty && r.id == request.id));
    final finalRequest = request.copyWith(
      id: newId,
      createdAt: request.createdAt ?? (index >= 0 ? _requests[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _requests[index] = finalRequest;
    } else {
      _requests.add(finalRequest);
    }
    _notify();

    try {
      await _firestore.collection('concierge_requests').doc(newId).set(
            finalRequest.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      dev.log('Error saving concierge request $newId to Firestore: $e', name: 'ConciergeRequestsRepository');
    }
  }
}
