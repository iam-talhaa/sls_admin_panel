import 'dart:async';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/content_block.dart';
import '../../../../core/models/localized_text.dart';
import '../models/blog_admin_model.dart';

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  return BlogRepository();
});

final blogListStreamProvider = StreamProvider<List<BlogAdminModel>>((ref) {
  return ref.watch(blogRepositoryProvider).watchBlogs();
});

class BlogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<BlogAdminModel> _blogs = [
    BlogAdminModel(
      id: 'blog_alpine_guide',
      title: const LocalizedText(
        en: 'The Ultimate Guide to Private Jet Travel in the Swiss Alps',
        fr: 'Le guide ultime du voyage en jet privé dans les Alpes suisses',
        de: 'Der ultimative Leitfaden für Privatjet-Reisen in den Schweizer Alpen',
        ar: 'الدليل الشامل للسفر بالطيران الخاص في جبال الألب السويسرية',
      ),
      excerpt: const LocalizedText(
        en: 'Discover how Swiss Luxury Services provides seamless VIP aviation directly into Davos, St. Moritz, and Zurich with maximum discretion.',
        fr: 'Découvrez comment Swiss Luxury Services offre une aviation VIP fluide directement vers Davos et Saint-Moritz.',
        de: 'Erfahren Sie, wie Swiss Luxury Services nahtlose VIP-Flüge direkt nach Davos und St. Moritz anbietet.',
        ar: 'اكتشف كيف تقدم سويس لاكشري سيرفيسز رحلات طيران VIP مباشرة إلى دافوس وسانت موريتز.',
      ),
      imageUrl: 'assets/blog3.png',
      isPublished: true,
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      contentBlocks: const [
        ContentBlock(
          type: ContentBlockType.paragraph,
          text: LocalizedText(
            en: 'Flying privately in Switzerland combines the unmatched speed of alpine airfields with bespoke luxury ground transfers.',
            fr: 'Voler en privé en Suisse allie la rapidité des aérodromes alpins à des transferts terrestres sur mesure.',
            de: 'Privatfliegen in der Schweiz verbindet alpine Flugplatznähe mit massgeschneiderten Transfers.',
            ar: 'يجمع الطيران الخاص في سويسرا بين سرعة المطارات الجبلية والخدمات الأرضية الفاخرة.',
          ),
        ),
      ],
    ),
  ];

  final _streamController = StreamController<List<BlogAdminModel>>.broadcast();
  bool _isSeeded = false;

  BlogRepository() {
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    try {
      _firestore.collection('blogs').orderBy('createdAt', descending: true).snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _blogs.clear();
            for (final doc in snapshot.docs) {
              _blogs.add(BlogAdminModel.fromMap(doc.data(), doc.id));
            }
            _notify();
          } else if (!_isSeeded) {
            _isSeeded = true;
            seedInitialBlogs();
          }
        },
        onError: (e) {
          dev.log('Firestore blogs listener error: $e', name: 'BlogRepository');
          _notify();
        },
      );
    } catch (e) {
      dev.log('Error initializing firestore blogs: $e', name: 'BlogRepository');
      _notify();
    }
  }

  Future<void> seedInitialBlogs({bool force = false}) async {
    try {
      if (!force) {
        final existing = await _firestore.collection('blogs').limit(1).get();
        if (existing.docs.isNotEmpty) return;
      }

      final batch = _firestore.batch();
      for (final blog in _blogs) {
        final docRef = _firestore.collection('blogs').doc(blog.id);
        batch.set(docRef, blog.toMap(), SetOptions(merge: true));
      }
      await batch.commit();
      dev.log('Initial blogs seeded successfully to Firestore', name: 'BlogRepository');
    } catch (e) {
      dev.log('Error seeding initial blogs to Firestore: $e', name: 'BlogRepository');
    }
  }

  void _notify() {
    _blogs.sort((a, b) {
      final aDate = a.createdAt ?? a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    _streamController.add(List.unmodifiable(_blogs));
  }

  Stream<List<BlogAdminModel>> watchBlogs() {
    return Stream<List<BlogAdminModel>>.multi((controller) {
      _notify();
      controller.add(List.unmodifiable(_blogs));
      final sub = _streamController.stream.listen((data) {
        controller.add(data);
      });
      controller.onCancel = () => sub.cancel();
    });
  }

  List<BlogAdminModel> get currentBlogs => List.unmodifiable(_blogs);

  Future<BlogAdminModel?> getBlogById(String id) async {
    try {
      final doc = await _firestore.collection('blogs').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final blog = BlogAdminModel.fromMap(doc.data()!, doc.id);
        final idx = _blogs.indexWhere((b) => b.id == id);
        if (idx >= 0) {
          _blogs[idx] = blog;
        } else {
          _blogs.insert(0, blog);
        }
        return blog;
      }
    } catch (e) {
      dev.log('Error fetching blog $id from Firestore: $e', name: 'BlogRepository');
    }

    try {
      return _blogs.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBlog(BlogAdminModel blog) async {
    final newId = blog.id.isNotEmpty ? blog.id : 'blog_${DateTime.now().millisecondsSinceEpoch}';
    final index = _blogs.indexWhere((b) => b.id == newId || (blog.id.isNotEmpty && b.id == blog.id));
    final finalBlog = blog.copyWith(
      id: newId,
      createdAt: blog.createdAt ?? (index >= 0 ? _blogs[index].createdAt : DateTime.now()),
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      _blogs[index] = finalBlog;
    } else {
      _blogs.insert(0, finalBlog);
    }
    _notify();

    try {
      await _firestore.collection('blogs').doc(newId).set(finalBlog.toMap(), SetOptions(merge: true));
    } catch (e) {
      dev.log('Error saving blog $newId to Firestore: $e', name: 'BlogRepository');
      rethrow;
    }
  }

  Future<void> deleteBlog(String id) async {
    _blogs.removeWhere((b) => b.id == id);
    _notify();

    try {
      await _firestore.collection('blogs').doc(id).delete();
    } catch (e) {
      dev.log('Error deleting blog $id from Firestore: $e', name: 'BlogRepository');
      rethrow;
    }
  }

  Future<void> togglePublishStatus(String id, bool isPublished) async {
    final index = _blogs.indexWhere((b) => b.id == id);
    final now = DateTime.now();
    DateTime? pubDate;
    if (index >= 0) {
      pubDate = isPublished ? (_blogs[index].publishedAt ?? now) : null;
      _blogs[index] = _blogs[index].copyWith(
        isPublished: isPublished,
        publishedAt: pubDate,
        updatedAt: now,
      );
      _notify();
    }

    try {
      await _firestore.collection('blogs').doc(id).update({
        'isPublished': isPublished,
        'publishedAt': pubDate?.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
    } catch (e) {
      dev.log('Error toggling publish status in Firestore: $e', name: 'BlogRepository');
      rethrow;
    }
  }
}
