import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../utils/date_utils.dart';
import 'add_edit_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  bool _isTakingPhoto = false;

  /// Mengambil foto sebagai "bukti" habit sudah dikerjakan hari ini.
  /// Ini adalah implementasi fitur perangkat mobile (kamera) yang
  /// diminta pada ketentuan minimal aplikasi.
  Future<void> _capturePhotoProof() async {
    setState(() => _isTakingPhoto = true);
    try {
      final picker = ImagePicker();
      final XFile? shot = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        imageQuality: 80,
      );

      if (shot == null) return; // user membatalkan

      // Salin file ke direktori dokumen aplikasi supaya path tetap valid
      // walau file cache sistem dibersihkan.
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'habit_${widget.habit.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(shot.path).copy('${appDir.path}/$fileName');

      if (!mounted) return;
      await context.read<HabitProvider>().attachPhoto(widget.habit, savedFile.path);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus habit ini?'),
        content: Text('"${widget.habit.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<HabitProvider>().deleteHabit(widget.habit.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dengarkan perubahan supaya UI ikut update ketika toggle/foto berubah.
    final provider = context.watch<HabitProvider>();
    final habit = provider.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditHabitScreen(existingHabit: habit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(habit.category)),
              Chip(label: Text('🔥 Streak ${habit.currentStreak} hari')),
              Chip(label: Text('${habit.totalCompleted}x total selesai')),
            ],
          ),
          const SizedBox(height: 16),
          if (habit.description.isNotEmpty) ...[
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(habit.description),
            const SizedBox(height: 20),
          ],
          Text('Dibuat pada ${formatFriendlyDate(habit.createdAt)}',
              style: TextStyle(color: Colors.black.withOpacity(0.5))),
          const SizedBox(height: 24),

          // Tombol toggle selesai hari ini
          FilledButton.icon(
            onPressed: () => provider.toggleToday(habit),
            icon: Icon(habit.isCompletedToday
                ? Icons.check_circle
                : Icons.radio_button_unchecked),
            label: Text(habit.isCompletedToday
                ? 'Sudah selesai hari ini'
                : 'Tandai selesai hari ini'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor:
                  habit.isCompletedToday ? Colors.green : null,
            ),
          ),
          const SizedBox(height: 12),

          // Fitur kamera: ambil foto bukti
          OutlinedButton.icon(
            onPressed: _isTakingPhoto ? null : _capturePhotoProof,
            icon: _isTakingPhoto
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.camera_alt_outlined),
            label: Text(habit.photoPath == null
                ? 'Ambil Foto Bukti'
                : 'Ganti Foto Bukti'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          if (habit.photoPath != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(habit.photoPath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Text('Foto tidak ditemukan'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
