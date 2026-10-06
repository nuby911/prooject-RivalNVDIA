<div align="center">

# Rencana Harian

### Aplikasi Flutter untuk merencanakan tugas dan mengingatkan tenggat.

![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13.3%2B-0175C2?logo=dart)

</div>

Rencana Harian membantu mencatat agenda, mengatur tanggal dan waktu tenggat,
memantau progres penyelesaian, serta menerima pengingat langsung di perangkat.

## Pratinjau

<div align="center">
	<img src="./lib/scren/1.png" width="280" alt="Layar utama Rencana Harian" />
	<img src="./lib/scren/2.png" width="280" alt="Layar tambah tugas" />
</div>

## Fitur

- Tambah tugas dengan tanggal dan waktu tenggat opsional.
- Lihat jumlah agenda, tugas yang selesai, dan progres harian.
- Tandai tugas selesai atau belum selesai, buka detail, dan hapus tugas.
- Simpan daftar tugas secara lokal di perangkat menggunakan `shared_preferences`.
- Jadwalkan notifikasi lokal untuk tugas yang memiliki tenggat. Pengingat dijadwalkan
	10 menit sebelum tenggat; jika tenggat kurang dari 10 menit lagi, pengingat
	dijadwalkan pada waktu tenggat.
- Sesuaikan jadwal pengingat dengan zona waktu perangkat.

> Pengingat memerlukan izin notifikasi. Di Android, izin alarm presisi juga dapat
> diminta; jika tidak diberikan, pengingat mungkin terlambat.

## Teknologi

| Teknologi | Kegunaan |
| --- | --- |
| Flutter dan Dart | Antarmuka dan logika aplikasi |
| `shared_preferences` | Penyimpanan tugas lokal |
| `flutter_local_notifications` | Penjadwalan pengingat lokal |
| `timezone` dan `flutter_timezone` | Penjadwalan sesuai zona waktu perangkat |

## Menjalankan aplikasi

### Prasyarat

- Flutter SDK yang menyertakan Dart SDK `3.13.3` atau lebih baru dalam rentang kompatibel proyek.
- Android Studio atau perangkat Android untuk menjalankan aplikasi.
- Untuk menjalankan di iOS, diperlukan macOS dan Xcode.

Pastikan Flutter siap digunakan:

```bash
flutter doctor
```

Dari direktori proyek, ambil dependensi lalu jalankan aplikasi pada emulator atau
perangkat yang terhubung:

```bash
flutter pub get
flutter run
```

## Pengujian

Jalankan seluruh pengujian Flutter dari direktori proyek:

```bash
flutter test
```

## Build Android

Untuk membuat APK release:

```bash
flutter build apk --release
```

Hasil build tersedia di `build/app/outputs/flutter-apk/`.

## Struktur proyek

```text
lib/
├── main.dart
├── models/       # Model tugas
├── screens/      # Layar utama, tambah tugas, dan detail
├── services/     # Penyimpanan lokal dan notifikasi
└── widgets/      # Komponen antarmuka yang dapat digunakan ulang
test/             # Pengujian
```
