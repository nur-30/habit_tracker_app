import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/habit.dart';

/// HabitProvider adalah satu-satunya "sumber kebenaran" (single source of
/// truth) untuk data habit di seluruh aplikasi. Semua screen membaca dan
/// menulis data lewat provider ini, tidak ada screen yang mengakses Hive
/// box secara langsung. Ini yang membuat alur state management jelas.
class HabitProvider extends ChangeNotifier {
  static const String boxName = 'habits_box';
  late Box<Habit> _box;
  bool _isReady = false;

  bool get isReady => _isReady;

  List<Habit> _habits = [];

  /// Diurutkan dari yang terbaru dibuat.
  List<Habit> get habits {
    final list = List<Habit>.from(_habits);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int get completedTodayCount =>
      _habits.where((h) => h.isCompletedToday).length;

  Future<void> init() async {
    _box = await Hive.openBox<Habit>(boxName);
    _habits = _box.values.toList();
    _isReady = true;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    await _box.put(habit.id, habit);
    _refresh();
  }

  Future<void> updateHabit(Habit habit) async {
    await _box.put(habit.id, habit);
    _refresh();
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
    _refresh();
  }

  Future<void> toggleToday(Habit habit) async {
    habit.toggleDate(DateTime.now());
    await _box.put(habit.id, habit);
    _refresh();
  }

  Future<void> attachPhoto(Habit habit, String path) async {
    habit.photoPath = path;
    await _box.put(habit.id, habit);
    _refresh();
  }

  void _refresh() {
    _habits = _box.values.toList();
    notifyListeners();
  }
}
