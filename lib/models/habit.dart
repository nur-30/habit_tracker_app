/// Model data untuk satu Habit.
///
/// Sengaja dibuat sebagai plain Dart class (bukan pakai `@HiveType` hasil
/// code-generation) supaya seluruh proses serialisasi ke Hive terlihat
/// jelas dan mudah dijelaskan saat presentasi (lihat `habit_adapter.dart`).
class Habit {
  String id;
  String title;
  String description;
  String category;
  DateTime createdAt;

  /// Tanggal-tanggal ketika habit ini "selesai dikerjakan".
  /// Disimpan sebagai String format `yyyy-MM-dd` supaya mudah dibandingkan.
  List<String> completedDates;

  /// Path file foto bukti (hasil kamera) yang terakhir diambil untuk habit ini.
  String? photoPath;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    List<String>? completedDates,
    this.photoPath,
  }) : completedDates = completedDates ?? [];

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  bool get isCompletedToday => completedDates.contains(dateKey(DateTime.now()));

  void toggleDate(DateTime date) {
    final key = dateKey(date);
    if (completedDates.contains(key)) {
      completedDates.remove(key);
    } else {
      completedDates.add(key);
    }
  }

  /// Menghitung streak (berapa hari berturut-turut selesai, dihitung mundur
  /// dari hari ini). Bagian ini sederhana tapi menunjukkan pengelolaan
  /// data/alur logika di sisi aplikasi, bukan hanya CRUD polos.
  int get currentStreak {
    int streak = 0;
    DateTime cursor = DateTime.now();
    while (completedDates.contains(dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get totalCompleted => completedDates.length;
}
