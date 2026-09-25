import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote_request_model.dart';

final quoteRequestsRepositoryProvider = Provider<QuoteRequestsRepository>((ref) {
  return QuoteRequestsRepository();
});

final quoteRequestsListStreamProvider = StreamProvider<List<QuoteRequestModel>>((ref) {
  return ref.watch(quoteRequestsRepositoryProvider).watchQuoteRequests();
});

class QuoteRequestsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<QuoteRequestModel> defaultQuotes = [
    QuoteRequestModel(
      id: 'quote_001',
      firstName: 'Alexander Wright',
      email: 'alex.wright@genevafinance.ch',
      phone: '+41 79 555 12 34',
      message: 'Requesting quotation for round-trip charter Zurich (ZRH) to Davos for 4 passengers during the WEF summit.',
      status: QuoteRequestStatus.isNew,
      adminNotes: 'Initial inquiry received via mobile app.',
      departure: 'Zurich (ZRH)',
      destination: 'Davos / Samedan (SMV)',
      departureDate: '2026-01-20',
      returnDate: '2026-01-24',
      passengers: '4',
      jetType: 'Midsize Jet',
      tripType: 'round_trip',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    QuoteRequestModel(
      id: 'quote_002',
      firstName: 'Sophie Von Berg',
      email: 'sophie.berg@luxuryliving.de',
      phone: '+49 171 234 5678',
      message: 'Midsize Jet charter from Munich to London Stansted on Friday afternoon.',
      status: QuoteRequestStatus.contacted,
      adminNotes: 'Quoted Challenger 350 at EUR 8,400. Client reviewing itinerary.',
      departure: 'Munich (MUC)',
      destination: 'London Stansted (STN)',
      departureDate: '2026-02-14',
      passengers: '6',
      jetType: 'Super Midsize Jet',
      tripType: 'one_way',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    QuoteRequestModel(
      id: 'quote_003',
      firstName: 'Marc Dumas',
      email: 'm.dumas@artparis.fr',
      phone: '+33 6 12 34 56 78',
      message: 'Helicopter transfer from Zurich airport directly to Art Basel VIP lounge.',
      status: QuoteRequestStatus.closed,
      adminNotes: 'Booking confirmed and flight scheduled.',
      departure: 'Zurich Airport (ZRH)',
      destination: 'Art Basel (BSL)',
      departureDate: '2026-06-18',
      passengers: '2',
      jetType: 'VIP Helicopter',
      tripType: 'one_way',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<QuoteRequestModel> _quotes = [];
  final _streamController = StreamController<List<QuoteRequestModel>>.broadcast();
  bool _isSeeded = false;

  QuoteRequestsRepository() {
    _quotes.addAll(defaultQuotes);
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('quote_requests').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _quotes.clear();
            for (final doc in snapshot.docs) {
              _quotes.add(QuoteRequestModel.fromMap(doc.data(), doc.id));
            }
            _notify();
          } else if (!_isSeeded) {
            _isSeeded = true;
            seedInitialQuoteRequests();
          }
        },
        onError: (e) {
          dev.log('Firestore quote_requests listener error: $e', name: 'QuoteRequestsRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore quote_requests: $e', name: 'QuoteRequestsRepository');
      _notify();
    }
  }

  Future<void> seedInitialQuoteRequests({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('quote_requests').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final quote in defaultQuotes) {
        final docRef = _firestore.collection('quote_requests').doc(quote.id);
        batch.set(docRef, quote.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      dev.log('Initial quote requests seeded to Firestore', name: 'QuoteRequestsRepository');
    } catch (e) {
      dev.log('Error seeding quote requests to Firestore: $e', name: 'QuoteRequestsRepository');
      // If seeding fails, fallback to default in-memory quotes
      if (_quotes.isEmpty) {
        _quotes.addAll(defaultQuotes);
        _notify();
      }
    }
  }

  void _notify() {
    _quotes.sort((a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
    _streamController.add(List.unmodifiable(_quotes));
  }

  Stream<List<QuoteRequestModel>> watchQuoteRequests() {
    return Stream<List<QuoteRequestModel>>.multi((controller) {
      _notify();
      controller.add(List.unmodifiable(_quotes));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<QuoteRequestModel> get currentQuotes => List.unmodifiable(_quotes);

  Future<QuoteRequestModel?> getQuoteRequestById(String id) async {
    try {
      final doc = await _firestore.collection('quote_requests').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final quote = QuoteRequestModel.fromMap(doc.data()!, doc.id);
        final idx = _quotes.indexWhere((q) => q.id == id);
        if (idx >= 0) {
          _quotes[idx] = quote;
        } else {
          _quotes.add(quote);
        }
        _notify();
        return quote;
      }
    } catch (e) {
      dev.log('Error fetching quote request $id from Firestore: $e', name: 'QuoteRequestsRepository');
    }

    try {
      return _quotes.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, QuoteRequestStatus status) async {
    final index = _quotes.indexWhere((q) => q.id == id);
    if (index >= 0) {
      _quotes[index] = _quotes[index].copyWith(status: status, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('quote_requests').doc(id).set({
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating status for quote $id in Firestore: $e', name: 'QuoteRequestsRepository');
    }
  }

  Future<void> updateAdminNotes(String id, String notes) async {
    final index = _quotes.indexWhere((q) => q.id == id);
    if (index >= 0) {
      _quotes[index] = _quotes[index].copyWith(adminNotes: notes, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('quote_requests').doc(id).set({
        'adminNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Error updating admin notes for quote $id in Firestore: $e', name: 'QuoteRequestsRepository');
    }
  }

  Future<void> deleteQuoteRequest(String id) async {
    _quotes.removeWhere((q) => q.id == id);
    _notify();

    try {
      await _firestore.collection('quote_requests').doc(id).delete();
    } catch (e) {
      dev.log('Error deleting quote request $id from Firestore: $e', name: 'QuoteRequestsRepository');
    }
  }

  Future<void> saveQuoteRequest(QuoteRequestModel quote) async {
    final newId = quote.id.isNotEmpty
        ? quote.id
        : 'quote_${DateTime.now().millisecondsSinceEpoch}';
    final index = _quotes.indexWhere((q) => q.id == newId || (quote.id.isNotEmpty && q.id == quote.id));
    final finalQuote = quote.copyWith(
      id: newId,
      createdAt: quote.createdAt ?? (index >= 0 ? _quotes[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _quotes[index] = finalQuote;
    } else {
      _quotes.add(finalQuote);
    }
    _notify();

    try {
      await _firestore.collection('quote_requests').doc(newId).set(
            finalQuote.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      dev.log('Error saving quote request $newId to Firestore: $e', name: 'QuoteRequestsRepository');
    }
  }
}
