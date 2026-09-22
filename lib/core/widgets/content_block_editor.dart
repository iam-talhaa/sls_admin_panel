import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../constants/app_text_styles.dart';
import '../models/content_block.dart';
import '../models/localized_text.dart';
import 'localized_field_tabs.dart';

class ContentBlockEditor extends StatefulWidget {
  final List<ContentBlock> initialBlocks;
  final ValueChanged<List<ContentBlock>> onChanged;

  const ContentBlockEditor({
    super.key,
    required this.initialBlocks,
    required this.onChanged,
  });

  @override
  State<ContentBlockEditor> createState() => _ContentBlockEditorState();
}

class _ContentBlockEditorState extends State<ContentBlockEditor> {
  late List<ContentBlock> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = List.from(widget.initialBlocks);
  }

  @override
  void didUpdateWidget(covariant ContentBlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBlocks != oldWidget.initialBlocks) {
      _blocks = List.from(widget.initialBlocks);
    }
  }

  void _notify() {
    widget.onChanged(List.from(_blocks));
  }

  void _addBlock(ContentBlockType type) {
    setState(() {
      switch (type) {
        case ContentBlockType.paragraph:
          _blocks.add(const ContentBlock(
            type: ContentBlockType.paragraph,
            text: LocalizedText.empty,
          ));
          break;
        case ContentBlockType.subheading:
          _blocks.add(const ContentBlock(
            type: ContentBlockType.subheading,
            text: LocalizedText.empty,
          ));
          break;
        case ContentBlockType.bulletList:
          _blocks.add(const ContentBlock(
            type: ContentBlockType.bulletList,
            items: [LocalizedText.empty],
          ));
          break;
        case ContentBlockType.linkReference:
          _blocks.add(const ContentBlock(
            type: ContentBlockType.linkReference,
            text: LocalizedText.empty,
            linkUrl: '',
          ));
          break;
      }
    });
    _notify();
  }

  void _removeBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
    });
    _notify();
  }

  void _moveBlock(int oldIndex, int newIndex) {
    if (newIndex < 0 || newIndex >= _blocks.length) return;
    setState(() {
      final item = _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, item);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Content Blocks (${_blocks.length})',
              style: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
            ),
            PopupMenuButton<ContentBlockType>(
              onSelected: _addBlock,
              color: colors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colors.border),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.primaryRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Add Block', style: AppTextStyles.buttonText.copyWith(color: Colors.white, fontSize: 12)),
                    const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: ContentBlockType.paragraph,
                  child: Row(
                    children: [
                      Icon(Icons.notes, size: 18, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Paragraph', style: TextStyle(color: colors.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ContentBlockType.subheading,
                  child: Row(
                    children: [
                      Icon(Icons.title, size: 18, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Subheading', style: TextStyle(color: colors.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ContentBlockType.bulletList,
                  child: Row(
                    children: [
                      Icon(Icons.format_list_bulleted, size: 18, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Bullet List', style: TextStyle(color: colors.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ContentBlockType.linkReference,
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 18, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Link Reference', style: TextStyle(color: colors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_blocks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              'No content blocks added yet. Click "+ Add Block" above to start.',
              style: AppTextStyles.subtitle.copyWith(color: colors.textSecondary),
            ),
          )
        else
          Column(
            children: [
              for (int index = 0; index < _blocks.length; index++)
                _buildBlockItem(_blocks[index], index, colors),
            ],
          ),
      ],
    );
  }

  Widget _buildBlockItem(ContentBlock block, int index, dynamic colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Up/Down Controls + Type badge + Delete
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceElevatedHigher,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                // Move Up
                IconButton(
                  icon: Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: index > 0 ? colors.textSecondary : colors.border,
                  ),
                  onPressed: index > 0 ? () => _moveBlock(index, index - 1) : null,
                  tooltip: 'Move Up',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(width: 2),
                // Move Down
                IconButton(
                  icon: Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: index < _blocks.length - 1 ? colors.textSecondary : colors.border,
                  ),
                  onPressed: index < _blocks.length - 1 ? () => _moveBlock(index, index + 1) : null,
                  tooltip: 'Move Down',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
                const SizedBox(width: 8),
                _getBlockIcon(block.type, colors),
                const SizedBox(width: 8),
                Text(
                  '${index + 1}. ${block.type.label}',
                  style: AppTextStyles.tableHeader.copyWith(color: colors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
                  onPressed: () => _removeBlock(index),
                  tooltip: 'Delete Block',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
          // Content Editor
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: _buildBlockContentEditor(block, index, colors),
          ),
        ],
      ),
    );
  }

  Widget _getBlockIcon(ContentBlockType type, dynamic colors) {
    switch (type) {
      case ContentBlockType.paragraph:
        return Icon(Icons.notes, size: 16, color: colors.info);
      case ContentBlockType.subheading:
        return Icon(Icons.title, size: 16, color: colors.warning);
      case ContentBlockType.bulletList:
        return Icon(Icons.format_list_bulleted, size: 16, color: colors.success);
      case ContentBlockType.linkReference:
        return Icon(Icons.link, size: 16, color: colors.primaryRed);
    }
  }

  Widget _buildBlockContentEditor(ContentBlock block, int blockIndex, dynamic colors) {
    switch (block.type) {
      case ContentBlockType.paragraph:
        return LocalizedFieldTabs(
          key: ValueKey('para_$blockIndex'),
          label: 'Paragraph Text',
          initialValue: block.text,
          maxLines: 4,
          onChanged: (val) {
            _blocks[blockIndex] = block.copyWith(text: val);
            _notify();
          },
        );

      case ContentBlockType.subheading:
        return LocalizedFieldTabs(
          key: ValueKey('subhead_$blockIndex'),
          label: 'Subheading Text',
          initialValue: block.text,
          maxLines: 1,
          onChanged: (val) {
            _blocks[blockIndex] = block.copyWith(text: val);
            _notify();
          },
        );

      case ContentBlockType.linkReference:
        return Column(
          children: [
            LocalizedFieldTabs(
              key: ValueKey('link_text_$blockIndex'),
              label: 'Link Anchor Text',
              initialValue: block.text,
              maxLines: 1,
              onChanged: (val) {
                _blocks[blockIndex] = block.copyWith(text: val);
                _notify();
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: block.linkUrl,
              style: AppTextStyles.inputText.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Target URL',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link, size: 18, color: colors.textSecondary),
              ),
              onChanged: (val) {
                _blocks[blockIndex] = block.copyWith(linkUrl: val);
                _notify();
              },
            ),
          ],
        );

      case ContentBlockType.bulletList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('List Items (${block.items.length})', style: AppTextStyles.fieldLabel.copyWith(color: colors.textPrimary)),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      final updatedItems = List<LocalizedText>.from(block.items)
                        ..add(LocalizedText.empty);
                      _blocks[blockIndex] = block.copyWith(items: updatedItems);
                    });
                    _notify();
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(block.items.length, (itemIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 14, right: 8),
                      child: Text('•', style: AppTextStyles.headingSmall.copyWith(color: colors.primaryRed)),
                    ),
                    Expanded(
                      child: LocalizedFieldTabs(
                        key: ValueKey('bullet_${blockIndex}_$itemIndex'),
                        label: 'Item ${itemIndex + 1}',
                        initialValue: block.items[itemIndex],
                        maxLines: 2,
                        onChanged: (val) {
                          final updatedItems = List<LocalizedText>.from(block.items);
                          updatedItems[itemIndex] = val;
                          _blocks[blockIndex] = block.copyWith(items: updatedItems);
                          _notify();
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: colors.textSecondary),
                      onPressed: () {
                        setState(() {
                          final updatedItems = List<LocalizedText>.from(block.items)
                            ..removeAt(itemIndex);
                          _blocks[blockIndex] = block.copyWith(items: updatedItems);
                        });
                        _notify();
                      },
                      tooltip: 'Remove Item',
                    ),
                  ],
                ),
              );
            }),
          ],
        );
    }
  }
}
