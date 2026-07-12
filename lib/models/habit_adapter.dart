import 'package:hive/hive.dart';
import 'habit.dart';

/// TypeAdapter manual untuk `Habit`.
///
/// Biasanya adapter ini dihasilkan otomatis oleh `build_runner` +
/// `hive_generator`. Di project ini adapter ditulis manual supaya:
/// 1. Tidak bergantung pada proses code-generation saat setup pertama kali.
/// 2. Mahasiswa benar-benar memahami bagaimana Hive membaca & menulis
///    byte-per-field ke dalam file database lokal (poin "memahami seluruh
///    kode yang digunakan" pada ketentuan final project).
///
/// Setiap field diberi index tetap (0..6). Jika field baru ditambahkan
/// di masa depan, tambahkan index baru di akhir agar data lama tetap
/// bisa dibaca (backward compatible).
class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      createdAt: fields[4] as DateTime,
      completedDates: (fields[5] as List).cast<String>(),
      photoPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(7) // jumlah field yang ditulis
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.completedDates)
      ..writeByte(6)
      ..write(obj.photoPath);
  }
}
