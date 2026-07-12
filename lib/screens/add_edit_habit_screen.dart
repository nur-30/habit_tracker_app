import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

/// Screen ini dipakai untuk DUA mode sekaligus:
/// - Mode tambah, ketika [existingHabit] bernilai null.
/// - Mode edit, ketika [existingHabit] diisi dari HabitDetailScreen.
class AddEditHabitScreen extends StatefulWidget {
  final Habit? existingHabit;

  const AddEditHabitScreen({super.key, this.existingHabit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedCategory;

  static const _categories = [
    'Kesehatan',
    'Belajar',
    'Produktivitas',
    'Olahraga',
    'Lainnya',
  ];

  bool get _isEditing => widget.existingHabit != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.existingHabit?.title ?? '');
    _descController =
        TextEditingController(text: widget.existingHabit?.description ?? '');
    _selectedCategory = widget.existingHabit?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<HabitProvider>();

    if (_isEditing) {
      final habit = widget.existingHabit!;
      habit.title = _titleController.text.trim();
      habit.description = _descController.text.trim();
      habit.category = _selectedCategory;
      provider.updateHabit(habit);
    } else {
      final habit = Habit(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        createdAt: DateTime.now(),
      );
      provider.addHabit(habit);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'Habit Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Nama Habit',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'contoh: Minum air 2 liter',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama habit tidak boleh kosong';
                }
                if (value.trim().length < 3) {
                  return 'Nama habit minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Deskripsi (opsional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Catatan tambahan tentang habit ini',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
