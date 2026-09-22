import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/localized_text.dart';
import '../models/home_content_model.dart';

final homeContentRepositoryProvider = Provider<HomeContentRepository>((ref) {
  return HomeContentRepository();
});

final homeContentStreamProvider = StreamProvider<HomeContentAdminModel>((ref) {
  return ref.watch(homeContentRepositoryProvider).watchHomeContent();
});

class HomeContentRepository {
  HomeContentAdminModel _homeContent = const HomeContentAdminModel(
    routeCards: [
      RouteCardAdminModel(
        id: 'card_1',
        title: LocalizedText(en: 'Davos Ski Escape', fr: 'Séjour ski à Davos', de: 'Ski-Urlaub in Davos', ar: 'عطلة تزلج في دافوس'),
        category: LocalizedText(en: 'SWISS ALPS', fr: 'ALPES SUISSES', de: 'SCHWEIZER ALPEN', ar: 'جبال الألب السويسرية'),
        duration: '1 hr 10 min',
        imageUrl: 'assets/des1.jpg',
        overlayTag: LocalizedText(en: 'POPULAR ROUTE', fr: 'ROUTE POPULAIRE', de: 'BELIEBTE ROUTE', ar: 'مسار مميز'),
      ),
      RouteCardAdminModel(
        id: 'card_2',
        title: LocalizedText(en: 'Zurich to London', fr: 'Zurich vers Londres', de: 'Zürich nach London', ar: 'من زيورخ إلى لندن'),
        category: LocalizedText(en: 'BUSINESS & CULTURE', fr: 'AFFAIRES ET CULTURE', de: 'WIRTSCHAFT & KULTUR', ar: 'أعمال وثقافة'),
        duration: '1 hr 40 min',
        imageUrl: 'assets/des4.png',
        overlayTag: LocalizedText(en: 'VIP CHARTER', fr: 'VOL VIP', de: 'VIP CHARTER', ar: 'شارتر VIP'),
      ),
    ],
    stats: [
      HomeStatAdminModel(
        count: '150+',
        label: LocalizedText(en: 'Private Destinations', fr: 'Destinations Privées', de: 'Private Reiseziele', ar: 'وجهات خاصة'),
      ),
      HomeStatAdminModel(
        count: '99.8%',
        label: LocalizedText(en: 'On-Time VIP Departures', fr: 'Départs VIP à l\'heure', de: 'Pünktliche VIP-Abflüge', ar: 'دقة المواعيد'),
      ),
      HomeStatAdminModel(
        count: '24/7',
        label: LocalizedText(en: 'Dedicated Concierge', fr: 'Conciergerie Dédiée', de: 'Dedizierter Concierge', ar: 'خدمة كونسيرج 24/7'),
      ),
    ],
  );

  final _streamController = StreamController<HomeContentAdminModel>.broadcast();

  HomeContentRepository() {
    _streamController.add(_homeContent);
  }

  Stream<HomeContentAdminModel> watchHomeContent() {
    return Stream<HomeContentAdminModel>.multi((controller) {
      controller.add(_homeContent);
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  Future<HomeContentAdminModel> getHomeContent() async {
    return _homeContent;
  }

  Future<void> saveHomeContent(HomeContentAdminModel model) async {
    _homeContent = model;
    _streamController.add(_homeContent);
  }
}
