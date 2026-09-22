import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
                Text('Publish VIP aviation insights, alpine travel guides, and lifestyle articles.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
              ],
            ),
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
                  const double minTableWidth = 900;
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
                                SizedBox(
                                  width: 80,
                                  child: Text('IMAGE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text('ARTICLE TITLE & EXCERPT', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('PUBLISHED DATE', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 155,
                                  child: Text('STATUS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text('ACTIONS', style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: colors.border),

                          // Blog Items List
                          Column(
                            children: [
                              for (int index = 0; index < filtered.length; index++) ...[
                                if (index > 0) Divider(height: 1, color: colors.border),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => context.go('/blog/${filtered[index].id}'),
                                    hoverColor: colors.tableRowHover,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        children: [
                                          // Thumbnail
                                          Container(
                                            width: 60,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: colors.surfaceElevatedHigher,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: colors.border),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: filtered[index].imageUrl.isNotEmpty
                                                ? (filtered[index].imageUrl.startsWith('http')
                                                    ? Image.network(filtered[index].imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.article, color: colors.textSecondary, size: 18))
                                                    : Image.asset(filtered[index].imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.article, color: colors.textSecondary, size: 18)))
                                                : Icon(Icons.article, color: colors.textSecondary, size: 18),
                                          ),
                                          const SizedBox(width: 20),

                                          // Title & Excerpt
                                          Expanded(
                                            flex: 4,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  filtered[index].title.en.isNotEmpty ? filtered[index].title.en : 'Untitled Post',
                                                  style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
                                                ),
                                                if (filtered[index].excerpt.en.isNotEmpty)
                                                  Text(
                                                    filtered[index].excerpt.en,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // Published Date
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              filtered[index].publishedAt != null
                                                  ? DateFormat('dd MMM yyyy, HH:mm').format(filtered[index].publishedAt!)
                                                  : (filtered[index].createdAt != null
                                                      ? 'Draft (${DateFormat('dd MMM yyyy').format(filtered[index].createdAt!)})'
                                                      : 'Draft'),
                                              style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
                                            ),
                                          ),

                                          // Status Switch
                                          SizedBox(
                                            width: 155,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Transform.scale(
                                                  scale: 0.8,
                                                  child: Switch(
                                                    value: filtered[index].isPublished,
                                                    onChanged: (val) {
                                                      ref.read(blogRepositoryProvider).togglePublishStatus(filtered[index].id, val);
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                StatusBadge.fromStatus(filtered[index].isPublished ? 'Published' : 'Draft'),
                                              ],
                                            ),
                                          ),

                                          // Actions
                                          SizedBox(
                                            width: 100,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit_outlined, size: 18, color: colors.textPrimary),
                                                  onPressed: () => context.go('/blog/${filtered[index].id}'),
                                                  tooltip: 'Edit Post',
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                                                  onPressed: () => _deleteBlog(filtered[index]),
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
                              ],
                            ],
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
