# Habit Tracker — Final Project UAS Mobile Computing

Aplikasi pelacak kebiasaan harian (habit tracker) sederhana dibangun dengan
Flutter. Pengguna bisa membuat habit, menandainya selesai setiap hari,
melihat streak (rentetan hari berturut-turut), dan mengambil foto sebagai
bukti telah mengerjakan habit tersebut.

## 1. Tema
**A. Habit Tracker App** — kombinasi konsep *Daily Activity Tracker* dengan
tambahan bukti foto per hari.

## 2. Fitur Utama
- **3 screen dengan navigasi jelas:**
  1. `HomeScreen` — daftar semua habit + ringkasan progres hari ini.
  2. `AddEditHabitScreen` — form tambah/edit habit dengan validasi input.
  3. `HabitDetailScreen` — detail habit, tandai selesai, ambil foto bukti,
     hapus habit.
- **State management:** `provider` (`ChangeNotifier`) — `HabitProvider`
  adalah satu-satunya sumber data yang didengarkan semua screen.
- **Local storage:** `Hive`, dengan `TypeAdapter` ditulis manual (lihat
  `lib/models/habit_adapter.dart`) supaya proses serialisasi data mudah
  dijelaskan tanpa bergantung pada `build_runner`.
- **Fitur perangkat mobile:** kamera (`image_picker`) untuk mengambil foto
  bukti, foto disalin ke folder dokumen aplikasi (`path_provider`) agar
  path-nya tetap valid.
- **Form & validasi:** nama habit wajib diisi, minimal 3 karakter.
- **UI/UX:** desain Material 3, kartu habit dengan checkbox cepat, badge
  streak, empty state saat belum ada data.

## 3. Struktur Project
```
lib/
 ├─ main.dart                     # Entry point, inisialisasi Hive & Provider
 ├─ models/
 │   ├─ habit.dart                # Model data + logika streak
 │   └─ habit_adapter.dart        # Hive TypeAdapter manual
 ├─ providers/
 │   └─ habit_provider.dart       # State management (CRUD + toggle + foto)
 ├─ screens/
 │   ├─ home_screen.dart
 │   ├─ add_edit_habit_screen.dart
 │   └─ habit_detail_screen.dart
 ├─ widgets/
 │   ├─ habit_card.dart
 │   └─ empty_state.dart
 └─ utils/
     └─ date_utils.dart
```

## 4. Alasan Desain (untuk presentasi)
- **Kenapa Provider, bukan setState biasa?** Data habit dipakai di banyak
  screen (list, detail, form) — Provider menghindari prop-drilling dan
  membuat satu sumber data konsisten dengan Hive di baliknya.
- **Kenapa Hive?** Ringan, tidak butuh server/API, cocok untuk data lokal
  sederhana seperti daftar habit dan tanggal penyelesaian.
- **Kenapa TypeAdapter manual?** Agar seluruh proses simpan-baca data biner
  bisa dijelaskan baris per baris saat demo, bukan kode hasil generate yang
  "ajaib".
- **Kenapa foto disalin ke app documents directory?** File sementara dari
  kamera bisa terhapus oleh sistem; menyalin ke folder aplikasi memastikan
  foto tetap ada selama data habit tersebut ada.

## 5. Cara Menjalankan
Project ini hanya berisi folder `lib/` dan `pubspec.yaml` (kode aplikasi).
Folder native `android/` & `ios/` perlu digenerate dengan Flutter CLI di
komputer masing-masing (karena bergantung pada versi Flutter/Android SDK
lokal):

```bash
# 1. Buat project Flutter kosong
flutter create habit_tracker_app
cd habit_tracker_app

# 2. Timpa pubspec.yaml dan folder lib/ dengan yang ada di paket ini
#    (copy-paste isi pubspec.yaml, lalu replace seluruh folder lib/)

# 3. Ambil dependency
flutter pub get

# 4. Tambahkan izin kamera di android/app/src/main/AndroidManifest.xml
#    (lihat berkas ANDROID_PERMISSIONS.txt pada paket ini)

# 5. Jalankan
flutter run
```

## 6. Build APK
```bash
flutter build apk --release
```
File APK akan ada di `build/app/outputs/flutter-apk/app-release.apk`.

## 7. Pengembangan Lanjutan (opsional)
- Tambah notifikasi pengingat harian (`flutter_local_notifications`).
- Tambah grafik progres mingguan/bulanan.
- Tambah kategori kustom yang bisa diedit pengguna.
