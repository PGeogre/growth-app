import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/db/repositories.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/image_field.dart';

/// 便签墙：彩色网格 + 置顶 + 搜索
class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  String _keyword = '';

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final notes = notesAsync.valueOrNull ?? [];

    final filtered = _keyword.isEmpty
        ? notes
        : notes.where((n) =>
            n.title.contains(_keyword) || n.content.contains(_keyword)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('便签'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => openNoteEditor(context, null),
        child: const Icon(Icons.add),
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Text('还没有便签，点右下角 + 新建', style: TextStyle(color: AppColors.textSecondary)))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => _NoteCard(note: filtered[i]),
            ),
    );
  }

  void _showSearch(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('搜索便签'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入关键词'),
          onChanged: (v) => setState(() => _keyword = v),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _keyword = '');
              Navigator.pop(ctx);
            },
            child: const Text('清除'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
}

void openNoteEditor(BuildContext context, Note? note) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
  );
}

class _NoteCard extends ConsumerWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(note.color);
    return GestureDetector(
      onTap: () => openNoteEditor(context, note),
      onLongPress: () => _showActions(context, ref),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title.isEmpty ? '无标题' : note.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3A3A3A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.pinned)
                  const Icon(Icons.push_pin, size: 16, color: Color(0xFF3A3A3A)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: note.imagePath != null && note.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(note.imagePath!), width: double.infinity, fit: BoxFit.cover),
                    )
                  : Text(
                      note.content,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF5A5A5A)),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(note.pinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(note.pinned ? '取消置顶' : '置顶'),
              onTap: () async {
                await Repositories.updateNote(Note(
                  id: note.id,
                  title: note.title,
                  content: note.content,
                  color: note.color,
                  imagePath: note.imagePath,
                  pinned: !note.pinned,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(notesProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('删除', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                await Repositories.deleteNote(note.id);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(notesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 便签编辑页
class NoteEditorPage extends ConsumerStatefulWidget {
  final Note? note;
  const NoteEditorPage({super.key, this.note});

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late int _color;
  late bool _pinned;
  String? _imagePath;

  static const _colors = [
    0xFFFFE9B8, // 黄
    0xFFFFD6D6, // 粉
    0xFFD6F0D6, // 绿
    0xFFD6E8FF, // 蓝
    0xFFE8D6FF, // 紫
    0xFFFFE0D6, // 橙
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _color = widget.note?.color ?? _colors[0];
    _pinned = widget.note?.pinned ?? false;
    _imagePath = widget.note?.imagePath;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty && _contentCtrl.text.trim().isEmpty && _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('写点内容吧')));
      return;
    }
    final note = Note(
      id: widget.note?.id ?? 0,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      color: _color,
      imagePath: _imagePath,
      pinned: _pinned,
    );
    if (widget.note == null) {
      await Repositories.addNote(note);
    } else {
      await Repositories.updateNote(note);
    }
    if (mounted) {
      ref.invalidate(notesProvider);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? '新建便签' : '编辑便签'),
        actions: [
          IconButton(
            icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _pinned = !_pinned),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 颜色选择
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in _colors)
                  GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Color(c),
                        shape: BoxShape.circle,
                        border: _color == c ? Border.all(color: AppColors.textPrimary, width: 2.5) : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(hintText: '标题'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentCtrl,
            maxLines: 6,
            decoration: const InputDecoration(hintText: '内容…'),
          ),
          const SizedBox(height: 16),
          ImageField(
            imagePath: _imagePath,
            onPick: () async {
              final p = await pickAndSaveImage();
              if (p != null) setState(() => _imagePath = p);
            },
            onRemove: () => setState(() => _imagePath = null),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
