import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote_request_model.dart';

final quoteRequestsRepositoryProvider = Provider<QuoteRequestsRepository>((ref) {
  return QuoteRequestsRepository();
});

final quoteRequestsListStreamProvider = StreamProvider<List<QuoteRequestModel>>((ref) {
  return ref.watch(quoteRequestsRepositoryProvider).watchQuoteRequests();
});

class QuoteRequestsRepository {
  final List<QuoteRequestModel> _quotes = [
    QuoteRequestModel(
      id: 'quote_001',
      firstName: 'Alexander Wright',
      email: 'alex.wright@genevafinance.ch',
      phone: '+41 79 555 12 34',
      message: 'Requesting quotation for round-trip charter Zurich (ZRH) to Davos for 4 passengers during the WEF summit.',
      status: QuoteRequestStatus.isNew,
      adminNotes: 'Initial inquiry received via mobile app.',
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
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final _streamController = StreamController<List<QuoteRequestModel>>.broadcast();

  QuoteRequestsRepository() {
    _notify();
  }

  void _notify() {
    _quotes.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    _streamController.add(List.unmodifiable(_quotes));
  }

  Stream<List<QuoteRequestModel>> watchQuoteRequests() {
    return Stream<List<QuoteRequestModel>>.multi((controller) {
      _quotes.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
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
      return _quotes.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, QuoteRequestStatus status) async {
    final index = _quotes.indexWhere((q) => q.id == id);
    if (index >= 0) {
      _quotes[index] = _quotes[index].copyWith(status: status);
      _notify();
    }
  }

  Future<void> updateAdminNotes(String id, String notes) async {
    final index = _quotes.indexWhere((q) => q.id == id);
    if (index >= 0) {
      _quotes[index] = _quotes[index].copyWith(adminNotes: notes);
      _notify();
    }
  }

  Future<void> deleteQuoteRequest(String id) async {
    _quotes.removeWhere((q) => q.id == id);
    _notify();
  }
}
