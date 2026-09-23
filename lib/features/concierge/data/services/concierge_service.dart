import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/localized_text.dart';
import '../models/concierge_model.dart';

// ==============================================================================
// HANDOFF NOTE FOR BACKEND INTEGRATION:
// This is a stand-in mock service for Concierge Services content management.
// When connecting to the real backend, replace the local in-memory store in this
// service with HTTP client calls (e.g. Dio or http) to endpoints matching:
//   - GET    /api/admin/concierge/banner
//   - PUT    /api/admin/concierge/banner
//   - GET    /api/admin/concierge/categories
//   - GET    /api/admin/concierge/categories/:id
//   - POST   /api/admin/concierge/categories
//   - PUT    /api/admin/concierge/categories/:id
//   - DELETE /api/admin/concierge/categories/:id
//   - PUT    /api/admin/concierge/categories/reorder
//   - POST   /api/admin/concierge/categories/:id/features
//   - PUT    /api/admin/concierge/categories/:id/features/:featureId
//   - DELETE /api/admin/concierge/categories/:id/features/:featureId
//   - PUT    /api/admin/concierge/categories/:id/features/reorder
// ==============================================================================

final conciergeServiceProvider = Provider<ConciergeService>((ref) {
  return ConciergeService();
});

final conciergeBannerStreamProvider = StreamProvider<ConciergeBanner>((ref) {
  final service = ref.watch(conciergeServiceProvider);
  return service.bannerStream;
});

final conciergeCategoriesStreamProvider = StreamProvider<List<ConciergeCategory>>((ref) {
  final service = ref.watch(conciergeServiceProvider);
  return service.categoriesStream;
});

class ConciergeService {
  // Singleton in-memory state so changes persist across screen navigations during the session
  static ConciergeBanner _banner = const ConciergeBanner(
    title: LocalizedText(
      en: 'Bespoke Luxury & Concierge Services',
      fr: 'Services de Conciergerie de Luxe sur Mesure',
      de: 'Maßgeschneiderte Luxus- und Concierge-Dienste',
      ar: 'خدمات الكونسيرج الفاخرة والمخصصة',
    ),
    subtitle: LocalizedText(
      en: 'Seamless 5-star hotel reservations, private chauffeur transfers, VIP ground assistance, diplomatic support, and curated global itineraries.',
      fr: 'Réservations d\'hôtels 5 étoiles, transferts privés, assistance VIP au sol, soutien diplomatique et itinéraires mondiaux sur mesure.',
      de: 'Nahtlose 5-Sterne-Hotelreservierungen, private Chauffeur-Transfers, VIP-Bodenbetreuung, diplomatische Unterstützung und kuratierte Reiserouten.',
      ar: 'حجوزات سلسة في فنادق 5 نجوم، وتنقلات خاصة بسائق، ومساعدة كبار الشخصيات على أرض المطار، ودعم دبلوماسي، وبرامج رحلات مصممة بعناية.',
    ),
    imageUrl: 'assets/conciergeService.png',
  );

  static List<ConciergeCategory> _categories = [
    const ConciergeCategory(
      id: 'cat_hotel_booking',
      slug: 'hotel-booking',
      sortOrder: 1,
      tabTitle: LocalizedText(
        en: 'Hotel Booking',
        fr: 'Réservation d\'Hôtel',
        de: 'Hotelbuchung',
        ar: 'حجز الفنادق',
      ),
      categoryTag: LocalizedText(
        en: 'LUXURY ACCOMMODATION',
        fr: 'HÉBERGEMENT DE LUXE',
        de: 'LUXUSUNTERKÜNFTE',
        ar: 'إقامة فاخرة',
      ),
      title: LocalizedText(
        en: 'Bespoke 5-Star Hotel & Private Chalet Reservations',
        fr: 'Réservations d\'Hôtels 5 Étoiles et Chalets Privés',
        de: 'Exklusive 5-Sterne-Hotels und private Chalet-Buchungen',
        ar: 'حجوزات مخصصة في فنادق 5 نجوم وشاليهات خاصة',
      ),
      description: LocalizedText(
        en: 'Privileged access and elite partnerships with world-renowned luxury hotel brands, private alpine ski chalets, and private island villas with VIP status amenities.',
        fr: 'Accès privilégié et partenariats d\'élite avec des hôtels de luxe de renommée mondiale, des chalets alpins privés et des villas insulaires.',
        de: 'Privilegierter Zugang und Partnerschaften mit weltweit führenden Luxushotels, privaten Skichalets in den Alpen und exklusiven Inselvillen.',
        ar: 'وصول متميز وشراكات نخبوية مع أرقى العلامات الفندقية العالمية والشاليهات الجبلية الخاصة والفلل في الجزر الخاصة مع مزايا كبار الشخصيات.',
      ),
      imageUrl: 'assets/hotelBooking.png',
      isActive: true,
      features: [
        ConciergeFeature(
          id: 'feat_hb_1',
          sortOrder: 1,
          text: LocalizedText(
            en: 'Complimentary room and presidential suite upgrades upon availability',
            fr: 'Surclassement gratuit en chambre ou suite présidentielle selon disponibilité',
            de: 'Kostenlose Upgrades auf Zimmer und Präsidentensuiten nach Verfügbarkeit',
            ar: 'ترقيات مجانية للغرف والأجنحة الرئاسية حسب التوفر',
          ),
        ),
        ConciergeFeature(
          id: 'feat_hb_2',
          sortOrder: 2,
          text: LocalizedText(
            en: 'Guaranteed flexible early check-in and late checkout privileges',
            fr: 'Arrivée anticipée et départ tardif flexibles garantis',
            de: 'Garantierte flexible Früh-Check-ins und Spät-Check-outs',
            ar: 'مزايا مضمونة لتسجيل الوصول المبكر والمغادرة المتأخرة بمرونة',
          ),
        ),
        ConciergeFeature(
          id: 'feat_hb_3',
          sortOrder: 3,
          text: LocalizedText(
            en: 'Dedicated 24/7 private butler and bespoke welcome amenities',
            fr: 'Majordome privé dédié 24/7 et cadeaux de bienvenue sur mesure',
            de: 'Dedizierter 24/7 Privat-Butler und maßgeschneiderte Begrüßungsannehmlichkeiten',
            ar: 'خادم شخصي مخصص على مدار الساعة وهدايا ترحيبية فاخرة',
          ),
        ),
        ConciergeFeature(
          id: 'feat_hb_4',
          sortOrder: 4,
          text: LocalizedText(
            en: 'Exclusive access to sold-out private chalets in St. Moritz, Gstaad & Courchevel',
            fr: 'Accès exclusif aux chalets privés à Saint-Moritz, Gstaad et Courchevel',
            de: 'Exklusiver Zugang zu ausgebuchten privaten Chalets in St. Moritz, Gstaad und Courchevel',
            ar: 'وصول حصري إلى شاليهات خاصة في سان موريتز وغشتاد وكورشوفيل',
          ),
        ),
      ],
    ),
    const ConciergeCategory(
      id: 'cat_chauffeur_services',
      slug: 'chauffeur-services',
      sortOrder: 2,
      tabTitle: LocalizedText(
        en: 'Chauffeur Services',
        fr: 'Services de Chauffeur',
        de: 'Chauffeur-Dienste',
        ar: 'خدمات السائق الخاص',
      ),
      categoryTag: LocalizedText(
        en: 'EXECUTIVE MOBILITY',
        fr: 'MOBILITÉ EXÉCUTIVE',
        de: 'EXECUTIVE MOBILITÄT',
        ar: 'تنقل تنفيذي فاخر',
      ),
      title: LocalizedText(
        en: 'Tarmac-Side Chauffeur & Armored Fleet Transfers',
        fr: 'Transferts en Chauffeur Tarmac et Véhicules Blindés',
        de: 'Rollfeld-Chauffeur und gepanzerte Fahrzeugtransfers',
        ar: 'خدمة السائق على مدرج المطار وتنقلات السيارات المصفحة',
      ),
      description: LocalizedText(
        en: 'Direct aircraft-to-car airside pick-up in pristine luxury sedans, armored SUVs, and executive vans staffed by discreet, security-cleared multi-lingual chauffeurs.',
        fr: 'Prise en charge directe au pied de l\'avion en berlines de luxe, SUV blindés et vans exécutifs avec chauffeurs discrets et polyglottes.',
        de: 'Direkte Abholung vom Flugzeug am Rollfeld in Luxuslimousinen, gepanzerten SUVs und Executive Vans mit diskreten, geschulten Chauffeuren.',
        ar: 'استقبال مباشر من باب الطائرة بسيارات سيدان فاخرة وسيارات دفع رباعي مصفحة وفانات تنفيذية مع سائقين محترفين متعددي اللغات.',
      ),
      imageUrl: 'assets/concierge2.png',
      isActive: true,
      features: [
        ConciergeFeature(
          id: 'feat_cs_1',
          sortOrder: 1,
          text: LocalizedText(
            en: 'Direct tarmac-side aircraft pickup and airside luggage transfer',
            fr: 'Prise en charge directe sur le tarmac et transfert des bagages',
            de: 'Direkte Rollfeld-Abholung am Jet und Vorfeld-Gepäcktransfer',
            ar: 'استقبال مباشر من مدرج المطار ونقل الأمتعة بسلاسة',
          ),
        ),
        ConciergeFeature(
          id: 'feat_cs_2',
          sortOrder: 2,
          text: LocalizedText(
            en: 'High-security armored vehicle fleet (VR7/VR9 ballistic protection)',
            fr: 'Flotte de véhicules blindés haute sécurité (protection balistique VR7/VR9)',
            de: 'Hochsichere gepanzerte Fahrzeugflotte (Ballistischer Schutz VR7/VR9)',
            ar: 'أسطول سيارات مصفحة عالية الأمان (حماية باليستية VR7/VR9)',
          ),
        ),
        ConciergeFeature(
          id: 'feat_cs_3',
          sortOrder: 3,
          text: LocalizedText(
            en: 'Prestigious modern fleet: Mercedes-Maybach S-Class, Rolls-Royce, Cadillac Escalade',
            fr: 'Flotte prestigieuse: Mercedes-Maybach Classe S, Rolls-Royce, Cadillac Escalade',
            de: 'Exklusive Flotte: Mercedes-Maybach S-Klasse, Rolls-Royce, Cadillac Escalade',
            ar: 'أسطول سيارات فاخر وحديث: مرسيدس مايباخ، رولز رويس، كاديلاك إسكاليد',
          ),
        ),
        ConciergeFeature(
          id: 'feat_cs_4',
          sortOrder: 4,
          text: LocalizedText(
            en: 'Trained close-protection drivers and multi-lingual executive protocol',
            fr: 'Conducteurs formés à la protection rapprochée et protocole multilingue',
            de: 'Chauffeure mit Personenschutzausbildung und mehrsprachigem Protokoll',
            ar: 'سائقون مدربون على الحراسة الشخصية والبروتوكول الدولي بعدة لغات',
          ),
        ),
      ],
    ),
    const ConciergeCategory(
      id: 'cat_ground_handling',
      slug: 'ground-handling',
      sortOrder: 3,
      tabTitle: LocalizedText(
        en: 'Ground Handling',
        fr: 'Assistance au Sol',
        de: 'Bodenabfertigung',
        ar: 'المناولة الأرضية',
      ),
      categoryTag: LocalizedText(
        en: 'AVIATION OPERATIONS',
        fr: 'OPÉRATIONS AÉRONAUTIQUES',
        de: 'LUFTFAHRT-OPERATIONEN',
        ar: 'عمليات الطيران',
      ),
      title: LocalizedText(
        en: 'VIP Terminal & Comprehensive FBO Ground Assistance',
        fr: 'Terminal VIP et Assistance FBO Complète au Sol',
        de: 'VIP-Terminal und umfassende FBO-Bodenbetreuung',
        ar: 'مساعدة كبار الشخصيات في صالات الطيران الخاص والمناولة الأرضية',
      ),
      description: LocalizedText(
        en: 'Flawless execution of VIP ramp handling, accelerated customs & immigration protocol, private lounge management, jet refueling, and secure hangarage worldwide.',
        fr: 'Exécution fluide de l\'assistance en piste VIP, dédouanement accéléré, salons privés, avitaillement et hangars sécurisés.',
        de: 'Reibungslose VIP-Vorfeldabfertigung, beschleunigte Zoll- und Einreiseprotokolle, VIP-Lounges, Betankung und sichere Hangars weltweit.',
        ar: 'تنفيذ احترافي للمناولة الأرضية، وإجراءات جمارك وجوازات سريعة، وصالات خاصة، وتزويد الطائرات بالوقود، ومواقف حظائر آمنة.',
      ),
      imageUrl: 'assets/concierge3.png',
      isActive: true,
      features: [
        ConciergeFeature(
          id: 'feat_gh_1',
          sortOrder: 1,
          text: LocalizedText(
            en: 'Expedited private VIP customs and passport immigration clearance',
            fr: 'Passage douanier et contrôle des passeports VIP express',
            de: 'Beschleunigte VIP-Zoll- und Passkontrollabfertigung',
            ar: 'تخليص سريع وخاص لإجراءات الجمارك والجوازات لكبار الشخصيات',
          ),
        ),
        ConciergeFeature(
          id: 'feat_gh_2',
          sortOrder: 2,
          text: LocalizedText(
            en: 'Dedicated baggage concierge with direct aircraft-to-destination transit',
            fr: 'Concierge bagages dédié avec transit direct avion-destination',
            de: 'Dedizierter Gepäck-Concierge mit direktem Transfer zum Zielort',
            ar: 'خدمة نقل أمتعة مخصصة ومباشرة من الطائرة إلى وجهة الإقامة',
          ),
        ),
        ConciergeFeature(
          id: 'feat_gh_3',
          sortOrder: 3,
          text: LocalizedText(
            en: 'Private FBO salon suites and gourmet crew catering lounge access',
            fr: 'Salons privés FBO et espace détente équipage avec restauration gastronomique',
            de: 'Private FBO-Suiten und Gourmet-Catering für Passagiere und Crew',
            ar: 'أجنحة صالات طيران خاص فاخرة وضيافة متكاملة للطاقم والركاب',
          ),
        ),
        ConciergeFeature(
          id: 'feat_gh_4',
          sortOrder: 4,
          text: LocalizedText(
            en: 'Guaranteed aircraft slot coordination, hangarage and rapid turnarounds',
            fr: 'Coordination des créneaux, hangars sécurisés et rotations rapides',
            de: 'Garantierte Slot-Koordination, Unterstellung und schnelle Turnarounds',
            ar: 'تنسيق مواعيد الهبوط والإقلاع وتوفير حظائر آمنة وسرعة تجهيز الطائرة',
          ),
        ),
      ],
    ),
    const ConciergeCategory(
      id: 'cat_diplomatic_support',
      slug: 'diplomatic-support',
      sortOrder: 4,
      tabTitle: LocalizedText(
        en: 'Diplomatic Support',
        fr: 'Soutien Diplomatique',
        de: 'Diplomatische Hilfe',
        ar: 'الدعم الدبلوماسي',
      ),
      categoryTag: LocalizedText(
        en: 'DIPLOMACY & PROTOCOL',
        fr: 'DIPLOMATIE & PROTOCOLE',
        de: 'DIPLOMATIE & PROTOKOLL',
        ar: 'الدبلوماسية والبروتوكول',
      ),
      title: LocalizedText(
        en: 'Embassy Protocol, Delegation Logistics & Security Clearance',
        fr: 'Protocole d\'Ambassade, Logistique de Délégation et Sécurité',
        de: 'Botschaftsprotokoll, Delegationslogistik und Sicherheitsfreigaben',
        ar: 'بروتوكول السفارات ولوجستيات الوفود الرسمية والتصاريح الأمنية',
      ),
      description: LocalizedText(
        en: 'Specialized protocol management for heads of state, royal families, foreign ministries, and government delegations requiring highest discretion and diplomatic immunity support.',
        fr: 'Gestion spécialisée du protocole pour chefs d\'État, familles royales et délégations gouvernementales avec discrétion absolue.',
        de: 'Spezialisiertes Protokollmanagement für Staatsoberhäupter, Königsfamilien und Delegationen mit höchster Diskretion.',
        ar: 'إدارة متخصصة للبروتوكول لرؤساء الدول والأسر الحاكمة والوفود الحكومية مع أقصى درجات السرية والحصانة الدبلوماسية.',
      ),
      imageUrl: 'assets/concierge4.png',
      isActive: true,
      features: [
        ConciergeFeature(
          id: 'feat_ds_1',
          sortOrder: 1,
          text: LocalizedText(
            en: 'Expedited diplomatic clearances, overflight & urgent landing permits',
            fr: 'Autorisations diplomatiques rapides, survols et permis d\'atterrissage urgents',
            de: 'Beschleunigte diplomatische Überflug- und Landegenehmigungen',
            ar: 'تصاريح هبوط وعبور جوي دبلوماسية عاجلة وتخليص فوري',
          ),
        ),
        ConciergeFeature(
          id: 'feat_ds_2',
          sortOrder: 2,
          text: LocalizedText(
            en: 'Coordinated police motorcades, armed escorts and secure route planning',
            fr: 'Cortèges officiels escortés, protection armée et itinéraires sécurisés',
            de: 'Polizeieskorten, bewaffneter Begleitschutz und sichere Routenplanung',
            ar: 'مواكب رسمية بمرافقة أمنية وتخطيط مسارات آمنة للوفود',
          ),
        ),
        ConciergeFeature(
          id: 'feat_ds_3',
          sortOrder: 3,
          text: LocalizedText(
            en: 'Strict adherence to international diplomatic state protocol and honors',
            fr: 'Respect strict du protocole d\'État international et honneurs officiels',
            de: 'Strikte Einhaltung des internationalen Staatsprotokolls',
            ar: 'التزام تام بالبروتوكول الدبلوماسي والمراسم الرسمية الدولية',
          ),
        ),
        ConciergeFeature(
          id: 'feat_ds_4',
          sortOrder: 4,
          text: LocalizedText(
            en: 'Encrypted communication lines and secure staging facilities',
            fr: 'Lignes de communication cryptées et installations sécurisées',
            de: 'Verschlüsselte Kommunikationskanäle und gesicherte Einrichtungen',
            ar: 'قنوات اتصال مشفرة ومرافق استقبال آمنة وخاصة',
          ),
        ),
      ],
    ),
    const ConciergeCategory(
      id: 'cat_vip_travel',
      slug: 'vip-travel-solutions',
      sortOrder: 5,
      tabTitle: LocalizedText(
        en: 'VIP Travel Solutions',
        fr: 'Solutions VIP',
        de: 'VIP-Reiselösungen',
        ar: 'حلول السفر الحصرية',
      ),
      categoryTag: LocalizedText(
        en: 'EXPERIENCES & LEISURE',
        fr: 'EXPÉRIENCES & LOISIRS',
        de: 'ERLEBNISSE & FREIZEIT',
        ar: 'تجارب وأنشطة حصرية',
      ),
      title: LocalizedText(
        en: 'Curated Superyacht Charters, Helicopter Transfers & Exclusive Access',
        fr: 'Yachts de Luxe, Transferts en Hélicoptère et Accès Exclusifs',
        de: 'Superyacht-Charter, Helikopter-Transfers und exklusiver Zugang',
        ar: 'تأجير اليخوت الفاخرة ورحلات الهليكوبتر والدخول الحصري للفعاليات',
      ),
      description: LocalizedText(
        en: 'Ultra-exclusive luxury lifestyle orchestration including Mediterranean and Caribbean mega-yacht charters, alpine helicopter transfers, private island buyouts, and red-carpet event access.',
        fr: 'Orchestration de style de vie ultra-exclusif incluant méga-yachts, hélicoptères alpins, îles privées et accès VIP aux galas.',
        de: 'Exklusive Lifestyle-Orchestrierung inklusive Megayacht-Charter, Helikoptertransfers in den Alpen, Privatinseln und VIP-Eventzugang.',
        ar: 'تنظيم تجارب معيشية فاخرة تشمل تأجير اليخوت الضخمة، وتنقلات الهليكوبتر الجبلية، وحجز الجزر الخاصة، وحضور الفعاليات العالمية الكبرى.',
      ),
      imageUrl: 'assets/concierge5.png',
      isActive: true,
      features: [
        ConciergeFeature(
          id: 'feat_vip_1',
          sortOrder: 1,
          text: LocalizedText(
            en: 'Superyacht charters in French Riviera, Amalfi Coast, Ibiza & Caribbean',
            fr: 'Location de superyachts sur la Côte d\'Azur, la côte amalfitaine, Ibiza et les Caraïbes',
            de: 'Superyacht-Charter an der Côte d\'Azur, Amalfiküste, Ibiza und Karibik',
            ar: 'تأجير يخوت فاخرة في الريفيرا الفرنسية، ساحل أمالفي، إيبيزا، والكاريبي',
          ),
        ),
        ConciergeFeature(
          id: 'feat_vip_2',
          sortOrder: 2,
          text: LocalizedText(
            en: 'Direct alpine helicopter transfers from Geneva/Zurich directly to ski slopes',
            fr: 'Transferts directs en hélicoptère depuis Genève/Zurich vers les pistes de ski',
            de: 'Direkte Helikopter-Transfers von Genf/Zürich direkt auf die Skipiste',
            ar: 'رحلات هليكوبتر مباشرة من جنيف وزيورخ إلى منحدرات التزلج في جبال الألب',
          ),
        ),
        ConciergeFeature(
          id: 'feat_vip_3',
          sortOrder: 3,
          text: LocalizedText(
            en: 'VIP passes for Monaco GP, Cannes Film Festival, Art Basel & WEF Davos',
            fr: 'Pass VIP pour le GP de Monaco, Festival de Cannes, Art Basel et WEF Davos',
            de: 'VIP-Zugang zu Formel 1 Monaco, Filmfestspiele Cannes, Art Basel und WEF Davos',
            ar: 'تذاكر VIP حصرية لسباق موناكو للفورمولا 1، ومهرجان كان، وآرت بازل، ومنتدى دافوس',
          ),
        ),
        ConciergeFeature(
          id: 'feat_vip_4',
          sortOrder: 4,
          text: LocalizedText(
            en: 'Private Michelin-starred chef catering and rare vintage wine cellaring',
            fr: 'Chefs étoilés Michelin privés et approvisionnement en grands crus',
            de: 'Private Michelin-Sterneköche und exklusive Jahrgangswein-Beschaffung',
            ar: 'طهاة حاصلون على نجوم ميشلان للخدمة الخاصة وتوفير أرقى المشروبات الفاخرة',
          ),
        ),
      ],
    ),
  ];

  final _bannerController = StreamController<ConciergeBanner>.broadcast();
  final _categoriesController = StreamController<List<ConciergeCategory>>.broadcast();

  Stream<ConciergeBanner> get bannerStream {
    // Emit current state immediately
    Timer.run(() => _bannerController.add(_banner));
    return _bannerController.stream;
  }

  Stream<List<ConciergeCategory>> get categoriesStream {
    // Emit current state sorted by sortOrder
    Timer.run(() {
      final sorted = List<ConciergeCategory>.from(_categories)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _categoriesController.add(sorted);
    });
    return _categoriesController.stream;
  }

  // Banner Operations
  Future<ConciergeBanner> getBanner() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _banner;
  }

  Future<void> updateBanner(ConciergeBanner banner) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _banner = banner;
    _bannerController.add(_banner);
  }

  // Category Operations
  Future<List<ConciergeCategory>> listCategories() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final sorted = List<ConciergeCategory>.from(_categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  Future<ConciergeCategory?> getCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ConciergeCategory> createCategory(ConciergeCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final newId = category.id.isNotEmpty
        ? category.id
        : 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final sortOrder = category.sortOrder > 0
        ? category.sortOrder
        : _categories.length + 1;

    final created = category.copyWith(
      id: newId,
      sortOrder: sortOrder,
    );

    _categories.add(created);
    _notifyCategoriesChanged();
    return created;
  }

  Future<ConciergeCategory> updateCategory(ConciergeCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      _categories[index] = category;
      _notifyCategoriesChanged();
      return category;
    } else {
      return createCategory(category);
    }
  }

  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _categories.removeWhere((c) => c.id == id);
    _recomputeSortOrders();
    _notifyCategoriesChanged();
  }

  Future<void> reorderCategories(List<ConciergeCategory> reordered) async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (int i = 0; i < reordered.length; i++) {
      reordered[i] = reordered[i].copyWith(sortOrder: i + 1);
    }
    _categories = List.from(reordered);
    _notifyCategoriesChanged();
  }

  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _categories.indexWhere((c) => c.id == id);
    if (index >= 0) {
      _categories[index] = _categories[index].copyWith(isActive: isActive);
      _notifyCategoriesChanged();
    }
  }

  // Feature Operations
  Future<ConciergeFeature> addFeature(String categoryId, ConciergeFeature feature) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex < 0) {
      throw Exception('Category $categoryId not found');
    }

    final category = _categories[catIndex];
    final featureId = feature.id.isNotEmpty
        ? feature.id
        : 'feat_${DateTime.now().millisecondsSinceEpoch}';
    final featureOrder = feature.sortOrder > 0
        ? feature.sortOrder
        : category.features.length + 1;

    final newFeature = feature.copyWith(id: featureId, sortOrder: featureOrder);
    final updatedFeatures = List<ConciergeFeature>.from(category.features)..add(newFeature);

    _categories[catIndex] = category.copyWith(features: updatedFeatures);
    _notifyCategoriesChanged();
    return newFeature;
  }

  Future<void> updateFeature(String categoryId, ConciergeFeature feature) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex < 0) return;

    final category = _categories[catIndex];
    final fIndex = category.features.indexWhere((f) => f.id == feature.id);
    if (fIndex >= 0) {
      final updatedFeatures = List<ConciergeFeature>.from(category.features);
      updatedFeatures[fIndex] = feature;
      _categories[catIndex] = category.copyWith(features: updatedFeatures);
      _notifyCategoriesChanged();
    }
  }

  Future<void> deleteFeature(String categoryId, String featureId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex < 0) return;

    final category = _categories[catIndex];
    final updatedFeatures = category.features.where((f) => f.id != featureId).toList();
    for (int i = 0; i < updatedFeatures.length; i++) {
      updatedFeatures[i] = updatedFeatures[i].copyWith(sortOrder: i + 1);
    }

    _categories[catIndex] = category.copyWith(features: updatedFeatures);
    _notifyCategoriesChanged();
  }

  Future<void> reorderFeatures(String categoryId, List<ConciergeFeature> features) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex < 0) return;

    final updatedFeatures = <ConciergeFeature>[];
    for (int i = 0; i < features.length; i++) {
      updatedFeatures.add(features[i].copyWith(sortOrder: i + 1));
    }

    _categories[catIndex] = _categories[catIndex].copyWith(features: updatedFeatures);
    _notifyCategoriesChanged();
  }

  void _recomputeSortOrders() {
    for (int i = 0; i < _categories.length; i++) {
      _categories[i] = _categories[i].copyWith(sortOrder: i + 1);
    }
  }

  void _notifyCategoriesChanged() {
    final sorted = List<ConciergeCategory>.from(_categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _categoriesController.add(sorted);
  }
}
