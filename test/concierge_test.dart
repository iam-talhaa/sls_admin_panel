import 'package:flutter_test/flutter_test.dart';
import 'package:sls_admin/core/models/localized_text.dart';
import 'package:sls_admin/features/concierge/data/models/concierge_model.dart';
import 'package:sls_admin/features/concierge/data/services/concierge_service.dart';

void main() {
  group('Concierge Data Models', () {
    test('ConciergeBanner serialization and deserialization', () {
      const banner = ConciergeBanner(
        title: LocalizedText(en: 'Exclusive Concierge', fr: 'Conciergerie Exclusive'),
        subtitle: LocalizedText(en: 'VIP Ground & Hotel Solutions'),
        imageUrl: 'assets/conciergeService.png',
      );

      final map = banner.toMap();
      final fromMap = ConciergeBanner.fromMap(map);

      expect(fromMap.title.en, equals('Exclusive Concierge'));
      expect(fromMap.title.fr, equals('Conciergerie Exclusive'));
      expect(fromMap.subtitle.en, equals('VIP Ground & Hotel Solutions'));
      expect(fromMap.imageUrl, equals('assets/conciergeService.png'));
    });

    test('ConciergeFeature serialization and deserialization', () {
      const feature = ConciergeFeature(
        id: 'feat_test_1',
        sortOrder: 1,
        text: LocalizedText(en: 'Direct tarmac pickup', fr: 'Prise en charge directe sur le tarmac'),
      );

      final map = feature.toMap();
      final fromMap = ConciergeFeature.fromMap(map);

      expect(fromMap.id, equals('feat_test_1'));
      expect(fromMap.sortOrder, equals(1));
      expect(fromMap.text.en, equals('Direct tarmac pickup'));
      expect(fromMap.text.fr, equals('Prise en charge directe sur le tarmac'));
    });

    test('ConciergeCategory serialization and nested features', () {
      const category = ConciergeCategory(
        id: 'cat_test_1',
        slug: 'hotel-booking',
        sortOrder: 1,
        tabTitle: LocalizedText(en: 'Hotel Booking', de: 'Hotelbuchung'),
        categoryTag: LocalizedText(en: 'LUXURY ACCOMMODATION'),
        title: LocalizedText(en: '5-Star Hotel & Chalet Reservations'),
        description: LocalizedText(en: 'Exclusive suites and private chalets.'),
        imageUrl: 'assets/hotelBooking.png',
        isActive: true,
        features: [
          ConciergeFeature(
            id: 'f1',
            sortOrder: 1,
            text: LocalizedText(en: 'Room upgrades upon availability'),
          ),
          ConciergeFeature(
            id: 'f2',
            sortOrder: 2,
            text: LocalizedText(en: '24/7 dedicated butler'),
          ),
        ],
      );

      final map = category.toMap();
      final fromMap = ConciergeCategory.fromMap(map, 'cat_test_1');

      expect(fromMap.id, equals('cat_test_1'));
      expect(fromMap.slug, equals('hotel-booking'));
      expect(fromMap.tabTitle.en, equals('Hotel Booking'));
      expect(fromMap.tabTitle.de, equals('Hotelbuchung'));
      expect(fromMap.categoryTag.en, equals('LUXURY ACCOMMODATION'));
      expect(fromMap.isActive, isTrue);
      expect(fromMap.features.length, equals(2));
      expect(fromMap.features.first.text.en, equals('Room upgrades upon availability'));
      expect(fromMap.features[1].id, equals('f2'));
    });
  });

  group('ConciergeService Mock Layer', () {
    late ConciergeService service;

    setUp(() {
      service = ConciergeService();
    });

    test('getBanner returns seeded hero banner', () async {
      final banner = await service.getBanner();
      expect(banner.title.en, isNotEmpty);
      expect(banner.imageUrl, equals('assets/conciergeService.png'));
    });

    test('updateBanner updates the current hero banner', () async {
      const newBanner = ConciergeBanner(
        title: LocalizedText(en: 'Updated Concierge Title'),
        subtitle: LocalizedText(en: 'Updated Subtitle'),
        imageUrl: 'assets/new_banner.png',
      );

      await service.updateBanner(newBanner);
      final fetched = await service.getBanner();
      expect(fetched.title.en, equals('Updated Concierge Title'));
      expect(fetched.imageUrl, equals('assets/new_banner.png'));
    });

    test('listCategories returns 5 seeded categories sorted by sortOrder', () async {
      final categories = await service.listCategories();
      expect(categories.length, greaterThanOrEqualTo(5));
      for (int i = 0; i < categories.length - 1; i++) {
        expect(categories[i].sortOrder, lessThanOrEqualTo(categories[i + 1].sortOrder));
      }
    });

    test('Category CRUD operations and active status toggle', () async {
      // 1. Create
      const newCat = ConciergeCategory(
        id: 'cat_custom_test',
        slug: 'custom-service',
        sortOrder: 10,
        tabTitle: LocalizedText(en: 'Custom Luxury'),
        title: LocalizedText(en: 'Custom Luxury Solutions'),
        isActive: true,
      );
      final created = await service.createCategory(newCat);
      expect(created.id, equals('cat_custom_test'));

      // 2. Read
      final fetched = await service.getCategory('cat_custom_test');
      expect(fetched, isNotNull);
      expect(fetched!.tabTitle.en, equals('Custom Luxury'));

      // 3. Update
      final updated = fetched.copyWith(
        tabTitle: const LocalizedText(en: 'Custom Luxury Modified'),
      );
      await service.updateCategory(updated);
      final afterUpdate = await service.getCategory('cat_custom_test');
      expect(afterUpdate?.tabTitle.en, equals('Custom Luxury Modified'));

      // 4. Toggle status
      await service.toggleCategoryStatus('cat_custom_test', false);
      final afterToggle = await service.getCategory('cat_custom_test');
      expect(afterToggle?.isActive, isFalse);

      // 5. Delete
      await service.deleteCategory('cat_custom_test');
      final afterDelete = await service.getCategory('cat_custom_test');
      expect(afterDelete, isNull);
    });

    test('Feature CRUD and reorder operations', () async {
      final categories = await service.listCategories();
      final targetCat = categories.first;

      // 1. Add feature
      const newFeature = ConciergeFeature(
        id: 'feat_test_new',
        sortOrder: 99,
        text: LocalizedText(en: 'New Test Feature'),
      );
      final added = await service.addFeature(targetCat.id, newFeature);
      expect(added.id, equals('feat_test_new'));

      var cat = await service.getCategory(targetCat.id);
      expect(cat?.features.any((f) => f.id == 'feat_test_new'), isTrue);

      // 2. Update feature
      await service.updateFeature(
        targetCat.id,
        const ConciergeFeature(
          id: 'feat_test_new',
          sortOrder: 99,
          text: LocalizedText(en: 'Updated Test Feature'),
        ),
      );
      cat = await service.getCategory(targetCat.id);
      expect(
        cat?.features.firstWhere((f) => f.id == 'feat_test_new').text.en,
        equals('Updated Test Feature'),
      );

      // 3. Delete feature
      await service.deleteFeature(targetCat.id, 'feat_test_new');
      cat = await service.getCategory(targetCat.id);
      expect(cat?.features.any((f) => f.id == 'feat_test_new'), isFalse);
    });
  });
}
