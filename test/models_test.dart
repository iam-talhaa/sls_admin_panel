import 'package:flutter_test/flutter_test.dart';
import 'package:sls_admin/core/models/content_block.dart';
import 'package:sls_admin/core/models/localized_text.dart';
import 'package:sls_admin/features/blog/data/models/blog_admin_model.dart';
import 'package:sls_admin/features/destinations/data/models/destination_admin_model.dart';
import 'package:sls_admin/features/fleet/data/models/jet_admin_model.dart';

void main() {
  group('Fleet Jet Model', () {
    test('JetAdminModel serialization and deserialization', () {
      final now = DateTime.now();
      final jet = JetAdminModel(
        id: 'jet_test_1',
        order: 1,
        category: 'LIGHT JET',
        imageUrl: 'https://example.com/jet.png',
        name: const LocalizedText(en: 'Test Jet', fr: 'Jet Test'),
        seating: const LocalizedText(en: '4 Seats'),
        range: const LocalizedText(en: '2.5 Hours'),
        description: const LocalizedText(en: 'A fast light jet'),
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = jet.toMap();
      final fromMap = JetAdminModel.fromMap(map, 'jet_test_1');

      expect(fromMap.id, equals('jet_test_1'));
      expect(fromMap.name.en, equals('Test Jet'));
      expect(fromMap.name.fr, equals('Jet Test'));
      expect(fromMap.category, equals('LIGHT JET'));
      expect(fromMap.isActive, isTrue);
      expect(fromMap.order, equals(1));
    });
  });

  group('Destination Model', () {
    test('DestinationAdminModel serialization with content blocks and highlights', () {
      final destination = DestinationAdminModel(
        id: 'dest_test_1',
        order: 2,
        title: const LocalizedText(en: 'Zurich to Davos'),
        category: const LocalizedText(en: 'ALPINE'),
        duration: '1 hr',
        imageUrl: 'https://example.com/davos.jpg',
        overlayTag: const LocalizedText(en: 'WEF Special'),
        description: const LocalizedText(en: 'Exclusive Swiss Alps travel experience into Davos.'),
        whyTravelWithUs: const [
          LocalizedText(en: 'Direct landing'),
          LocalizedText(en: 'VIP chauffeur'),
        ],
        contentBlocks: const [
          ContentBlock(
            type: ContentBlockType.paragraph,
            text: LocalizedText(en: 'Welcome to Davos'),
          ),
        ],
      );

      final map = destination.toMap();
      final fromMap = DestinationAdminModel.fromMap(map, 'dest_test_1');

      expect(fromMap.id, equals('dest_test_1'));
      expect(fromMap.title.en, equals('Zurich to Davos'));
      expect(fromMap.description.en, equals('Exclusive Swiss Alps travel experience into Davos.'));
      expect(fromMap.whyTravelWithUs.length, equals(2));
      expect(fromMap.contentBlocks.length, equals(1));
      expect(fromMap.contentBlocks.first.type, equals(ContentBlockType.paragraph));
    });
  });

  group('Blog Model', () {
    test('BlogAdminModel serialization with timestamps and publish status', () {
      final now = DateTime.now();
      final blog = BlogAdminModel(
        id: 'blog_test_1',
        title: const LocalizedText(en: 'Luxury Travel in 2026'),
        excerpt: const LocalizedText(en: 'Trends in private aviation'),
        imageUrl: 'https://example.com/blog.png',
        isPublished: true,
        publishedAt: now,
        createdAt: now,
      );

      final map = blog.toMap();
      final fromMap = BlogAdminModel.fromMap(map, 'blog_test_1');

      expect(fromMap.id, equals('blog_test_1'));
      expect(fromMap.title.en, equals('Luxury Travel in 2026'));
      expect(fromMap.isPublished, isTrue);
      expect(fromMap.publishedAt, isNotNull);
    });
  });
}
