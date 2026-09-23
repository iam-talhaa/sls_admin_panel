import 'dart:async';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/localized_text.dart';
import '../models/jet_admin_model.dart';

final fleetRepositoryProvider = Provider<FleetRepository>((ref) {
  return FleetRepository();
});

final fleetListStreamProvider = StreamProvider<List<JetAdminModel>>((ref) {
  return ref.watch(fleetRepositoryProvider).watchJets();
});

class FleetRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<JetAdminModel> _inMemoryJets = [
    const JetAdminModel(
      id: 'light_jet',
      order: 0,
      category: 'LIGHT JET',
      imageUrl: 'assets/jet1.png',
      name: LocalizedText(
        en: 'Light Jet',
        fr: 'Jet Léger',
        de: 'Leichtjet',
        ar: 'طائرة خفيفة',
      ),
      seating: LocalizedText(
        en: 'Up to 4 passengers',
        fr: 'Jusqu\'à 4 passagers',
        de: 'Bis zu 4 Passagiere',
        ar: 'حتى 4 ركاب',
      ),
      range: LocalizedText(
        en: 'Up to 2.5 Hours',
        fr: 'Jusqu\'à 2,5 heures',
        de: 'Bis zu 2,5 Stunden',
        ar: 'حتى 2.5 ساعة',
      ),
      description: LocalizedText(
        en: 'Very light jets (VLJs) are a cost-effective and flexible charter option for groups of up to four passengers. They have a lightweight airframe and impressive performance capabilities, allowing them to land in small airports with short runways. They are also fast and efficient, making them a great option for entry-level charter jet. However, they have limited amenities and luggage space. They are perfect for short trips with a small group of people and for those who are looking for an economic option.',
        fr: 'Les jets très légers (VLJ) sont une option d\'affrètement économique et flexible pour des groupes de 4 passagers maximum.',
        de: 'Sehr leichte Jets (VLJs) sind eine kostengünstige und flexible Charteroption für Gruppen von bis zu vier Passagieren.',
        ar: 'تعتبر الطائرات الخفيفة للغاية خياراً اقتصادياً ومرناً للمجموعات المكونة من 4 ركاب كحد أقصى.',
      ),
      isActive: true,
    ),
    const JetAdminModel(
      id: 'midsize_jet',
      order: 1,
      category: 'MIDSIZE JET',
      imageUrl: 'assets/jet2.png',
      name: LocalizedText(
        en: 'Midsize Jet',
        fr: 'Jet Intermédiaire',
        de: 'Mittelgroßer Jet',
        ar: 'طائرة متوسطة الحجم',
      ),
      seating: LocalizedText(
        en: 'Up to 8 passengers',
        fr: 'Jusqu\'à 8 passagers',
        de: 'Bis zu 8 Passagiere',
        ar: 'حتى 8 ركاب',
      ),
      range: LocalizedText(
        en: 'Up to 4 Hours',
        fr: 'Jusqu\'à 4 heures',
        de: 'Bis zu 4 Stunden',
        ar: 'حتى 4 ساعات',
      ),
      description: LocalizedText(
        en: 'Midsize jets offer the perfect balance of range, speed, and spacious cabin comfort for groups of up to eight passengers. Featuring generous stand-up headroom, ample luggage compartment capacity, and transcontinental capabilities, midsize jets provide superior performance for medium-haul journeys while maintaining optimal flexibility.',
        fr: 'Les jets intermédiaires offrent un équilibre parfait entre autonomie, vitesse et confort de cabine pour jusqu\'à huit passagers.',
        de: 'Mittelgroße Jets bieten die perfekte Balance aus Reichweite, Geschwindigkeit und geräumigem Kabinenkomfort für bis zu acht Passagiere.',
        ar: 'توفر الطائرات متوسطة الحجم التوازن المثالي بين المدى والسرعة والراحة لغاية 8 ركاب.',
      ),
      isActive: true,
    ),
    const JetAdminModel(
      id: 'heavy_jet',
      order: 2,
      category: 'HEAVY JET',
      imageUrl: 'assets/jet3.png',
      name: LocalizedText(
        en: 'Heavy Jet',
        fr: 'Jet Lourd',
        de: 'Schwerer Jet',
        ar: 'طائرة ثقيلة فاخرة',
      ),
      seating: LocalizedText(
        en: 'Up to 14 passengers',
        fr: 'Jusqu\'à 14 passagers',
        de: 'Bis zu 14 Passagiere',
        ar: 'حتى 14 راكباً',
      ),
      range: LocalizedText(
        en: 'Up to 8 Hours',
        fr: 'Jusqu\'à 8 heures',
        de: 'Bis zu 8 Stunden',
        ar: 'حتى 8 ساعات',
      ),
      description: LocalizedText(
        en: 'Heavy jets represent the ultimate in private jet luxury and intercontinental performance. Designed to seat up to fourteen passengers across distinct cabin zones, they feature fully flat berthable seating, a dedicated attendant galley, high-speed connectivity, and exceptional transatlantic range.',
        fr: 'Les jets lourds représentent le summum du luxe en jet privé et des performances intercontinentales.',
        de: 'Schwere Jets bieten das Höchstmaß an Luxus und interkontinentaler Leistung für bis zu 14 Passagiere.',
        ar: 'تمثل الطائرات الثقيلة قمة الفخامة في الطيران الخاص والأداء العابر للقارات.',
      ),
      isActive: true,
    ),
    const JetAdminModel(
      id: 'helicopter',
      order: 3,
      category: 'HELICOPTER',
      imageUrl: 'assets/chopper.png',
      name: LocalizedText(
        en: 'Helicopter',
        fr: 'Hélicoptère',
        de: 'Hubschrauber',
        ar: 'طائرة هليكوبتر',
      ),
      seating: LocalizedText(
        en: 'Up to 8 passengers',
        fr: 'Jusqu\'à 8 passagers',
        de: 'Bis zu 8 Passagiere',
        ar: 'حتى 8 ركاب',
      ),
      range: LocalizedText(
        en: 'Up to 3 Hours',
        fr: 'Jusqu\'à 3 heures',
        de: 'Bis zu 3 Stunden',
        ar: 'حتى 3 ساعات',
      ),
      description: LocalizedText(
        en: 'Imagine flying directly to your private jet by helicopter – no traffic jams, no detours, just take off and enjoy the world from above. With our helicopter booking services Zurich, you can reach your destination quickly, comfortably, and in style.',
        fr: 'Envolez-vous directement vers votre jet privé en hélicoptère – sans embouteillages ni détours.',
        de: 'Fliegen Sie mit dem Helikopter direkt zu Ihrem Privatjet – staufrei und komfortabel.',
        ar: 'سافر مباشرة إلى طائرتك الخاصة بالهليكوبتر وتجنب الازدحام المروري.',
      ),
      isActive: true,
    ),
  ];

  final _streamController = StreamController<List<JetAdminModel>>.broadcast();
  bool _isSeeded = false;

  FleetRepository() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore
          .collection('jets')
          .orderBy('order')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isNotEmpty) {
                _inMemoryJets.clear();
                for (final doc in snapshot.docs) {
                  _inMemoryJets.add(JetAdminModel.fromMap(doc.data(), doc.id));
                }
                _notify();
              } else if (!_isSeeded) {
                _isSeeded = true;
                seedInitialJets();
              }
            },
            onError: (e) {
              dev.log(
                'Firestore jets listener error: $e',
                name: 'FleetRepository',
              );
              _notify();
            },
          );
    } catch (e) {
      dev.log('Error initializing firestore jets: $e', name: 'FleetRepository');
      _notify();
    }
  }

  Future<void> seedInitialJets({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('jets').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final jet in _inMemoryJets) {
        final docRef = _firestore.collection('jets').doc(jet.id);
        // Exclude imageUrl — Firebase Storage is not yet enabled.
        final data = Map<String, dynamic>.from(jet.toMap())..remove('imageUrl');
        batch.set(docRef, data, SetOptions(merge: true));
      }
      await batch.commit();
      dev.log(
        'Initial fleet catalog seeded successfully to Firestore',
        name: 'FleetRepository',
      );
    } catch (e) {
      dev.log(
        'Error seeding initial jets to Firestore: $e',
        name: 'FleetRepository',
      );
      rethrow; // propagate so the UI can show the error snackbar
    }
  }

  void _notify() {
    _inMemoryJets.sort((a, b) => a.order.compareTo(b.order));
    _streamController.add(List.unmodifiable(_inMemoryJets));
  }

  Stream<List<JetAdminModel>> watchJets() {
    return Stream<List<JetAdminModel>>.multi((controller) {
      _inMemoryJets.sort((a, b) => a.order.compareTo(b.order));
      controller.add(List.unmodifiable(_inMemoryJets));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<JetAdminModel> get currentJets => List.unmodifiable(_inMemoryJets);

  Future<JetAdminModel?> getJetById(String id) async {
    try {
      final doc = await _firestore.collection('jets').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final jet = JetAdminModel.fromMap(doc.data()!, doc.id);
        final idx = _inMemoryJets.indexWhere((j) => j.id == id);
        if (idx >= 0) {
          _inMemoryJets[idx] = jet;
        } else {
          _inMemoryJets.add(jet);
        }
        return jet;
      }
    } catch (e) {
      dev.log(
        'Error fetching jet $id from Firestore: $e',
        name: 'FleetRepository',
      );
    }

    try {
      return _inMemoryJets.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveJet(JetAdminModel jet) async {
    final newId = jet.id.isNotEmpty
        ? jet.id
        : 'jet_${DateTime.now().millisecondsSinceEpoch}';
    final index = _inMemoryJets.indexWhere(
      (j) => j.id == newId || (jet.id.isNotEmpty && j.id == jet.id),
    );
    final finalOrder = jet.order > 0
        ? jet.order
        : (index >= 0 ? _inMemoryJets[index].order : _inMemoryJets.length);
    final finalJet = jet.copyWith(
      id: newId,
      order: finalOrder,
      createdAt:
          jet.createdAt ??
          (index >= 0 ? _inMemoryJets[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _inMemoryJets[index] = finalJet;
    } else {
      _inMemoryJets.add(finalJet);
    }
    _notify();

    try {
      await _firestore
          .collection('jets')
          .doc(newId)
          .set(finalJet.toMap(), SetOptions(merge: true));
    } catch (e) {
      dev.log(
        'Error saving jet $newId to Firestore: $e',
        name: 'FleetRepository',
      );
      // Do not rethrow — in-memory update already succeeded.
    }
  }

  Future<void> deleteJet(String id) async {
    _inMemoryJets.removeWhere((j) => j.id == id);
    _notify();

    try {
      await _firestore.collection('jets').doc(id).delete();
    } catch (e) {
      dev.log(
        'Error deleting jet $id from Firestore: $e',
        name: 'FleetRepository',
      );
      // Do not rethrow — in-memory deletion already succeeded.
    }
  }

  Future<void> toggleJetStatus(String id, bool isActive) async {
    final index = _inMemoryJets.indexWhere((j) => j.id == id);
    if (index >= 0) {
      _inMemoryJets[index] = _inMemoryJets[index].copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      _notify();
    }

    try {
      await _firestore.collection('jets').doc(id).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      dev.log(
        'Error toggling jet status in Firestore: $e',
        name: 'FleetRepository',
      );
      // Do not rethrow — in-memory update already succeeded.
    }
  }

  Future<void> updateJetsOrder(List<JetAdminModel> reorderedJets) async {
    for (int i = 0; i < reorderedJets.length; i++) {
      final item = reorderedJets[i];
      final idx = _inMemoryJets.indexWhere((j) => j.id == item.id);
      if (idx >= 0) {
        _inMemoryJets[idx] = _inMemoryJets[idx].copyWith(order: i);
      }
    }
    _notify();

    try {
      final batch = _firestore.batch();
      for (int i = 0; i < reorderedJets.length; i++) {
        final docRef = _firestore.collection('jets').doc(reorderedJets[i].id);
        batch.update(docRef, {'order': i});
      }
      await batch.commit();
    } catch (e) {
      dev.log(
        'Error updating jets order in Firestore: $e',
        name: 'FleetRepository',
      );
      // Do not rethrow — in-memory reorder already succeeded.
    }
  }
}
