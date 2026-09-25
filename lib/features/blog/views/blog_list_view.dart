import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../data/models/blog_admin_model.dart';
import '../data/repositories/blog_repository.dart';

class BlogListView extends ConsumerStatefulWidget {
  const BlogListView({super.key});

  @override
  ConsumerState<BlogListView> createState() => _BlogListViewState();
}

class _BlogListViewState extends ConsumerState<BlogListView> {
  String _searchQuery = '';
  bool _isSyncing = false;

  Future<void> _deleteBlog(BlogAdminModel blog) async {
    final colors = context.colors;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Blog Post',
      message: 'Are you sure you want to delete "${blog.title.en}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await ref.read(blogRepositoryProvider).deleteBlog(blog.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Blog post deleted successfully'), backgroundColor: colors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting blog post: $e'), backgroundColor: colors.error),
          );
        }
      }
    }
  }

  Future<void> _duplicateBlog(BlogAdminModel blog) async {
    final colors = context.colors;
    try {
      final newId = 'blog_${DateTime.now().millisecondsSinceEpoch}';
      final duplicate = blog.copyWith(
        id: newId,
        title: blog.title.copyWith(en: '${blog.title.en} (Copy)'),
        order: blog.order + 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(blogRepositoryProvider).saveBlog(duplicate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Blog post duplicated successfully in Firebase'), backgroundColor: colors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating blog post: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  Future<void> _onReorder(List<BlogAdminModel> currentList, int oldIndex, int newIndex) async {
    final colors = context.colors;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final items = List<BlogAdminModel>.from(currentList);
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);

    try {
      await ref.read(blogRepositoryProvider).updateBlogsOrder(items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving new order: $e'), backgroundColor: colors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final blogsAsync = ref.watch(blogListStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Action Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Luxury Journal & Blog Posts', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text('Manage VIP aviation insights, destination guides, and lifestyle articles for the mobile app.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Force-sync all 11 default blog articles to Firebase Firestore',
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'Sync Blogs to Firebase',
                              message:
                                  'This will sync all 11 default blog articles with complete structured content blocks (paragraphs, subheadings, bullet lists, link references) to Firestore.\n\nProceed?',
                              confirmLabel: 'Sync Now',
                              icon: Icons.cloud_sync_outlined,
                            );

                            if (confirmed && mounted) {
                              setState(() => _isSyncing = true);
                              try {
                                await ref
                                    .read(blogRepositoryProvider)
                                    .seedInitialBlogs(force: true);
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          '✅ All 11 blog articles synced to Firebase successfully!'),
                                      backgroundColor: colors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Sync error: $e\n(Make sure you are logged in and Firestore rules allow writes)'),
                                      backgroundColor: colors.error,
                                      duration: const Duration(seconds: 6),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isSyncing = false);
                                }
                              }
                            }
                          },
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_sync_outlined, size: 18),
                    label: Text(_isSyncing ? 'Syncing...' : 'Sync to Firebase'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.go('/blog/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                height: 40,
                child: TextField(
                  style: AppTextStyles.inputText.copyWith(color: colors.textPrimary, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search blog posts by title or excerpt...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: Icon(Icons.search, size: 18, color: colors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Blog Posts List
        blogsAsync.when(
          loading: () => SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Text('Error loading blogs: $err', style: TextStyle(color: colors.error)),
          ),
          data: (blogs) {
            final filtered = blogs.where((b) {
              return _searchQuery.isEmpty ||
                  b.title.en.toLowerCase().contains(_searchQuery) ||
                  b.excerpt.en.toLowerCase().contains(_searchQuery);
            }).toList();

            if (filtered.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: EmptyState(
                  title: 'No blog posts found',
                  message: 'No articles match your criteria. Create your first post!',
                  actionLabel: 'Write Post',
                  onAction: () => context.go('/blog/new'),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double minTableWidth = 920;
                  final effectiveWidth = constraints.maxWidth < minTableWidth ? minTableWidth : constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: effectiveWidth,
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colors.surfaceElevatedHigher,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(11),
                                topRight: Radius.circular(11),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 32),
                                SizedBox(
                                  width: 80,
                                  child: Text('ID', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text('ARTICLE TITLE & EXCERPT', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text('CONTENT BLOCKS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 145,
                                  child: Text('STATUS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('ACTIONS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: colors.border),

                          // Reorderable Blog Items List
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            onReorder: (oldIdx, newIdx) => _onReorder(filtered, oldIdx, newIdx),
                            buildDefaultDragHandles: false,
                            itemBuilder: (context, index) {
                              final blog = filtered[index];
                              return Container(
                                key: ValueKey(blog.id.isNotEmpty ? blog.id : 'blog_$index'),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: colors.border)),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.go('/blog/${blog.id}'),
                                    hoverColor: colors.tableRowHover,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          // Drag Handle
                                          ReorderableDragStartListener(
                                            index: index,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.grab,
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 12.0),
                                                child: Icon(Icons.drag_indicator, color: colors.textSecondary, size: 20),
                                              ),
                                            ),
                                          ),

                                          // ID Badge / Icon
                                          Container(
                                            width: 60,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: colors.surfaceElevatedHigher,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: colors.border),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              blog.id.replaceAll('blog_', '#'),
                                              style: TextStyle(
                                                color: colors.primaryRed,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),

                                          // Title & Excerpt
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  blog.title.en.isNotEmpty ? blog.title.en : 'Untitled Post',
                                                  style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                                                ),
                                                if (blog.excerpt.en.isNotEmpty)
                                                  Text(
                                                    blog.excerpt.en,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Content blocks count
                                          SizedBox(
                                            width: 130,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceElevatedHigher,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: colors.border),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.layers_outlined, size: 14, color: colors.textSecondary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${blog.contentBlocks.length} Blocks',
                                                    style: AppTextStyles.bodySmall.copyWith(color: colors.textPrimary, fontSize: 11),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Status Switch
                                          SizedBox(
                                            width: 145,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Switch(
                                                    value: blog.isPublished,
                                                    onChanged: (val) {
                                                      ref.read(blogRepositoryProvider).togglePublishStatus(blog.id, val);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                StatusBadge.fromStatus(blog.isPublished ? 'Published' : 'Draft'),
                                              ],
                                            ),
                                          ),

                                          // Actions
                                          SizedBox(
                                            width: 130,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                                                  onPressed: () => context.go('/blog/${blog.id}'),
                                                  tooltip: 'Edit Post',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.copy_outlined, size: 18, color: colors.textSecondary),
                                                  onPressed: () => _duplicateBlog(blog),
                                                  tooltip: 'Duplicate Post',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                                  onPressed: () => _deleteBlog(blog),
                                                  tooltip: 'Delete Post',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
