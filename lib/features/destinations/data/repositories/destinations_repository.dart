import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/content_block.dart';
import '../../../../core/models/localized_text.dart';
import '../models/destination_admin_model.dart';

final destinationsRepositoryProvider = Provider<DestinationsRepository>((ref) {
  return DestinationsRepository();
});

final destinationsListStreamProvider = StreamProvider<List<DestinationAdminModel>>((ref) {
  return ref.watch(destinationsRepositoryProvider).watchDestinations();
});

class DestinationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<DestinationAdminModel> _destinations = [
    const DestinationAdminModel(
      id: 'wef-davos-europe',
      order: 0,
      title: LocalizedText(en: 'WEF Davos', fr: 'WEF Davos', de: 'WEF Davos', ar: 'دافوس WEF'),
      category: LocalizedText(en: 'WORLD ECONOMIC FORUM', fr: 'FORUM ÉCONOMIQUE MONDIAL', de: 'WELTWIRTSCHAFTSFORUM', ar: 'المنتدى الاقتصادي العالمي'),
      duration: '1 hr 10 min',
      imageUrl: 'assets/des1.jpg',
      overlayTag: LocalizedText(en: 'WEF • ~ 1 hr 10 min', fr: 'WEF • ~ 1 h 10 min', de: 'WEF • ~ 1 Std. 10 Min.', ar: 'WEF • ~ 1 ساعة 10 دقائق'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Davos', fr: 'Zurich – Davos', de: 'Zürich – Davos', ar: 'زيورخ – دافوس'),
      startingPrice: LocalizedText(en: 'From CHF 3,500', fr: 'À partir de CHF 3 500', de: 'Ab CHF 3.500', ar: 'من 3,500 فرنك'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', fr: 'CAPACITÉ : JUSQU\'À 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', fr: 'AUTONOMIE : JUSQU\'À 2,5 HEURES', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      whyTravelWithUs: [
        LocalizedText(en: 'Direct airport access: Samedan (SMV), Dübendorf (LSMD), or Zurich (ZRH)', fr: 'Accès direct aux aéroports : Samedan, Dübendorf ou Zurich', de: 'Direkter Flughafenzugang: Samedan, Dübendorf oder Zürich', ar: 'وصول مباشر للمطارات: ساميدان، دوبندورف أو زيورخ'),
        LocalizedText(en: 'Seamless VIP transfers via private limousine or alpine helicopter', fr: 'Transferts VIP en limousine privée ou hélicoptère alpin', de: 'Nahtlose VIP-Transfers per Limousine oder Alpenhelikopter', ar: 'تنقلات VIP سلسة عبر ليموزين خاصة أو طائرة هليكوبتر'),
      ],
      contentBlocks: [
        ContentBlock(
          type: ContentBlockType.subheading,
          text: LocalizedText(en: 'Accommodation in Davos', fr: 'Hébergement à Davos', de: 'Unterkunft in Davos', ar: 'الإقامة في دافوس'),
        ),
        ContentBlock(
          type: ContentBlockType.paragraph,
          text: LocalizedText(
            en: 'Book your accommodation early, as demand is very high during the WEF. There is a wide range of luxury hotels, apartments, and alpine chalets in Davos.',
            fr: 'Réservez votre hébergement tôt en raison de la forte demande pendant le WEF.',
            de: 'Buchen Sie Ihre Unterkunft frühzeitig, da die Nachfrage während des WEF sehr hoch ist.',
            ar: 'احجز إقامتك مبكراً نظراً للطلب المرتفع جداً خلال منتدى دافوس.',
          ),
        ),
      ],
    ),
    const DestinationAdminModel(
      id: 'art-basel',
      order: 1,
      title: LocalizedText(en: 'Art Basel', fr: 'Art Basel', de: 'Art Basel', ar: 'آرت بازل'),
      category: LocalizedText(en: "THE WORLD'S PREMIER ART FAIR", fr: 'LA PLUS GRANDE FOIRE D\'ART', de: 'DIE WELTWEIT FÜHRENDE KUNSTMESSE', ar: 'معرض الفن الرائد عالمياً'),
      duration: '45 min',
      imageUrl: 'assets/des2.png',
      overlayTag: LocalizedText(en: 'ART BASEL • ~ 45 min', fr: 'ART BASEL • ~ 45 min', de: 'ART BASEL • ~ 45 Min.', ar: 'آرت بازل • ~ 45 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – Basel', fr: 'Zurich – Bâle', de: 'Zürich – Basel', ar: 'زيورخ – بازل'),
      startingPrice: LocalizedText(en: 'From CHF 3,500', fr: 'À partir de CHF 3 500', de: 'Ab CHF 3.500', ar: 'من 3,500 فرنك'),
      seating: LocalizedText(en: 'SEATING : UP TO 4', fr: 'CAPACITÉ : JUSQU\'À 4', de: 'SITZPLÄTZE : BIS ZU 4', ar: 'المقاعد : حتى 4'),
      range: LocalizedText(en: 'RANGE : UP TO 2.5 HOURS', fr: 'AUTONOMIE : JUSQU\'À 2,5 HEURES', de: 'REICHWEITE : BIS ZU 2,5 STUNDEN', ar: 'المدى : حتى 2.5 ساعة'),
      isActive: true,
      whyTravelWithUs: [
        LocalizedText(en: 'Efficient travel without airport delays', fr: 'Voyage efficace sans retards d\'aéroport', de: 'Effizientes Reisen ohne Flughafenverzögerungen', ar: 'سفر مريح وسريع دون أي تأخير'),
        LocalizedText(en: 'Unmatched comfort and luxury', fr: 'Confort et luxe inégalés', de: 'Unübertroffener Komfort und Luxus', ar: 'فخامة وراحة لا تضاهى'),
      ],
      contentBlocks: [
        ContentBlock(
          type: ContentBlockType.paragraph,
          text: LocalizedText(
            en: 'Art Basel is a premier international art fair that showcases the best of modern and contemporary art.',
            fr: 'Art Basel est une foire d\'art internationale de premier plan.',
            de: 'Die Art Basel ist eine führende internationale Kunstmesse.',
            ar: 'آرت بازل هو المعرض الدولي الرائد للفن الحديث.',
          ),
        ),
      ],
    ),
    const DestinationAdminModel(
      id: 'zurich-london',
      order: 2,
      title: LocalizedText(en: 'Zurich – London', fr: 'Zurich – Londres', de: 'Zürich – London', ar: 'زيورخ – لندن'),
      category: LocalizedText(en: 'FINANCE & CULTURE', fr: 'FINANCE ET CULTURE', de: 'FINANZEN & KULTUR', ar: 'أعمال وثقافة'),
      duration: '1 hr 40 min',
      imageUrl: 'assets/des4.png',
      overlayTag: LocalizedText(en: 'ZRH ⇄ LON • ~ 1 hr 40 min', fr: 'ZRH ⇄ LON • ~ 1 h 40 min', de: 'ZRH ⇄ LON • ~ 1 Std. 40 Min.', ar: 'زيورخ ⇄ لندن • ~ 1 ساعة 40 دقيقة'),
      jetType: 'Light Jet',
      route: LocalizedText(en: 'Zurich – London', fr: 'Zurich – Londres', de: 'Zürich – London', ar: 'زيورخ – لندن'),
      startingPrice: LocalizedText(en: 'From CHF 3,500', fr: 'À partir de CHF 3 500', de: 'Ab CHF 3.500', ar: 'من 3,500 فرنك'),
      isActive: true,
    ),
  ];

  final _streamController = StreamController<List<DestinationAdminModel>>.broadcast();
  bool _isSeeded = false;

  DestinationsRepository() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('destinations').orderBy('order').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _destinations.clear();
            for (final doc in snapshot.docs) {
              _destinations.add(DestinationAdminModel.fromMap(doc.data(), doc.id));
            }
            _notify();
          } else if (!_isSeeded) {
            _isSeeded = true;
            seedInitialDestinations();
          }
        },
        onError: (e) {
          dev.log('Firestore destinations listener error: $e', name: 'DestinationsRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore destinations: $e', name: 'DestinationsRepository');
      _notify();
    }
  }

  Future<void> seedInitialDestinations({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('destinations').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final dest in _destinations) {
        final docRef = _firestore.collection('destinations').doc(dest.id);
        batch.set(docRef, dest.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      dev.log('Initial destinations seeded successfully to Firestore', name: 'DestinationsRepository');
    } catch (e) {
      dev.log('Error seeding initial destinations to Firestore: $e', name: 'DestinationsRepository');
    }
  }

  void _notify() {
    _destinations.sort((a, b) => a.order.compareTo(b.order));
    _streamController.add(List.unmodifiable(_destinations));
  }

  Stream<List<DestinationAdminModel>> watchDestinations() {
    return Stream<List<DestinationAdminModel>>.multi((controller) {
      _destinations.sort((a, b) => a.order.compareTo(b.order));
      controller.add(List.unmodifiable(_destinations));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<DestinationAdminModel> get currentDestinations => List.unmodifiable(_destinations);

  Future<DestinationAdminModel?> getDestinationById(String id) async {
    try {
      final doc = await _firestore.collection('destinations').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final dest = DestinationAdminModel.fromMap(doc.data()!, doc.id);
        final idx = _destinations.indexWhere((d) => d.id == id);
        if (idx >= 0) {
          _destinations[idx] = dest;
        } else {
          _destinations.add(dest);
        }
        return dest;
      }
    } catch (e) {
      dev.log('Error fetching destination $id from Firestore: $e', name: 'DestinationsRepository');
    }

    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveDestination(DestinationAdminModel destination) async {
    final newId = destination.id.isNotEmpty ? destination.id : 'dest_${DateTime.now().millisecondsSinceEpoch}';
    final index = _destinations.indexWhere((d) => d.id == newId || (destination.id.isNotEmpty && d.id == destination.id));
    final finalOrder = destination.order > 0 ? destination.order : (index >= 0 ? _destinations[index].order : _destinations.length);
    final finalDest = destination.copyWith(
      id: newId,
      order: finalOrder,
      createdAt: destination.createdAt ?? (index >= 0 ? _destinations[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _destinations[index] = finalDest;
    } else {
      _destinations.add(finalDest);
    }
    _notify();

    try {
      await _firestore.collection('destinations').doc(newId).set(finalDest.toMap(), SetOptions(merge: true));
    } catch (e) {
      dev.log('Error saving destination $newId to Firestore: $e', name: 'DestinationsRepository');
      rethrow;
    }
  }

  Future<void> deleteDestination(String id) async {
    _destinations.removeWhere((d) => d.id == id);
    _notify();

    try {
      await _firestore.collection('destinations').doc(id).delete();
    } catch (e) {
      dev.log('Error deleting destination $id from Firestore: $e', name: 'DestinationsRepository');
      rethrow;
    }
  }

  Future<void> toggleDestinationStatus(String id, bool isActive) async {
    final index = _destinations.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _destinations[index] = _destinations[index].copyWith(isActive: isActive, updatedAt: DateTime.now());
      _notify();
    }

    try {
      await _firestore.collection('destinations').doc(id).update({
        'isActive': isActive,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      dev.log('Error toggling destination status in Firestore: $e', name: 'DestinationsRepository');
      rethrow;
    }
  }

  Future<void> updateDestinationsOrder(List<DestinationAdminModel> reordered) async {
    for (int i = 0; i < reordered.length; i++) {
      final item = reordered[i];
      final idx = _destinations.indexWhere((d) => d.id == item.id);
      if (idx >= 0) {
        _destinations[idx] = _destinations[idx].copyWith(order: i);
      }
    }
    _notify();

    try {
      final batch = _firestore.batch();
      for (int i = 0; i < reordered.length; i++) {
        final docRef = _firestore.collection('destinations').doc(reordered[i].id);
        batch.update(docRef, {'order': i});
      }
      await batch.commit();
    } catch (e) {
      dev.log('Error updating destinations order in Firestore: $e', name: 'DestinationsRepository');
      rethrow;
    }
  }
}
