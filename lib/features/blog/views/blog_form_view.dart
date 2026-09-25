import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_color_scheme.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/content_block.dart';
import '../../../core/models/localized_text.dart';
import '../../../core/widgets/content_block_editor.dart';
import '../../../core/widgets/image_uploader.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/localized_field_tabs.dart';
import '../data/models/blog_admin_model.dart';
import '../data/repositories/blog_repository.dart';

class BlogFormView extends ConsumerStatefulWidget {
  final String blogId;

  const BlogFormView({super.key, required this.blogId});

  @override
  ConsumerState<BlogFormView> createState() => _BlogFormViewState();
}

class _BlogFormViewState extends ConsumerState<BlogFormView> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  late String _id;
  int _order = 0;
  LocalizedText _title = LocalizedText.empty;
  LocalizedText _excerpt = LocalizedText.empty;
  String _imageUrl = '';
  List<ContentBlock> _contentBlocks = [];
  bool _isPublished = false;
  DateTime? _publishedAt;

  bool get isNew => widget.blogId == 'new' || widget.blogId.isEmpty;

  @override
  void initState() {
    super.initState();
    _loadBlogData();
  }

  Future<void> _loadBlogData() async {
    if (isNew) {
      _id = 'blog_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final blog = await ref.read(blogRepositoryProvider).getBlogById(widget.blogId);
      if (blog != null) {
        _id = blog.id;
        _order = blog.order;
        _title = blog.title;
        _excerpt = blog.excerpt;
        _imageUrl = blog.imageUrl;
        _contentBlocks = List.from(blog.contentBlocks);
        _isPublished = blog.isPublished;
        _publishedAt = blog.publishedAt;
      }
    } catch (e) {
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading blog: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickPublishedDate() async {
    final colors = context.colors;
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _publishedAt ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: colors.primaryRed,
            surface: colors.surfaceElevated,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_publishedAt ?? now),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: colors.primaryRed,
              surface: colors.surfaceElevated,
            ),
          ),
          child: child!,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          _publishedAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _handleSave() async {
    final colors = context.colors;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please complete all required fields.'), backgroundColor: colors.error),
      );
      return;
    }

    if (_title.en.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please enter an article title in English.'), backgroundColor: colors.error),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final blog = BlogAdminModel(
        id: isNew ? '' : _id,
        order: _order,
        title: _title,
        excerpt: _excerpt,
        imageUrl: _imageUrl,
        contentBlocks: _contentBlocks,
        isPublished: _isPublished,
        publishedAt: _isPublished ? (_publishedAt ?? DateTime.now()) : null,
      );

      await ref.read(blogRepositoryProvider).saveBlog(blog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew ? 'Blog post published successfully!' : 'Blog post updated successfully!'),
            backgroundColor: colors.success,
          ),
        );
        context.go('/blog');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving blog: $e'), backgroundColor: colors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator(color: colors.primaryRed)),
      );
    }

    return LoadingOverlay(
      isLoading: _isSaving,
      message: 'Saving blog post...',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/blog');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isNew ? 'Write New Article' : 'Edit Article', style: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary)),
                        Text(isNew ? 'Create a new journal post' : 'ID: $_id', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/blog');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(color: colors.border),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: Text(isNew ? 'Save Article' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Basic Article Info Card
            Container(
              padding: const EdgeInsets.all(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Article Header', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 20),

                  LocalizedFieldTabs(
                    label: 'Article Title',
                    initialValue: _title,
                    isRequired: true,
                    hint: 'e.g. The Ultimate Guide to Private Jet Travel in the Swiss Alps',
                    onChanged: (val) => _title = val,
                  ),
                  const SizedBox(height: 20),

                  LocalizedFieldTabs(
                    label: 'Article Excerpt / Summary',
                    initialValue: _excerpt,
                    maxLines: 3,
                    hint: 'Brief summary displayed on blog cards and mobile overview...',
                    onChanged: (val) => _excerpt = val,
                  ),
                  const SizedBox(height: 20),

                  ImageUploader(
                    label: 'Featured Cover Image',
                    initialImageUrl: _imageUrl,
                    storagePath: 'blogs/${isNew ? 'temp_${DateTime.now().millisecondsSinceEpoch}' : _id}',
                    onImageUploaded: (url) => _imageUrl = url,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rich Body Content Blocks
            Container(
              padding: const EdgeInsets.all(24),
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
              child: ContentBlockEditor(
                initialBlocks: _contentBlocks,
                onChanged: (blocks) => _contentBlocks = blocks,
              ),
            ),
            const SizedBox(height: 24),

            // Publishing Options
            Container(
              padding: const EdgeInsets.all(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Publishing Settings', style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Publish to Mobile App', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                          Text('When enabled, this article is instantly visible in the mobile app journal.', style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary)),
                        ],
                      ),
                      Switch(
                        value: _isPublished,
                        onChanged: (val) {
                          setState(() {
                            _isPublished = val;
                            if (val && _publishedAt == null) {
                              _publishedAt = DateTime.now();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isPublished) ...[
                    const SizedBox(height: 16),
                    Divider(color: colors.border),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Publish Date & Time', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                            Text(
                              _publishedAt != null
                                  ? DateFormat('EEEE, dd MMMM yyyy • HH:mm').format(_publishedAt!)
                                  : 'Now',
                              style: AppTextStyles.bodyMedium.copyWith(color: colors.primaryRed),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickPublishedDate,
                          icon: Icon(Icons.calendar_today, size: 16, color: colors.textSecondary),
                          label: Text('Change Date', style: TextStyle(color: colors.textSecondary)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
